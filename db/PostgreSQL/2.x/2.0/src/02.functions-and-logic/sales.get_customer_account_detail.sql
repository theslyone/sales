DROP FUNCTION IF EXISTS sales.get_customer_account_detail(integer, date, date);
CREATE OR REPLACE FUNCTION sales.get_customer_account_detail
(
    _customer_id        integer,
    _from               date,
    _to                 date
)
RETURNS TABLE
(
    id                  integer, 
    value_date          date, 
    invoice_number      bigint, 
    statement_reference text, 
    debit               numeric(30, 6), 
    credit              numeric(30, 6), 
    balance             numeric(30, 6)
)
AS
$BODY$
BEGIN
    CREATE TEMPORARY TABLE _customer_account_detail
    (
        id                      SERIAL NOT NULL,
        value_date              date,
        invoice_number          bigint,
        statement_reference     text,
        debit                   numeric(30, 6),
        credit                  numeric(30, 6),
        balance                 numeric(30, 6)
    ) ON COMMIT DROP;

    INSERT INTO _customer_account_detail
    (
        value_date, 
        invoice_number, 
        statement_reference, 
        debit, 
        credit
    )
    SELECT 
        ctv.value_date,
        ctv.invoice_number,
        ctv.statement_reference,
        ctv.debit,
        ctv.credit
    FROM sales.customer_transaction_view ctv
    LEFT JOIN inventory.customers cus
    ON ctv.customer_id = cus.customer_id
    WHERE ctv.customer_id = _customer_id
    AND ctv.value_date BETWEEN _from AND _to;

    UPDATE _customer_account_detail 
    SET balance = c.balance
    FROM
    (
        SELECT p.id,
            SUM(COALESCE(c.debit, 0) - COALESCE(c.credit, 0)) As balance
        FROM _customer_account_detail p
        LEFT JOIN _customer_account_detail c
        ON c.id <= p.id
        GROUP BY p.id
        ORDER BY p.id
    ) AS c
    WHERE _customer_account_detail.id = c.id;

    RETURN QUERY
    SELECT * FROM _customer_account_detail;
END
$BODY$
 LANGUAGE plpgsql;

