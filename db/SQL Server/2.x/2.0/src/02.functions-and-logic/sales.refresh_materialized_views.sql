IF OBJECT_ID('sales.refresh_materialized_views') IS NOT NULL
DROP PROCEDURE sales.refresh_materialized_views;

GO

CREATE PROCEDURE sales.refresh_materialized_views(@user_id integer, @login_id bigint, @office_id integer, @value_date date)
AS
BEGIN
    REFRESH MATERIALIZED VIEW finance.trial_balance_view;
    REFRESH MATERIALIZED VIEW inventory.verified_checkout_view;
    REFRESH MATERIALIZED VIEW finance.verified_transaction_mat_view;
    REFRESH MATERIALIZED VIEW finance.verified_cash_transaction_mat_view;
END;




--SELECT finance.create_routine('REF-MV', 'sales.refresh_materialized_views', 1000);

--SELECT * FROM sales.refresh_materialized_views(1, 1, 1, '1-1-2000')

GO
