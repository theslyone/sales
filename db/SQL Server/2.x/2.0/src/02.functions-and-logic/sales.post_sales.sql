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
    @tender                                 decimal(30, 6),
    @change                                 decimal(30, 6),
    @payment_term_id                        integer,
    @check_amount                           decimal(30, 6),
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
    @discount                               decimal(30, 6),
    @details                                sales.sales_detail_type READONLY,
    @sales_quotation_id                     bigint,
    @sales_order_id                         bigint,
    @transaction_master_id                  bigint OUTPUT
)
AS
BEGIN        
    DECLARE @book_name                      national character varying(48) = 'Sales Entry';
    DECLARE @checkout_id                    bigint;
    DECLARE @grand_total                    decimal(30, 6);
    DECLARE @discount_total                 decimal(30, 6);
    DECLARE @receivable                     decimal(30, 6);
    DECLARE @default_currency_code          national character varying(12);
    DECLARE @is_periodic                    bit = inventory.is_periodic_inventory(@office_id);
    DECLARE @cost_of_goods                    decimal(30, 6);
    DECLARE @tran_counter                   integer;
    DECLARE @transaction_code               national character varying(50);
    DECLARE @tax_total                      decimal(30, 6);
    DECLARE @shipping_charge                decimal(30, 6);
    DECLARE @cash_repository_id             integer;
    DECLARE @cash_account_id                integer;
    DECLARE @is_cash                        bit = 0;
    DECLARE @is_credit                      bit = 0;
    DECLARE @gift_card_id                   integer;
    DECLARE @gift_card_balance              numeric(30, 6);
    DECLARE @coupon_id                      integer;
    DECLARE @coupon_discount                numeric(30, 6); 
    DECLARE @default_discount_account_id    integer;
    DECLARE @fiscal_year_code               national character varying(12);
    DECLARE @invoice_number                 bigint;
    DECLARE @tax_account_id                 integer;

    DECLARE @total_rows                     integer = 0;
    DECLARE @counter                        integer = 0;
    DECLARE @loop_id                        integer;
    DECLARE @loop_checkout_id               bigint
    DECLARE @loop_tran_type                 national character varying(2)
    DECLARE @loop_store_id                  integer;
    DECLARE @loop_item_id                   integer;
    DECLARE @loop_quantity                  decimal(30, 6);
    DECLARE @loop_unit_id                   integer;
    DECLARE @loop_base_quantity             decimal(30, 6);
    DECLARE @loop_base_unit_id              integer;
    DECLARE @loop_price                     decimal(30, 6);
    DECLARE @loop_cost_of_goods_sold        decimal(30, 6);
    DECLARE @loop_discount                  decimal(30, 6);
    DECLARE @loop_tax                       decimal(30, 6);
    DECLARE @loop_shipping_charge           decimal(30, 6);


    DECLARE @can_post_transaction           bit;
    DECLARE @error_message                  national character varying(MAX);

    SELECT
        @can_post_transaction   = can_post_transaction,
        @error_message          = error_message
    FROM finance.can_post_transaction(@login_id, @user_id, @office_id, @book_name, @value_date);

    IF(@can_post_transaction = 0)
    BEGIN
        RAISERROR(@error_message, 10, 1);
        RETURN;
    END;

    SET @tax_account_id                         = finance.get_sales_tax_account_id_by_office_id(@office_id);
    SET @default_currency_code                  = core.get_currency_code_by_office_id(@office_id);
    SET @cash_account_id                        = inventory.get_cash_account_id_by_store_id(@store_id);
    SET @cash_repository_id                     = inventory.get_cash_repository_id_by_store_id(@store_id);
    SET @is_cash                                = finance.is_cash_account_id(@cash_account_id);    

    SET @coupon_id                              = sales.get_active_coupon_id_by_coupon_code(@coupon_code);
    SET @gift_card_id                           = sales.get_gift_card_id_by_gift_card_number(@gift_card_number);
    SET @gift_card_balance                      = sales.get_gift_card_balance(@gift_card_id, @value_date);


    SELECT TOP 1 @fiscal_year_code = finance.fiscal_year.fiscal_year_code
    FROM finance.fiscal_year
    WHERE @value_date BETWEEN finance.fiscal_year.starts_from AND finance.fiscal_year.ends_on;

    IF(COALESCE(@customer_id, 0) = 0)
    BEGIN
        RAISERROR('Please select a customer.', 10, 1);
    END;

    IF(COALESCE(@coupon_code, '') != '' AND COALESCE(@discount, 0) > 0)
    BEGIN
        RAISERROR('Please do not specify discount rate when you mention coupon code.', 10, 1);
    END;
    --TODO: VALIDATE COUPON CODE AND POST DISCOUNT

    IF(COALESCE(@payment_term_id, 0) > 0)
    BEGIN
        SET @is_credit                          = 1;
    END;

    IF(@is_credit = 0 AND @is_cash = 0)
    BEGIN
        RAISERROR('Cannot post sales. Invalid cash account mapping on store.', 10, 1);
    END;

   
    IF(@is_cash = 0)
    BEGIN
        SET @cash_repository_id                 = NULL;
    END;

    DECLARE @checkout_details TABLE
    (
        id                              integer IDENTITY PRIMARY KEY,
        checkout_id                     bigint, 
        tran_type                       national character varying(2), 
        store_id                        integer,
        item_id                         integer, 
        quantity                        decimal(30, 6),        
        unit_id                         integer,
        base_quantity                   decimal(30, 6),
        base_unit_id                    integer,                
        price                           decimal(30, 6),
        cost_of_goods_sold              decimal(30, 6) DEFAULT(0),
        discount_rate                   decimal(30, 6),
        discount                        decimal(30, 6),
        tax                             decimal(30, 6),
        shipping_charge                 decimal(30, 6),
        sales_account_id                integer,
        sales_discount_account_id       integer,
        inventory_account_id            integer,
        cost_of_goods_sold_account_id   integer
    ) ;

    INSERT INTO @checkout_details(store_id, item_id, quantity, unit_id, price, discount_rate, tax, shipping_charge)
    SELECT store_id, item_id, quantity, unit_id, price, discount_rate, tax, shipping_charge
    FROM @details;

    
    UPDATE @checkout_details 
    SET
        tran_type                       = 'Cr',
        base_quantity                   = inventory.get_base_quantity_by_unit_id(unit_id, quantity),
        base_unit_id                    = inventory.get_root_unit_id(unit_id),
        discount                        = ROUND((price * quantity) * (discount_rate / 100), 2);


    UPDATE @checkout_details
    SET
        sales_account_id                = inventory.get_sales_account_id(item_id),
        sales_discount_account_id       = inventory.get_sales_discount_account_id(item_id),
        inventory_account_id            = inventory.get_inventory_account_id(item_id),
        cost_of_goods_sold_account_id   = inventory.get_cost_of_goods_sold_account_id(item_id);

    DECLARE @item_quantities TABLE
    (
        item_id             integer,
        base_unit_id        integer,
        store_id            integer,
        total_sales         numeric(30, 6),
        in_stock            numeric(30, 6),
        maintain_inventory      bit
    ) ;

    INSERT INTO @item_quantities(item_id, base_unit_id, store_id, total_sales)
    SELECT item_id, base_unit_id, store_id, SUM(base_quantity)
    FROM @checkout_details
    GROUP BY item_id, base_unit_id, store_id;

    UPDATE @item_quantities
    SET maintain_inventory = inventory.items.maintain_inventory
    FROM @item_quantities AS item_quantities 
    INNER JOIN inventory.items
    ON item_quantities.item_id = inventory.items.item_id;
    
    UPDATE @item_quantities
    SET in_stock = inventory.count_item_in_stock(item_id, base_unit_id, store_id)
    WHERE maintain_inventory = 1;


    IF EXISTS
    (
        SELECT TOP 1 0 FROM @item_quantities
        WHERE total_sales > in_stock
        AND maintain_inventory = 1     
    )
    BEGIN
        RAISERROR('Insufficient item quantity', 10, 1);
    END;
    
    IF EXISTS
    (
        SELECT TOP 1 0 FROM @checkout_details AS details
        WHERE inventory.is_valid_unit_id(details.unit_id, details.item_id) = 0
    )
    BEGIN
        RAISERROR('Item/unit mismatch.', 10, 1);
    END;

    SELECT @discount_total  = ROUND(SUM(COALESCE(discount, 0)), 2) FROM @checkout_details;
    SELECT @grand_total     = SUM(COALESCE(price, 0) * COALESCE(quantity, 0)) FROM @checkout_details;
    SELECT @shipping_charge = SUM(COALESCE(shipping_charge, 0)) FROM @checkout_details;
    SELECT @tax_total       = ROUND(SUM(COALESCE(tax, 0)), 2) FROM @checkout_details;

     
    SET @receivable         = COALESCE(@grand_total, 0) - COALESCE(@discount_total, 0) + COALESCE(@tax_total, 0) + COALESCE(@shipping_charge, 0);
        
    IF(@is_flat_discount = 1 AND @discount > @receivable)
    BEGIN
        RAISERROR('The discount amount cannot be greater than total amount.', 10, 1);
    END
    ELSE IF(@is_flat_discount = 0 AND @discount > 100)
    BEGIN
        RAISERROR('The discount rate cannot be greater than 100.', 10, 1);
    END;

    SET @coupon_discount                = ROUND(@discount, 2);

    IF(@is_flat_discount = 0 AND COALESCE(@discount, 0) > 0)
    BEGIN
        SET @coupon_discount            = ROUND(@receivable * (@discount/100), 2);
    END;

    IF(COALESCE(@coupon_discount, 0) > 0)
    BEGIN
        SET @discount_total             = @discount_total + @coupon_discount;
        SET @receivable                 = @receivable - @coupon_discount;
    END;

    IF(@tender > 0)
    BEGIN
        IF(@tender < @receivable)
        BEGIN
            SET @error_message = FORMATMESSAGE('The tender amount must be greater than or equal to %s.', CAST(@receivable AS varchar(30)));
            RAISERROR(@error_message, 10, 1);
        END;
    END
    ELSE IF(@check_amount > 0)
    BEGIN
        IF(@check_amount < @receivable )
        BEGIN
            SET @error_message = FORMATMESSAGE('The check amount must be greater than or equal to %s.', CAST(@receivable AS varchar(30)));
            RAISERROR(@error_message, 10, 1);
        END;
    END
    ELSE IF(COALESCE(@gift_card_number, '') != '')
    BEGIN
        IF(@gift_card_balance < @receivable )
        BEGIN
            SET @error_message = FORMATMESSAGE('The gift card must have a balance of at least %s.', CAST(@receivable AS varchar(30)));
            RAISERROR(@error_message, 10, 1);
        END;
    END;
    
    DECLARE @temp_transaction_details TABLE
    (
        transaction_master_id       BIGINT, 
        tran_type                   national character varying(2), 
        account_id                  integer NOT NULL, 
        statement_reference         national character varying(2000), 
        cash_repository_id          integer, 
        currency_code               national character varying(12), 
        amount_in_currency          decimal(30, 6) NOT NULL, 
        local_currency_code         national character varying(12), 
        er                          decimal(30, 6), 
        amount_in_local_currency    decimal(30, 6)
    ) ;


    INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
    SELECT 'Cr', sales_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0)), 1, @default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0))
    FROM @checkout_details
    GROUP BY sales_account_id;

    IF(@is_periodic = 0)
    BEGIN
        --Perpetutal Inventory Accounting System

        UPDATE @checkout_details SET cost_of_goods_sold = inventory.get_cost_of_goods_sold(item_id, unit_id, store_id, quantity);
        
        SELECT @cost_of_goods = SUM(cost_of_goods_sold)
        FROM @checkout_details;


        IF(@cost_of_goods > 0)
        BEGIN
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Dr', cost_of_goods_sold_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
            FROM @checkout_details
            GROUP BY cost_of_goods_sold_account_id;

            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Cr', inventory_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
            FROM @checkout_details
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
        FROM @checkout_details
        GROUP BY sales_discount_account_id
        HAVING SUM(COALESCE(discount, 0)) > 0;
    END;


    IF(@coupon_discount > 0)
    BEGIN
        SELECT @default_discount_account_id = inventory.inventory_setup.default_discount_account_id
        FROM inventory.inventory_setup
        WHERE inventory.inventory_setup.office_id = @office_id;

        INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Dr', @default_discount_account_id, @statement_reference, @default_currency_code, @coupon_discount, 1, @default_currency_code, @coupon_discount;
    END;



    INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
    SELECT 'Dr', inventory.get_account_id_by_customer_id(@customer_id), @statement_reference, @default_currency_code, @receivable, 1, @default_currency_code, @receivable;

    
    SET @tran_counter           = finance.get_new_transaction_counter(@value_date);
    SET @transaction_code       = finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id);

    
    INSERT INTO finance.transaction_master(transaction_counter, transaction_code, book, value_date, book_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference) 
    SELECT @tran_counter, @transaction_code, @book_name, @value_date, @book_date, @user_id, @login_id, @office_id, @cost_center_id, @reference_number, @statement_reference;
    SET @transaction_master_id  = SCOPE_IDENTITY();
    UPDATE @temp_transaction_details        SET transaction_master_id   = @transaction_master_id;


    INSERT INTO finance.transaction_details(value_date, book_date, office_id, transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency)
    SELECT @value_date, @book_date, @office_id, transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency
    FROM @temp_transaction_details
    ORDER BY tran_type DESC;


    INSERT INTO inventory.checkouts(transaction_book, value_date, book_date, transaction_master_id, shipper_id, posted_by, office_id, discount)
    SELECT @book_name, @value_date, @book_date, @transaction_master_id, @shipper_id, @user_id, @office_id, @coupon_discount;

    SET @checkout_id              = SCOPE_IDENTITY();    
    
    UPDATE @checkout_details
    SET checkout_id             = @checkout_id;

    SELECT @total_rows=MAX(id) FROM @checkout_details;

    WHILE @counter<@total_rows
    BEGIN
        SELECT TOP 1 
            @loop_id                    = id,
            @loop_checkout_id           = checkout_id,
            @loop_tran_type             = tran_type,
            @loop_store_id              = store_id,
            @loop_item_id               = item_id,
            @loop_quantity              = quantity,
            @loop_unit_id               = unit_id,
            @loop_base_quantity         = base_quantity,
            @loop_base_unit_id          = base_unit_id,
            @loop_price                 = price,
            @loop_cost_of_goods_sold    = cost_of_goods_sold,
            @loop_discount              = discount,
            @loop_tax                   = tax,
            @loop_shipping_charge       = shipping_charge
        FROM @checkout_details
        WHERE id >= @counter
        ORDER BY id;

        IF(@loop_id IS NOT NULL)
        BEGIN
            SET @counter = @loop_id + 1;        
        END
        ELSE
        BEGIN
            BREAK;
        END;

        INSERT INTO inventory.checkout_details(value_date, book_date, checkout_id, transaction_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, cost_of_goods_sold, discount, tax, shipping_charge)
        SELECT @value_date, @book_date, @loop_checkout_id, @loop_tran_type, @loop_store_id, @loop_item_id, @loop_quantity, @loop_unit_id, @loop_base_quantity, @loop_base_unit_id, @loop_price, COALESCE(@loop_cost_of_goods_sold, 0), @loop_discount, @loop_tax, @loop_shipping_charge 
        FROM @checkout_details
        WHERE id = @loop_id;
    END;


    SELECT @invoice_number = COALESCE(MAX(invoice_number), 0) + 1
    FROM sales.sales
    WHERE sales.sales.fiscal_year_code = @fiscal_year_code;
    
    INSERT INTO sales.sales(fiscal_year_code, invoice_number, price_type_id, counter_id, total_amount, cash_repository_id, sales_order_id, sales_quotation_id, transaction_master_id, checkout_id, customer_id, salesperson_id, coupon_id, is_flat_discount, discount, total_discount_amount, is_credit, payment_term_id, tender, change, check_number, check_date, check_bank_name, check_amount, gift_card_id)
    SELECT @fiscal_year_code, @invoice_number, @price_type_id, @counter_id, @receivable, @cash_repository_id, @sales_order_id, @sales_quotation_id, @transaction_master_id, @checkout_id, @customer_id, @user_id, @coupon_id, @is_flat_discount, @discount, @discount_total, @is_credit, @payment_term_id, @tender, @change, @check_number, @check_date, @check_bank_name, @check_amount, @gift_card_id;
    
    EXECUTE finance.auto_verify @transaction_master_id, @office_id;

    IF(@is_credit = 0)
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
    BEGIN
        EXECUTE sales.settle_customer_due @customer_id, @office_id;
    END;

    SELECT @transaction_master_id;
END;

GO
