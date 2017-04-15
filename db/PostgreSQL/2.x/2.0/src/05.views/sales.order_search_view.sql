DROP VIEW IF EXISTS sales.order_search_view;

CREATE VIEW sales.order_search_view
AS
SELECT
	sales.orders.order_id,
	inventory.get_customer_name_by_customer_id(sales.orders.customer_id) AS customer,
	SUM(

        ROUND
		(
			(
			(sales.order_details.price * sales.order_details.quantity)
			* ((100 - sales.order_details.discount_rate)/100)) 
		, 4)  + sales.order_details.tax		
	) AS total_amount,
	sales.orders.value_date,
	sales.orders.expected_delivery_date AS expected_date,
	COALESCE(sales.orders.reference_number, '') AS reference_number,
	COALESCE(sales.orders.terms, '') AS terms,
	COALESCE(sales.orders.internal_memo, '') AS memo,
	account.get_name_by_user_id(sales.orders.user_id) AS posted_by,
	core.get_office_name_by_office_id(sales.orders.office_id) AS office,
	sales.orders.transaction_timestamp AS posted_on,
	sales.orders.office_id
FROM sales.orders
INNER JOIN sales.order_details
ON sales.orders.order_id = sales.order_details.order_id
GROUP BY
	sales.orders.order_id,
	sales.orders.customer_id,
	sales.orders.value_date,
	sales.orders.expected_delivery_date,
	sales.orders.reference_number,
	sales.orders.terms,
	sales.orders.internal_memo,
	sales.orders.user_id,
	sales.orders.transaction_timestamp,
	sales.orders.office_id
ORDER BY sales.orders.order_id;

