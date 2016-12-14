IF OBJECT_ID('sales.post_sales') IS NOT NULL
DROP PROCEDURE sales.post_sales;

GO

CREATE PROCEDURE sales.post_sales
(
    @office_id                              integer,
    @user_id                                integer,
    @login_id                               bigint,
    @counter_id                             integer,
    @value_date                             date,
    @book_date                              date,
    @cost_center_id                         integer,
    @reference_number                       national character varying(24),
    @statement_reference                    national character varying(2000),
    @tender                                 dbo.money_strict2,
    @change                                 dbo.money_strict2,
    @payment_term_id                        integer,
    @check_amount                           dbo.money_strict2,
    @check_bank_name                        national character varying(1000),
    @check_number                           national character varying(100),
    @check_date                             date,
    @gift_card_number                       national character varying(100),
    @customer_id                            integer,
    @price_type_id                          integer,
    @shipper_id                             integer,
    @store_id                               integer,
    @coupon_code                            national character varying(100),
    @is_flat_discount                       bit,
    @discount                               dbo.money_strict2,
    @details                                sales.sales_detail_type,
    @sales_quotation_id                     bigint,
    @sales_order_id                         bigint
)
AS
BEGIN        
    DECLARE @book_name                      national character varying(48) = 'Sales Entry';
    DECLARE @transaction_master_id          bigint;
    DECLARE @checkout_id                    bigint;
    DECLARE @checkout_detail_id             bigint;
    DECLARE @grand_total                    dbo.money_strict;
    DECLARE @discount_total                 dbo.money_strict2;
    DECLARE @receivable                     dbo.money_strict2;
    DECLARE @default_currency_code          national character varying(12);
    DECLARE @is_periodic                    bit = inventory.is_periodic_inventory(@office_id);
    DECLARE @cost_of_ods                    dbo.money_strict;
    DECLARE @tran_counter                   integer;
    DECLARE @transaction_code               national character varying(50);
    DECLARE @tax_total                      dbo.money_strict2;
    DECLARE @shipping_charge                dbo.money_strict2;
    DECLARE @cash_repository_id             integer;
    DECLARE @cash_account_id                integer;
    DECLARE @is_cash                        bit = 0;
    DECLARE @is_credit                      bit = 0;
    DECLARE @gift_card_id                   integer;
    DECLARE @gift_card_balance              decimal(24, 4);
    DECLARE @coupon_id                      integer;
    DECLARE @coupon_discount                decimal(24, 4); 
    DECLARE @default_discount_account_id    integer;
    DECLARE @fiscal_year_code               national character varying(12);
    DECLARE @invoice_number                 bigint;
    DECLARE @tax_account_id                 integer;
    DECLARE this                            RECORD;

    IF NOT finance.can_post_transaction(@login_id, @user_id, @office_id, @book_name, @value_date)
    BEGIN
        RETURN 0;
    END;

    @tax_account_id                         = finance.get_sales_tax_account_id_by_office_id(@office_id);
    @default_currency_code                  = core.get_currency_code_by_office_id(@office_id);
    @cash_account_id                        = inventory.get_cash_account_id_by_store_id(@store_id);
    @cash_repository_id                     = inventory.get_cash_repository_id_by_store_id(@store_id);
    @is_cash                                = finance.is_cash_account_id(@cash_account_id);    

    @coupon_id                              = sales.get_active_coupon_id_by_coupon_code(@coupon_code);
    @gift_card_id                           = sales.get_gift_card_id_by_gift_card_number(@gift_card_number);
    @gift_card_balance                      = sales.get_gift_card_balance(@gift_card_id, @value_date);


    SELECT TOP 1 @fiscal_year_code = finance.fiscal_year.fiscal_year_code
    FROM finance.fiscal_year
    WHERE @value_date BETWEEN finance.fiscal_year.starts_from AND finance.fiscal_year.ends_on;

    IF(COALESCE(@customer_id, 0) = 0)
    BEGIN
        RAISERROR('Please select a customer.', 10, 1);
    END;

    IF(COALESCE(@coupon_code, '') != '' AND COALESCE(@discount) > 0)
    BEGIN
        RAISERROR('Please do not specify discount rate when you mention coupon code.', 10, 1);
    END;
    --TODO: VALIDATE COUPON CODE AND POST DISCOUNT

    IF(COALESCE(@payment_term_id, 0) > 0)
    BEGIN
        @is_credit                          = 1;
    END;

    IF(@is_credit = 0 AND @is_cash = 0)
    BEGIN
        RAISERROR('Cannot post sales. Invalid cash account mapping on store.', 10, 1);
    END;

   
    IF(NOT @is_cash)
    BEGIN
        @cash_repository_id                 = NULL;
    END;

    DECLARE @temp_checkout_details TABLE
    (
        id                              integer IDENTITY PRIMARY KEY,
        checkout_id                     bigint, 
        tran_type                       national character varying(2), 
        store_id                        integer,
        item_id                         integer, 
        quantity                        dbo.decimal_strict,        
        unit_id                         integer,
        base_quantity                   decimal,
        base_unit_id                    integer,                
        price                           dbo.money_strict,
        cost_of_ods_sold              dbo.money_strict2 DEFAULT(0),
        discount_rate                   dbo.decimal_strict2,
        discount                        dbo.money_strict2,
        tax                             dbo.money_strict2,
        shipping_charge                 dbo.money_strict2,
        sales_account_id                integer,
        sales_discount_account_id       integer,
        inventory_account_id            integer,
        cost_of_ods_sold_account_id   integer
    ) ;

    INSERT INTO @temp_checkout_details(store_id, item_id, quantity, unit_id, price, discount_rate, tax, shipping_charge)
    SELECT store_id, item_id, quantity, unit_id, price, discount_rate, tax, shipping_charge
    FROM @details;

    
    UPDATE @temp_checkout_details 
    SET
        tran_type                       = 'Cr',
        base_quantity                   = inventory.get_base_quantity_by_unit_id(unit_id, quantity),
        base_unit_id                    = inventory.get_root_unit_id(unit_id),
        discount                        = ROUND((price * quantity) * (discount_rate / 100), 2);


    UPDATE @temp_checkout_details
    SET
        sales_account_id                = inventory.get_sales_account_id(item_id),
        sales_discount_account_id       = inventory.get_sales_discount_account_id(item_id),
        inventory_account_id            = inventory.get_inventory_account_id(item_id),
        cost_of_ods_sold_account_id   = inventory.get_cost_of_ods_sold_account_id(item_id);

    DECLARE @item_quantities_temp TABLE
    (
        item_id             integer,
        base_unit_id        integer,
        store_id            integer,
        total_sales         numeric(24, 23),
        in_stock            numeric(24, 23),
        maintain_inventory      bit
    ) ;

    INSERT INTO @item_quantities_temp(item_id, base_unit_id, store_id, total_sales)
    SELECT item_id, base_unit_id, store_id, SUM(base_quantity)
    FROM @temp_checkout_details
    GROUP BY item_id, base_unit_id, store_id;

    UPDATE @item_quantities_temp
    SET maintain_inventory = inventory.items.maintain_inventory
    FROM inventory.items
    WHERE item_id = inventory.items.item_id;
    
    UPDATE @item_quantities_temp
    SET in_stock = inventory.count_item_in_stock(item_id, base_unit_id, store_id)
    WHERE maintain_inventory;


    IF EXISTS
    (
        SELECT TOP 1 0 FROM @item_quantities_temp
        WHERE total_sales > in_stock
        AND maintain_inventory        
    )
    BEGIN
        RAISERROR('Insufficient item quantity', 10, 1);
    END;
    
    IF EXISTS
    (
        SELECT TOP 1 0 FROM @temp_checkout_details AS details
        WHERE inventory.is_valid_unit_id(details.unit_id, details.item_id) = 0
    )
    BEGIN
        RAISERROR('Item/unit mismatch.', 10, 1);
    END;

    SELECT ROUND(SUM(COALESCE(discount, 0)), 2)                 INTO @discount_total FROM @temp_checkout_details;
    SELECT SUM(COALESCE(price, 0) * COALESCE(quantity, 0))      INTO @grand_total FROM @temp_checkout_details;
    SELECT SUM(COALESCE(shipping_charge, 0))                    INTO @shipping_charge FROM @temp_checkout_details;
    SELECT ROUND(SUM(COALESCE(tax, 0)), 2)                      INTO @tax_total FROM @temp_checkout_details;

     
     @receivable                    = COALESCE(@grand_total, 0) - COALESCE(@discount_total, 0) + COALESCE(@tax_total, 0) + COALESCE(@shipping_charge, 0);
        
    IF(@is_flat_discount AND @discount > @receivable)
    BEGIN
        RAISERROR('The discount amount cannot be greater than total amount.', 10, 1);
    END
    ELSE IF(NOT @is_flat_discount AND @discount > 100)
    BEGIN
        RAISERROR('The discount rate cannot be greater than 100.', 10, 1);
    END;

    @coupon_discount                = ROUND(@discount, 2);

    IF(NOT @is_flat_discount AND COALESCE(@discount, 0) > 0)
    BEGIN
        @coupon_discount            = ROUND(@receivable * (@discount/100), 2);
    END;

    IF(COALESCE(@coupon_discount, 0) > 0)
    BEGIN
        @discount_total             = @discount_total + @coupon_discount;
        @receivable                 = @receivable - @coupon_discount;
    END;

    IF(@tender > 0)
    BEGIN
        IF(@tender < @receivable )
        BEGIN
            RAISERROR('The tender amount must be greater than or equal to %s.', 10, 1, @receivable);
        END;
    END
    ELSE IF(@check_amount > 0)
    BEGIN
        IF(@check_amount < @receivable )
        BEGIN
            RAISERROR('The check amount must be greater than or equal to %s.', 10, 1, @receivable);
        END;
    END
    ELSE IF(COALESCE(@gift_card_number, '') != '')
    BEGIN
        IF(@gift_card_balance < @receivable )
        BEGIN
            RAISERROR('The gift card must have a balance of at least %s.', 10, 1, @receivable);
        END;
    END;
    
    DECLARE @temp_transaction_details
    (
        transaction_master_id       BIGINT, 
        tran_type                   national character varying(2), 
        account_id                  integer NOT NULL, 
        statement_reference         national character varying(2000), 
        cash_repository_id          integer, 
        currency_code               national character varying(12), 
        amount_in_currency          dbo.money_strict NOT NULL, 
        local_currency_code         national character varying(12), 
        er                          dbo.decimal_strict, 
        amount_in_local_currency    dbo.money_strict
    ) ;


    INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
    SELECT 'Cr', sales_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0)), 1, @default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0))
    FROM @temp_checkout_details
    GROUP BY sales_account_id;

    IF(NOT @is_periodic)
    BEGIN
        --Perpetutal Inventory Accounting System

        UPDATE @temp_checkout_details SET cost_of_ods_sold = inventory.get_cost_of_ods_sold(item_id, unit_id, store_id, quantity);
        
        SELECT SUM(cost_of_ods_sold) INTO @cost_of_ods
        FROM @temp_checkout_details;


        IF(@cost_of_ods > 0)
        BEGIN
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Dr', cost_of_ods_sold_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(cost_of_ods_sold, 0)), 1, @default_currency_code, SUM(COALESCE(cost_of_ods_sold, 0))
            FROM @temp_checkout_details
            GROUP BY cost_of_ods_sold_account_id;

            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Cr', inventory_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(cost_of_ods_sold, 0)), 1, @default_currency_code, SUM(COALESCE(cost_of_ods_sold, 0))
            FROM @temp_checkout_details
            GROUP BY inventory_account_id;
        END;
    END;

    IF(COALESCE(@tax_total, 0) > 0)
    BEGIN
        INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Cr', @tax_account_id, @statement_reference, @default_currency_code, @tax_total, 1, @default_currency_code, @tax_total;
    END;

    IF(COALESCE(@shipping_charge, 0) > 0)
    BEGIN
        INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Cr', inventory.get_account_id_by_shipper_id(@shipper_id), @statement_reference, @default_currency_code, @shipping_charge, 1, @default_currency_code, @shipping_charge;                
    END;


    IF(@discount_total > 0)
    BEGIN
        INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Dr', sales_discount_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(discount, 0)), 1, @default_currency_code, SUM(COALESCE(discount, 0))
        FROM @temp_checkout_details
        GROUP BY sales_discount_account_id
        HAVING SUM(COALESCE(discount, 0)) > 0;
    END;


    IF(@coupon_discount > 0)
    BEGIN
        SELECT inventory.inventory_setup.default_discount_account_id INTO @default_discount_account_id
        FROM inventory.inventory_setup
        WHERE inventory.inventory_setup.office_id = @office_id;

        INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Dr', @default_discount_account_id, @statement_reference, @default_currency_code, @coupon_discount, 1, @default_currency_code, @coupon_discount;
    END;



    INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
    SELECT 'Dr', inventory.get_account_id_by_customer_id(@customer_id), @statement_reference, @default_currency_code, @receivable, 1, @default_currency_code, @receivable;

    
    @transaction_master_id  = nextval(pg_get_integer IDENTITY_sequence('finance.transaction_master', 'transaction_master_id'));
    @checkout_id        = nextval(pg_get_integer IDENTITY_sequence('inventory.checkouts', 'checkout_id'));    
    @tran_counter           = finance.get_new_transaction_counter(@value_date);
    @transaction_code       = finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id);

    UPDATE @temp_transaction_details        SET transaction_master_id   = @transaction_master_id;
    UPDATE @temp_checkout_details           SET checkout_id             = @checkout_id;
    
    INSERT INTO finance.transaction_master(transaction_master_id, transaction_counter, transaction_code, book, value_date, book_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference) 
    SELECT @transaction_master_id, @tran_counter, @transaction_code, @book_name, @value_date, @book_date, @user_id, @login_id, @office_id, @cost_center_id, @reference_number, @statement_reference;


    INSERT INTO finance.transaction_details(value_date, book_date, office_id, transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency)
    SELECT @value_date, @book_date, @office_id, transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency
    FROM @temp_transaction_details
    ORDER BY tran_type DESC;

    INSERT INTO inventory.checkouts(transaction_book, value_date, book_date, checkout_id, transaction_master_id, shipper_id, posted_by, office_id, discount)
    SELECT @book_name, @value_date, @book_date, @checkout_id, @transaction_master_id, @shipper_id, @user_id, @office_id, @coupon_discount;

    FOR this IN SELECT * FROM @temp_checkout_details ORDER BY id
    LOOP
        @checkout_detail_id        = nextval(pg_get_integer IDENTITY_sequence('inventory.checkout_details', 'checkout_detail_id'));

        INSERT INTO inventory.checkout_details(checkout_detail_id, value_date, book_date, checkout_id, transaction_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, cost_of_ods_sold, discount, tax, shipping_charge)
        SELECT @checkout_detail_id, @value_date, @book_date, this.checkout_id, this.tran_type, this.store_id, this.item_id, this.quantity, this.unit_id, this.base_quantity, this.base_unit_id, this.price, COALESCE(this.cost_of_ods_sold, 0), this.discount, this.tax, this.shipping_charge 
        FROM @temp_checkout_details
        WHERE id = this.id;
    END LOOP;


    SELECT
        COALESCE(MAX(invoice_number), 0) + 1
    INTO
        @invoice_number
    FROM sales.sales
    WHERE sales.sales.fiscal_year_code = @fiscal_year_code;
    
    INSERT INTO sales.sales(fiscal_year_code, invoice_number, price_type_id, counter_id, total_amount, cash_repository_id, sales_order_id, sales_quotation_id, transaction_master_id, checkout_id, customer_id, salesperson_id, coupon_id, is_flat_discount, discount, total_discount_amount, is_credit, payment_term_id, tender, change, check_number, check_date, check_bank_name, check_amount, gift_card_id)
    SELECT @fiscal_year_code, @invoice_number, @price_type_id, @counter_id, @receivable, @cash_repository_id, @sales_order_id, @sales_quotation_id, @transaction_master_id, @checkout_id, @customer_id, @user_id, @coupon_id, @is_flat_discount, @discount, @discount_total, @is_credit, @payment_term_id, @tender, @change, @check_number, @check_date, @check_bank_name, @check_amount, @gift_card_id;
    
    EXECUTE finance.auto_verify @transaction_master_id, @office_id;

    IF(NOT @is_credit)
    BEGIN
        EXECUTE sales.post_receipt
            @user_id, 
            @office_id, 
            @login_id,
            @customer_id,
            @default_currency_code, 
            1.0, 
            1.0,
            @reference_number, 
            @statement_reference, 
            @cost_center_id,
            @cash_account_id,
            @cash_repository_id,
            @value_date,
            @book_date,
            @receivable,
            @tender,
            @change,
            @check_amount,
            @check_bank_name,
            @check_number,
            @check_date,
            @gift_card_number,
            @store_id,
            @transaction_master_id;
    END
    ELSE
        EXECUTE sales.settle_customer_due @customer_id, @office_id;
    END;

    SELECT @transaction_master_id;
END;




-- 
-- 
-- SELECT * FROM sales.post_sales
-- (
--     1, 1, 1, 1, finance.get_value_date(1), finance.get_value_date(1), 1, 'asdf', 'Test', 
--     500000,2000, null, null, null, null, null, null,
--     inventory.get_customer_id_by_customer_code('DEF'), 1, 1, 1,
--     null, 1, 1000,
--     ARRAY[
--     ROW(1, 'Cr', 1, 1, 1,180000, 0, 10, 0),
--     ROW(1, 'Cr', 2, 1, 7,130000, 0, 10, 0),
--     ROW(1, 'Cr', 3, 1, 1,110000, 0, 10, 0)],
--     NULL,
--     NULL
-- );
-- 


GO
