IF OBJECT_ID('sales.post_return') IS NOT NULL
DROP PROCEDURE sales.post_return;

GO

CREATE PROCEDURE sales.post_return
(
    @transaction_master_id          bigint,
    @office_id                      integer,
    @user_id                        integer,
    @login_id                       bigint,
    @value_date                     date,
    @book_date                      date,
    @store_id                       integer,
    @counter_id                     integer,
    @customer_id                    integer,
    @price_type_id                  integer,
    @reference_number               national character varying(24),
    @statement_reference            national character varying(2000),
    @details                        sales.sales_detail_type
)
AS
BEGIN
    DECLARE @book_name              national character varying = 'Sales Return';
    DECLARE @customer_id            bigint;
    DECLARE @cost_center_id         bigint;
    DECLARE @tran_master_id         bigint;
    DECLARE @tran_counter           integer;
    DECLARE @tran_code national character varying(50);
    DECLARE @checkout_id            bigint;
    DECLARE @grand_total            dbo.money_strict;
    DECLARE @discount_total         dbo.money_strict2;
    DECLARE @is_credit              bit;
    DECLARE @default_currency_code  national character varying(12);
    DECLARE @cost_of_ods_sold     dbo.money_strict2;
    DECLARE @ck_id                  bigint;
    DECLARE @sales_id               bigint;
    DECLARE @tax_total              dbo.money_strict2;
    DECLARE @tax_account_id                 integer;
    DECLARE this                    RECORD;

    IF NOT finance.can_post_transaction(@login_id, @user_id, @office_id, @book_name, @value_date)
    BEGIN
        RETURN 0;
    END;

    @tax_account_id                         = finance.get_sales_tax_account_id_by_office_id(@office_id);

    IF(NOT sales.validate_items_for_return(@transaction_master_id, @details))
    BEGIN
        RETURN 0;
    END;

    @default_currency_code          = core.get_currency_code_by_office_id(@office_id);

    SELECT sales.sales.sales_id 
    INTO @sales_id
    FROM sales.sales
    WHERE sales.sales.transaction_master_id = +transaction_master_id;
    
    SELECT cost_center_id   INTO @cost_center_id    
    FROM finance.transaction_master 
    WHERE finance.transaction_master.transaction_master_id = @transaction_master_id;

    SELECT 
        is_credit,
        checkout_id
    INTO 
        @is_credit,
        @ck_id
    FROM sales.sales
    WHERE transaction_master_id = @transaction_master_id;

    DECLARE @temp_checkout_details TABLE
    (
        id                              integer IDENTITY PRIMARY KEY,
        checkout_id                     bigint, 
        tran_type                       national character varying(2), 
        store_id                        integer,
        item_id                         integer, 
        quantity                        dbo.integer_strict,        
        unit_id                         integer,
        base_quantity                   decimal,
        base_unit_id                    integer,                
        price                           dbo.money_strict,
        cost_of_ods_sold              dbo.money_strict2 DEFAULT(0),
        discount                        dbo.money_strict2 DEFAULT(0),
        discount_rate                   dbo.decimal_strict2,
        tax                             dbo.money_strict2,
        shipping_charge                 dbo.money_strict2,
        sales_account_id                integer,
        sales_discount_account_id       integer,
        sales_return_account_id         integer,
        inventory_account_id            integer,
        cost_of_ods_sold_account_id   integer
    ) ;
        
    INSERT INTO @temp_transaction_details(store_id, item_id, quantity, unit_id, price, discount_rate, tax, shipping_charge)
    SELECT store_id, item_id, quantity, unit_id, price, discount_rate, tax, shipping_charge
    FROM @details;

    UPDATE @temp_transaction_details 
    SET
        tran_type                   = 'Dr',
        base_quantity               = inventory.get_base_quantity_by_unit_id(unit_id, quantity),
        base_unit_id                = inventory.get_root_unit_id(unit_id);

    UPDATE @temp_transaction_details
    SET
        sales_account_id                = inventory.get_sales_account_id(item_id),
        sales_discount_account_id       = inventory.get_sales_discount_account_id(item_id),
        sales_return_account_id         = inventory.get_sales_return_account_id(item_id),        
        inventory_account_id            = inventory.get_inventory_account_id(item_id),
        cost_of_ods_sold_account_id   = inventory.get_cost_of_ods_sold_account_id(item_id);
    
    IF EXISTS
    (
        SELECT TOP 1 0 FROM @temp_transaction_details AS details
        WHERE inventory.is_valid_unit_id(details.unit_id, details.item_id) = 0
    )
    BEGIN
        RAISERROR('Item/unit mismatch.', 10, 1);
    END;


    @tran_master_id             = nextval(pg_get_integer IDENTITY_sequence('finance.transaction_master', 'transaction_master_id'));
    @checkout_id                = nextval(pg_get_integer IDENTITY_sequence('inventory.checkouts', 'checkout_id'));
    @tran_counter               = finance.get_new_transaction_counter(@value_date);
    @tran_code                  = finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id);

    INSERT INTO finance.transaction_master(transaction_master_id, transaction_counter, transaction_code, book, value_date, book_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference)
    SELECT @tran_master_id, @tran_counter, @tran_code, @book_name, @value_date, @book_date, @user_id, @login_id, @office_id, @cost_center_id, @reference_number, @statement_reference;
        
    SELECT SUM(COALESCE(tax, 0))                                INTO @tax_total FROM @temp_transaction_details;
    SELECT SUM(COALESCE(discount, 0))                           INTO @discount_total FROM @temp_transaction_details;
    SELECT SUM(COALESCE(price, 0) * COALESCE(quantity, 0))      INTO @grand_total FROM @temp_transaction_details;



    UPDATE @temp_transaction_details
    SET cost_of_ods_sold = COALESCE(inventory.get_write_off_cost_of_ods_sold(@ck_id, item_id, unit_id, quantity), 0);


    SELECT SUM(cost_of_ods_sold) INTO @cost_of_ods_sold FROM @temp_transaction_details;


    IF(@cost_of_ods_sold > 0)
    BEGIN
        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT @tran_master_id, @office_id, @value_date, @book_date, 'Dr', inventory_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(cost_of_ods_sold, 0)), 1, @default_currency_code, SUM(COALESCE(cost_of_ods_sold, 0))
        FROM @temp_transaction_details
        GROUP BY inventory_account_id;


        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT @tran_master_id, @office_id, @value_date, @book_date, 'Cr', cost_of_ods_sold_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(cost_of_ods_sold, 0)), 1, @default_currency_code, SUM(COALESCE(cost_of_ods_sold, 0))
        FROM @temp_transaction_details
        GROUP BY cost_of_ods_sold_account_id;
    END;


    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er,amount_in_local_currency) 
    SELECT @tran_master_id, @office_id, @value_date, @book_date, 'Dr', sales_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0)), @default_currency_code, 1, SUM(COALESCE(price, 0) * COALESCE(quantity, 0))
    FROM @temp_transaction_details
    GROUP BY sales_account_id;


    IF(@discount_total IS NOT NULL AND @discount_total > 0)
    BEGIN
        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency) 
        SELECT @tran_master_id, @book_name, @office_id, @value_date, @book_date, 'Cr', sales_discount_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(discount, 0)), @default_currency_code, 1, SUM(COALESCE(discount, 0))
        FROM @temp_transaction_details
        GROUP BY sales_discount_account_id;
    END;

    IF(COALESCE(@tax_total, 0) > 0)
    BEGIN
        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency) 
        SELECT @tran_master_id, @office_id, @value_date, @book_date, 'Dr', @tax_account_id, @statement_reference, @default_currency_code, @tax_total, @default_currency_code, 1, @tax_total;
    END;    

    IF(@is_credit)
    BEGIN
        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency) 
        SELECT @tran_master_id, @office_id, @value_date, @book_date, 'Cr',  inventory.get_account_id_by_customer_id(@customer_id), @statement_reference, @default_currency_code, @grand_total - @discount_total, @default_currency_code, 1, @grand_total - @discount_total;
    END
    ELSE
    BEGIN
        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency) 
        SELECT @tran_master_id, @office_id, @value_date, @book_date, 'Cr',  sales_return_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0)) - SUM(COALESCE(discount, 0)), @default_currency_code, 1, SUM(COALESCE(price, 0) * COALESCE(quantity, 0)) - SUM(COALESCE(discount, 0))
        FROM @temp_transaction_details
        GROUP BY sales_return_account_id;
    END;



    INSERT INTO inventory.checkouts(checkout_id, transaction_book, value_date, book_date, transaction_master_id, office_id, posted_by) 
    SELECT @checkout_id, @book_name, @value_date, @book_date, @tran_master_id, @office_id, @user_id;


    INSERT INTO inventory.checkout_details(value_date, book_date, checkout_id, transaction_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, tax, cost_of_ods_sold, discount)
    SELECT @value_date, @book_date, @checkout_id, tran_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, tax, cost_of_ods_sold, discount FROM @temp_transaction_details;

    INSERT INTO sales.returns(sales_id, checkout_id, counter_id, transaction_master_id, return_transaction_master_id, customer_id, price_type_id, is_credit)
    SELECT @sales_id, @checkout_id, @counter_id, @transaction_master_id, @tran_master_id, @customer_id, @price_type_id, 0;

    EXECUTE finance.auto_verify @tran_master_id, @office_id;

    SELECT @tran_master_id;
END;




-- SELECT * FROM sales.post_return
-- (
--     12, --_transaction_master_id          bigint,
--     1, --_office_id                      integer,
--     1, --_user_id                        integer,
--     1, --_login_id                       bigint,
--     finance.get_value_date(1), --_value_date                     date,
--     finance.get_value_date(1), --_book_date                      date,
--     1, --_store_id                       integer,
--     1, --_counter_id                       integer,
--     1, --_customer_id                    integer,
--     1, --_price_type_id                  integer,
--     '', --_reference_number               national character varying(24),
--     '', --_statement_reference            national character varying(1000),
--     ARRAY
--     [
--         ROW(1, 'Dr', 1, 1, 1,1, 0, 10, 200),
--         ROW(1, 'Dr', 2, 1, 7,1, 300, 10, 30),
--         ROW(1, 'Dr', 3, 1, 1,1, 5000, 10, 50)
--     ]
-- );
-- 
-- 


GO
