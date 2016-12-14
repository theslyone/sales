IF OBJECT_ID('sales.post_cash_receipt') IS NOT NULL
DROP PROCEDURE sales.post_cash_receipt;

GO

CREATE PROCEDURE sales.post_cash_receipt
(
    @user_id                                    integer, 
    @office_id                                  integer, 
    @login_id                                   bigint,
    @customer_id                                integer,
    @customer_account_id                        integer,
    @currency_code                              national character varying(12),
    @local_currency_code                        national character varying(12),
    @base_currency_code                         national character varying(12),
    @exchange_rate_debit                        dbo.decimal_strict, 
    @exchange_rate_credit                       dbo.decimal_strict,
    @reference_number                           national character varying(24), 
    @statement_reference                        national character varying(2000), 
    @cost_center_id                             integer,
    @cash_account_id                            integer,
    @cash_repository_id                         integer,
    @value_date                                 date,
    @book_date                                  date,
    @receivable                                 dbo.money_strict2,
    @tender                                     dbo.money_strict2,
    @change                                     dbo.money_strict2,
    @cascading_tran_id                          bigint
)
AS
BEGIN
    DECLARE @book                               national character varying(50) = 'Sales Receipt';
    DECLARE @transaction_master_id              bigint;
    DECLARE @debit                              dbo.money_strict2;
    DECLARE @credit                             dbo.money_strict2;
    DECLARE @lc_debit                           dbo.money_strict2;
    DECLARE @lc_credit                          dbo.money_strict2;

    IF NOT finance.can_post_transaction(@login_id, @user_id, @office_id, @book, @value_date)
    BEGIN
        RETURN 0;
    END;

    IF(@tender < @receivable)
    BEGIN
        RAISERROR('The tendered amount must be greater than or equal to sales amount', 10, 1);
    END;
    
    @debit                                  = @receivable;
    @lc_debit                               = @receivable * @exchange_rate_debit;

    @credit                                 = @receivable * (@exchange_rate_debit/ @exchange_rate_credit);
    @lc_credit                              = @receivable * @exchange_rate_debit;
    
    INSERT INTO finance.transaction_master
    (
        transaction_master_id, 
        transaction_counter, 
        transaction_code, 
        book, 
        value_date, 
        book_date,
        user_id, 
        login_id, 
        office_id, 
        cost_center_id, 
        reference_number, 
        statement_reference,
        audit_user_id,
        cascading_tran_id
    )
    SELECT 
        nextval(pg_get_integer IDENTITY_sequence('finance.transaction_master', 'transaction_master_id')), 
        finance.get_new_transaction_counter(@value_date), 
        finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id),
        @book,
        @value_date,
        @book_date,
        @user_id,
        @login_id,
        @office_id,
        @cost_center_id,
        @reference_number,
        @statement_reference,
        @user_id,
        @cascading_tran_id;


    @transaction_master_id = currval(pg_get_integer IDENTITY_sequence('finance.transaction_master', 'transaction_master_id'));

    --Debit
    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
    SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Dr', @cash_account_id, @statement_reference, @cash_repository_id, @currency_code, @debit, @local_currency_code, @exchange_rate_debit, @lc_debit, @user_id;

    --Credit
    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date,  book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
    SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Cr', @customer_account_id, @statement_reference, NULL, @base_currency_code, @credit, @local_currency_code, @exchange_rate_credit, @lc_credit, @user_id;
    
    
    INSERT INTO sales.customer_receipts(transaction_master_id, customer_id, currency_code, er_debit, er_credit, cash_repository_id, posted_date, tender, change)
    SELECT @transaction_master_id, @customer_id, @currency_code, @exchange_rate_debit, @exchange_rate_credit, @cash_repository_id, @value_date, @tender, @change;

    SELECT @transaction_master_id;
END;



--SELECT * FROM sales.post_cash_receipt(1, 1, 1, 1, 1, 'USD', 'USD', 'USD', 1, 1, '', '', 1, 1, 1, '1-1-2020', '1-1-2020', 2000, 0, NULL);

GO
