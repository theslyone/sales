IF OBJECT_ID('sales.quotation_search_view') IS NOT NULL
DROP VIEW sales.quotation_search_view;

GO

CREATE VIEW sales.quotation_search_view
AS
SELECT
	sales.quotations.quotation_id,
	inventory.get_customer_name_by_customer_id(sales.quotations.customer_id) AS customer,
	SUM(

        ROUND
		(
			(
			(sales.quotation_details.price * sales.quotation_details.quantity)
			* ((100 - sales.quotation_details.discount_rate)/100)) 
		, 4)  + sales.quotation_details.tax		
	) AS total_amount,
	sales.quotations.value_date,
	sales.quotations.expected_delivery_date AS expected_date,
	COALESCE(sales.quotations.reference_number, '') AS reference_number,
	COALESCE(sales.quotations.terms, '') AS terms,
	COALESCE(sales.quotations.internal_memo, '') AS memo,
	account.get_name_by_user_id(sales.quotations.user_id) AS posted_by,
	core.get_office_name_by_office_id(sales.quotations.office_id) AS office,
	sales.quotations.transaction_timestamp AS posted_on,
	sales.quotations.office_id
FROM sales.quotations
INNER JOIN sales.quotation_details
ON sales.quotations.quotation_id = sales.quotation_details.quotation_id
GROUP BY
	sales.quotations.quotation_id,
	sales.quotations.customer_id,
	sales.quotations.value_date,
	sales.quotations.expected_delivery_date,
	sales.quotations.reference_number,
	sales.quotations.terms,
	sales.quotations.internal_memo,
	sales.quotations.user_id,
	sales.quotations.transaction_timestamp,
	sales.quotations.office_id;

GO

