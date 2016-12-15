IF OBJECT_ID('sales.post_check_receipt') IS NOT NULL
DROP PROCEDURE sales.post_check_receipt;

GO


CREATE PROCEDURE sales.post_check_receipt
(
    @user_id                                    integer, 
    @office_id                                  integer, 
    @login_id                                   bigint,
    @customer_id                                integer,
    @customer_account_id                        integer,
    @receivable_account_id                      integer,--sales.get_receivable_account_for_check_receipts(@store_id)
    @currency_code                              national character varying(12),
    @local_currency_code                        national character varying(12),
    @base_currency_code                         national character varying(12),
    @exchange_rate_debit                        dbo.decimal_strict, 
    @exchange_rate_credit                       dbo.decimal_strict,
    @reference_number                           national character varying(24), 
    @statement_reference                        national character varying(2000), 
    @cost_center_id                             integer,
    @value_date                                 date,
    @book_date                                  date,
    @check_amount                               dbo.money_strict2,
    @check_bank_name                            national character varying(1000),
    @check_number                               national character varying(100),
    @check_date                                 date,
    @cascading_tran_id                          bigint,
    @transaction_master_id                      bigint OUTPUT
)
AS
BEGIN            
    DECLARE @book                               national character varying(50) = 'Sales Receipt';
    DECLARE @debit                              dbo.money_strict2;
    DECLARE @credit                             dbo.money_strict2;
    DECLARE @lc_debit                           dbo.money_strict2;
    DECLARE @lc_credit                          dbo.money_strict2;

    DECLARE @can_post_transaction           bit;
    DECLARE @error_message                  national character varying(MAX);

    SELECT
        @can_post_transaction   = can_post_transaction,
        @error_message          = error_message
    FROM finance.can_post_transaction(@login_id, @user_id, @office_id, @book, @value_date);

    IF(@can_post_transaction = 0)
    BEGIN
        RAISERROR(@error_message, 10, 1);
        RETURN;
    END;

    SET @debit                                  = @check_amount;
    SET @lc_debit                               = @check_amount * @exchange_rate_debit;

    SET @credit                                 = @check_amount * (@exchange_rate_debit/ @exchange_rate_credit);
    SET @lc_credit                              = @check_amount * @exchange_rate_debit;
    
    INSERT INTO finance.transaction_master
    (
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

    SET @transaction_master_id = SCOPE_IDENTITY();


    --Debit
    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
    SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Dr', @receivable_account_id, @statement_reference, NULL, @currency_code, @debit, @local_currency_code, @exchange_rate_debit, @lc_debit, @user_id;        

    --Credit
    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
    SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Cr', @customer_account_id, @statement_reference, NULL, @base_currency_code, @credit, @local_currency_code, @exchange_rate_credit, @lc_credit, @user_id;
    
    
    INSERT INTO sales.customer_receipts(transaction_master_id, customer_id, currency_code, er_debit, er_credit, posted_date, check_amount, bank_name, check_number, check_date)
    SELECT @transaction_master_id, @customer_id, @currency_code, @exchange_rate_debit, @exchange_rate_credit, @value_date, @check_amount, @check_bank_name, @check_number, @check_date;

    SELECT @transaction_master_id;
END;


GO

--SELECT * FROM sales.post_check_receipt(1, 1, 1, 1, 1, 1, 'USD', 'USD', 'USD', 1, 1, '', '', 1, '1-1-2020', '1-1-2020', 2000, '', '', '1-1-2020', null);
