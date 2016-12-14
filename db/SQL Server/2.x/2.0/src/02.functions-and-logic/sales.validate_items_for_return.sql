IF OBJECT_ID('sales.validate_items_for_return') IS NOT NULL
DROP FUNCTION sales.validate_items_for_return;

GO

CREATE FUNCTION sales.validate_items_for_return
(
    @transaction_master_id                  bigint, 
    @details                                sales.sales_detail_type
)
RETURNS bit
AS
BEGIN        
    DECLARE @checkout_id                    bigint = 0;
    DECLARE @is_purchase                    bit = 0;
    DECLARE @item_id                        integer = 0;
    DECLARE @factor_to_base_unit            numeric(24, 4);
    DECLARE @returned_in_previous_batch     dbo.decimal_strict2 = 0;
    DECLARE @in_verification_queue          dbo.decimal_strict2 = 0;
    DECLARE @actual_price_in_root_unit      dbo.money_strict2 = 0;
    DECLARE @price_in_root_unit             dbo.money_strict2 = 0;
    DECLARE @item_in_stock                  dbo.decimal_strict2 = 0;
    DECLARE @error_item_id                  integer;
    DECLARE @error_quantity                 decimal;
    DECLARE @error_amount                   decimal;
    DECLARE this                            RECORD; 

    @checkout_id                            = inventory.get_checkout_id_by_transaction_master_id(@transaction_master_id);

    DECLARE @details_temp TABLE
    (
        store_id            integer,
        item_id             integer,
        item_in_stock       numeric(24, 4),
        quantity            dbo.decimal_strict,        
        unit_id             integer,
        price               dbo.money_strict,
        discount_rate       dbo.decimal_strict2,
        tax                 dbo.money_strict2,
        shipping_charge     dbo.money_strict2,
        root_unit_id        integer,
        base_quantity       numeric(24, 4)
    ) ;

    INSERT INTO @details_temp(store_id, item_id, quantity, unit_id, price, discount_rate, tax, shipping_charge)
    SELECT store_id, item_id, quantity, unit_id, price, discount_rate, tax, shipping_charge
    FROM @details;

    UPDATE @details_temp
    SET 
        item_in_stock = inventory.count_item_in_stock(item_id, unit_id, store_id);
       
    UPDATE @details_temp
    SET root_unit_id = inventory.get_root_unit_id(unit_id);

    UPDATE @details_temp
    SET base_quantity = inventory.convert_unit(unit_id, root_unit_id) * quantity;


    --Determine whether the quantity of the returned item(s) is less than or equal to the same on the actual transaction
    DECLARE @item_summary TABLE
    (
        store_id                    integer,
        item_id                     integer,
        root_unit_id                integer,
        returned_quantity           numeric(24, 4),
        actual_quantity             numeric(24, 4),
        returned_in_previous_batch  numeric(24, 4),
        in_verification_queue       numeric(24, 4)
    ) ;
    
    INSERT INTO @item_summary(store_id, item_id, root_unit_id, returned_quantity)
    SELECT
        store_id,
        item_id,
        root_unit_id, 
        SUM(base_quantity)
    FROM @details_temp
    GROUP BY 
        store_id, 
        item_id,
        root_unit_id;

    UPDATE @item_summary
    SET actual_quantity = 
    (
        SELECT SUM(base_quantity)
        FROM inventory.checkout_details
        WHERE inventory.checkout_details.checkout_id = @checkout_id
        AND inventory.checkout_details.item_id = @item_summary.item_id
    );

    UPDATE @item_summary
    SET returned_in_previous_batch = 
    (
        SELECT 
            COALESCE(SUM(base_quantity), 0)
        FROM inventory.checkout_details
        WHERE checkout_id IN
        (
            SELECT checkout_id
            FROM inventory.checkouts
            INNER JOIN finance.transaction_master
            ON finance.transaction_master.transaction_master_id = inventory.checkouts.transaction_master_id
            WHERE finance.transaction_master.verification_status_id > 0
            AND inventory.checkouts.transaction_master_id IN 
            (
                SELECT 
                    return_transaction_master_id 
                FROM sales.returns
                WHERE transaction_master_id = @transaction_master_id
            )
        )
        AND item_id = @item_summary.item_id
    );

    UPDATE @item_summary
    SET in_verification_queue =
    (
        SELECT 
            COALESCE(SUM(base_quantity), 0)
        FROM inventory.checkout_details
        WHERE checkout_id IN
        (
            SELECT checkout_id
            FROM inventory.checkouts
            INNER JOIN finance.transaction_master
            ON finance.transaction_master.transaction_master_id = inventory.checkouts.transaction_master_id
            WHERE finance.transaction_master.verification_status_id = 0
            AND inventory.checkouts.transaction_master_id IN 
            (
                SELECT 
                return_transaction_master_id 
                FROM sales.returns
                WHERE transaction_master_id = @transaction_master_id
            )
        )
        AND item_id = @item_summary.item_id
    );
    
    --Determine whether the price of the returned item(s) is less than or equal to the same on the actual transaction
    DECLARE @cumulative_pricing TABLE
    (
        item_id                     integer,
        base_price                  numeric(24, 4),
        allowed_returns             numeric(24, 4)
    ) ;

    INSERT INTO @cumulative_pricing
    SELECT 
        item_id,
        MIN(price  / base_quantity * quantity) as base_price,
        SUM(base_quantity) OVER(ORDER BY item_id, base_quantity) as allowed_returns
    FROM inventory.checkout_details 
    WHERE checkout_id = @checkout_id
    GROUP BY item_id, base_quantity;

    IF EXISTS(SELECT 0 FROM @details_temp WHERE store_id IS NULL OR store_id <= 0)
    BEGIN
        RAISERROR('Invalid store.', 10, 1);
    END;    

    IF EXISTS(SELECT 0 FROM @details_temp WHERE item_id IS NULL OR item_id <= 0)
    BEGIN
        RAISERROR('Invalid item.', 10, 1);
    END;

    IF EXISTS(SELECT 0 FROM @details_temp WHERE unit_id IS NULL OR unit_id <= 0)
    BEGIN
        RAISERROR('Invalid unit.', 10, 1);
    END;

    IF EXISTS(SELECT 0 FROM @details_temp WHERE quantity IS NULL OR quantity <= 0)
    BEGIN
        RAISERROR('Invalid quantity.', 10, 1)
    END;

    IF(@checkout_id  IS NULL OR @checkout_id  <= 0)
    BEGIN
        RAISERROR('Invalid transaction id.', 10, 1);
    END;

    IF NOT EXISTS
    (
        SELECT * FROM finance.transaction_master
        WHERE transaction_master_id = @transaction_master_id
        AND verification_status_id > 0
    )
    BEGIN
        RAISERROR('Invalid or rejected transaction.', 10, 1);
    END;
        
    SELECT item_id INTO @item_id
    FROM @details_temp
    WHERE item_id NOT IN
    (
        SELECT TOP 1 item_id FROM inventory.checkout_details
        WHERE checkout_id = @checkout_id
    );

    IF(COALESCE(@item_id, 0) != 0)
    BEGIN
        RAISERROR('The item %s is not associated with this transaction.', 10, 1, inventory.get_item_name_by_item_id(@item_id));
    END;


    IF NOT EXISTS
    (
        SELECT TOP 1 0 FROM inventory.checkout_details
        INNER JOIN @details_temp AS details_temp
        ON inventory.checkout_details.item_id = details_temp.item_id
        WHERE checkout_id = @checkout_id
        AND inventory.get_root_unit_id(details_temp.unit_id) = inventory.get_root_unit_id(inventory.checkout_details.unit_id)
    )
    BEGIN
        RAISERROR('Invalid or incompatible unit specified.', 10, 1);
    END;

    SELECT TOP 1
        @error_item_id = item_id,
        @error_quantity = returned_quantity        
    FROM @item_summary
    WHERE returned_quantity + returned_in_previous_batch + in_verification_queue > actual_quantity;

    IF(@error_item_id IS NOT NULL)
    BEGIN    
        RAISERROR('The returned quantity (%s) of %s is greater than actual quantity.', 10, 1, @error_quantity, inventory.get_item_name_by_item_id(@error_item_id));
    END;

    FOR this IN
    SELECT item_id, base_quantity, CAST((price / base_quantity * quantity) AS numeric(24, 4)) as price
    FROM @details_temp
    LOOP
        SELECT TOP 1
            @error_item_id = item_id,
            @error_amount = base_price
        FROM @cumulative_pricing
        WHERE item_id = this.item_id
        AND base_price <  this.price
        AND allowed_returns >= this.base_quantity;
        
        IF (@error_item_id IS NOT NULL)
        BEGIN
            RAISERROR('The returned base amount %s of %s cannot be greater than actual amount %s.', 10, 1, this.price, inventory.get_item_name_by_item_id(@error_item_id), @error_amount);
        END;
    END LOOP;
    
    RETURN 1;
END;



-- SELECT * FROM sales.validate_items_for_return
-- (
--     6,
--     ARRAY[
--         ROW(1, 'Dr', 1, 1, 1,180000, 0, 200),
--         ROW(1, 'Dr', 2, 1, 7,130000, 300, 30),
--         ROW(1, 'Dr', 3, 1, 1,110000, 5000, 50)
--     ]
-- );
-- 


GO
