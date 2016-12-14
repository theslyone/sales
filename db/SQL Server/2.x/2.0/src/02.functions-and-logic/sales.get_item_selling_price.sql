IF OBJECT_ID('sales.get_item_selling_price') IS NOT NULL
DROP FUNCTION sales.get_item_selling_price;

GO

CREATE FUNCTION sales.get_item_selling_price(@item_id integer, @customer_type_id integer, @price_type_id integer, @unit_id integer)
RETURNS dbo.money_strict2
AS
BEGIN
    DECLARE @price              dbo.money_strict2;
    DECLARE @costing_unit_id    integer;
    DECLARE @factor             decimal;
    DECLARE @tax_rate           decimal;
    DECLARE @includes_tax       bit;
    DECLARE @tax                dbo.money_strict2;

    --Fist pick the catalog price which matches all these fields:
    --Item, Customer Type, Price Type, and Unit.
    --This is the most effective price.
    SELECT 
        item_selling_prices.price, 
        item_selling_prices.unit_id,
        item_selling_prices.includes_tax
    INTO 
        @price, 
        @costing_unit_id,
        @includes_tax       
    FROM sales.item_selling_prices
    WHERE item_selling_prices.item_id=_item_id
    AND item_selling_prices.customer_type_id=_customer_type_id
    AND item_selling_prices.price_type_id =_price_type_id
    AND item_selling_prices.unit_id = @unit_id
    AND sales.item_selling_prices.deleted = 0;

    IF(@costing_unit_id IS NULL)
    BEGIN
        --We do not have a selling price of this item for the unit supplied.
        --Let's see if this item has a price for other units.
        SELECT 
            item_selling_prices.price, 
            item_selling_prices.unit_id,
            item_selling_prices.includes_tax
        INTO 
            @price, 
            @costing_unit_id,
            @includes_tax
        FROM sales.item_selling_prices
        WHERE item_selling_prices.item_id=_item_id
        AND item_selling_prices.customer_type_id=_customer_type_id
        AND item_selling_prices.price_type_id =_price_type_id
        AND sales.item_selling_prices.deleted = 0;
    END;

    IF(@price IS NULL)
    BEGIN
        SELECT 
            item_selling_prices.price, 
            item_selling_prices.unit_id,
            item_selling_prices.includes_tax
        INTO 
            @price, 
            @costing_unit_id,
            @includes_tax
        FROM sales.item_selling_prices
        WHERE item_selling_prices.item_id=_item_id
        AND item_selling_prices.price_type_id =_price_type_id
        AND sales.item_selling_prices.deleted = 0;
    END;

    
    IF(@price IS NULL)
    BEGIN
        --This item does not have selling price defined in the catalog.
        --Therefore, getting the default selling price from the item definition.
        SELECT 
            selling_price, 
            unit_id,
            0
        INTO 
            @price, 
            @costing_unit_id,
            @includes_tax
        FROM inventory.items
        WHERE inventory.items.item_id = @item_id
        AND inventory.items.deleted = 0;
    END;

    IF(@includes_tax)
    BEGIN
        @tax_rate = core.get_item_tax_rate(@item_id);
        @price = @price / ((100 + @tax_rate)/ 100);
    END;

    --Get the unitary conversion factor if the requested unit does not match with the price defition.
    @factor = inventory.convert_unit(@unit_id, @costing_unit_id);

    RETURN @price * @factor;
END;




SELECT * FROM sales.get_item_selling_price(1, 1, 1, 1);


GO
