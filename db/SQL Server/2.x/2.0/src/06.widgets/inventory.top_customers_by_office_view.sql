IF OBJECT_ID('inventory.top_customers_by_office_view') IS NOT NULL
DROP VIEW inventory.top_customers_by_office_view;

GO

CREATE VIEW inventory.top_customers_by_office_view
AS
SELECT TOP 5
    inventory.verified_checkout_view.office_id,
    inventory.customers.customer_id,
    CASE WHEN COALESCE(inventory.customers.customer_name, '') = ''
    THEN inventory.customers.company_name
    ELSE inventory.customers.customer_name
    END as customer,
    inventory.customers.company_country AS country,
    SUM(
        (inventory.verified_checkout_view.price * inventory.verified_checkout_view.quantity) 
        - inventory.verified_checkout_view.discount 
        + inventory.verified_checkout_view.tax) AS amount
FROM inventory.verified_checkout_view
INNER JOIN sales.sales
ON inventory.verified_checkout_view.checkout_id = sales.sales.checkout_id
INNER JOIN inventory.customers
ON sales.sales.customer_id = inventory.customers.customer_id
GROUP BY
inventory.verified_checkout_view.office_id,
inventory.customers.customer_id,
inventory.customers.customer_name,
inventory.customers.company_name,
inventory.customers.company_country
ORDER BY 2 DESC;
GO