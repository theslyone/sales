IF OBJECT_ID('sales.post_receipt_by_gift_card') IS NOT NULL
DROP PROCEDURE sales.post_receipt_by_gift_card;

GO

CREATE PROCEDURE sales.post_receipt_by_gift_card
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
    @value_date                                 date,
    @book_date                                  date,
    @gift_card_id                               integer,
    @gift_card_number                           national character varying(100),
    @amount                                     dbo.money_strict,
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
    DECLARE @is_cash                            bit;
    DECLARE @gift_card_payable_account_id       integer;

    IF NOT finance.can_post_transaction(@login_id, @user_id, @office_id, @book, @value_date)
    BEGIN
        RETURN 0;
    END;

    @gift_card_payable_account_id           = sales.get_payable_account_for_gift_card(@gift_card_id);
    @debit                                  = @amount;
    @lc_debit                               = @amount * @exchange_rate_debit;

    @credit                                 = @amount * (@exchange_rate_debit/ @exchange_rate_credit);
    @lc_credit                              = @amount * @exchange_rate_debit;
    
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
    SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Dr', @gift_card_payable_account_id, @statement_reference, NULL, @currency_code, @debit, @local_currency_code, @exchange_rate_debit, @lc_debit, @user_id;        

    --Credit
    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
    SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Cr', @customer_account_id, @statement_reference, NULL, @base_currency_code, @credit, @local_currency_code, @exchange_rate_credit, @lc_credit, @user_id;
    
    
    INSERT INTO sales.customer_receipts(transaction_master_id, customer_id, currency_code, er_debit, er_credit, posted_date, gift_card_number)
    SELECT @transaction_master_id, @customer_id, @currency_code, @exchange_rate_debit, @exchange_rate_credit, @value_date, @gift_card_number;

    SELECT @transaction_master_id;
END;



--select * from sales.post_receipt_by_gift_card(1,1, 1,1,1,'USD','USD','USD',1,1,'','',1,'1-1-2020', '1-1-2020', 1, '123456', 1000, NULL);

GO
