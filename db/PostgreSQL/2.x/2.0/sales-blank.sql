-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/01.types-domains-tables-and-constraints/tables-and-constraints.sql --<--<--
DROP SCHEMA IF EXISTS sales CASCADE;

CREATE SCHEMA sales;

--TODO: CREATE UNIQUE INDEXES

CREATE TABLE sales.gift_cards
(
    gift_card_id                            SERIAL PRIMARY KEY,
    gift_card_number                        national character varying(100),
	payable_account_id					    integer NOT NULL REFERENCES finance.accounts,
    customer_id                             integer REFERENCES inventory.customers,
    first_name                              national character varying(100),
    middle_name                             national character varying(100),
    last_name                               national character varying(100),
    address_line_1                          national character varying(128),   
    address_line_2                          national character varying(128),
    street                                  national character varying(100),
    city                                    national character varying(100),
    state                                   national character varying(100),
    country                                 national character varying(100),
    po_box                                  national character varying(100),
    zipcode                                 national character varying(100),
    phone_numbers                           national character varying(100),
    fax                                     national character varying(100),    
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)    
);

CREATE UNIQUE INDEX gift_cards_gift_card_number_uix
ON sales.gift_cards(UPPER(gift_card_number));

--TODO: Create a trigger to disable deleting a gift card if the balance is not zero.

CREATE TABLE sales.gift_card_transactions
(
    transaction_id                          BIGSERIAL PRIMARY KEY,
	gift_card_id							integer NOT NULL REFERENCES sales.gift_cards,
	value_date								date,
	book_date								date,
    transaction_master_id                   bigint NOT NULL REFERENCES finance.transaction_master,
    transaction_type                        national character varying(2) NOT NULL
                                            CHECK(transaction_type IN('Dr', 'Cr')),
    amount                                  public.money_strict
);

CREATE TABLE sales.late_fee
(
    late_fee_id                             SERIAL PRIMARY KEY,
    late_fee_code                           national character varying(24) NOT NULL,
    late_fee_name                           national character varying(500) NOT NULL,
    is_flat_amount                          boolean NOT NULL DEFAULT(false),
    rate                                    numeric(24,4) NOT NULL,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE TABLE sales.price_types
(
    price_type_id                           SERIAL PRIMARY KEY,
    price_type_code                         national character varying(24) NOT NULL,
    price_type_name                         national character varying(500) NOT NULL,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE TABLE sales.item_selling_prices
(
    item_selling_price_id                   BIGSERIAL PRIMARY KEY,
    item_id                                 integer NOT NULL REFERENCES inventory.items,
    unit_id                                 integer NOT NULL REFERENCES inventory.units,
    customer_type_id                        integer REFERENCES inventory.customer_types,
    price_type_id                           integer REFERENCES sales.price_types,
    includes_tax                            boolean NOT NULL DEFAULT(false),
    price                                   public.money_strict NOT NULL,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE TABLE sales.payment_terms
(
    payment_term_id                         SERIAL PRIMARY KEY,
    payment_term_code                       national character varying(24) NOT NULL,
    payment_term_name                       national character varying(500) NOT NULL,
    due_on_date                             boolean NOT NULL DEFAULT(false),
    due_days                                public.integer_strict2 NOT NULL DEFAULT(0),
    due_frequency_id                        integer REFERENCES finance.frequencies,
    grace_period                            integer NOT NULL DEFAULT(0),
    late_fee_id                             integer REFERENCES sales.late_fee,
    late_fee_posting_frequency_id           integer REFERENCES finance.frequencies,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)    
);


CREATE TABLE sales.cashiers
(
    cashier_id                              SERIAL PRIMARY KEY,
    cashier_code                            national character varying(12) NOT NULL,
    pin_code                                national character varying(8) NOT NULL,
    associated_user_id                      integer NOT NULL REFERENCES account.users,
    counter_id                              integer NOT NULL REFERENCES inventory.counters,
    valid_from                              date NOT NULL,
    valid_till                              date NOT NULL CHECK(valid_till >= valid_from),
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE TABLE sales.cashier_login_info
(
    cashier_login_info_id                   uuid PRIMARY KEY DEFAULT(gen_random_uuid()),
    counter_id                              integer REFERENCES inventory.counters,
    cashier_id                              integer REFERENCES sales.cashiers,
    login_date                              TIMESTAMP WITH TIME ZONE NOT NULL,
    success                                 boolean NOT NULL,
    attempted_by                            integer NOT NULL REFERENCES account.users,
    browser                                 text,
    ip_address                              text,
    user_agent                              text,    
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);


CREATE TABLE sales.quotations
(
    quotation_id                            BIGSERIAL PRIMARY KEY,
    value_date                              date NOT NULL,
    transaction_timestamp                   TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT(NOW()),
    customer_id                             integer NOT NULL REFERENCES inventory.customers,
    price_type_id                           integer NOT NULL REFERENCES sales.price_types,
    user_id                                 integer NOT NULL REFERENCES account.users,
    office_id                               integer NOT NULL REFERENCES core.offices,
    reference_number                        national character varying(24),
    memo                                    national character varying(500),
    internal_memo                           national character varying(500),
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE TABLE sales.quotation_details
(
    quotation_detail_id                     BIGSERIAL PRIMARY KEY,
    quotation_id                            bigint NOT NULL REFERENCES sales.quotations,
    value_date                              date NOT NULL,
    item_id                                 integer NOT NULL REFERENCES inventory.items,
    price                                   public.money_strict NOT NULL,
    discount                                public.money_strict2 NOT NULL DEFAULT(0),    
    shipping_charge                         public.money_strict2 NOT NULL DEFAULT(0),    
    unit_id                                 integer NOT NULL REFERENCES inventory.units,
    quantity                                public.integer_strict2 NOT NULL,
    base_unit_id                            integer NOT NULL REFERENCES inventory.units,
    base_quantity                           numeric NOT NULL
);


CREATE TABLE sales.orders
(
    order_id                                BIGSERIAL PRIMARY KEY,
    quotation_id                            bigint REFERENCES sales.quotations,
    value_date                              date NOT NULL,
    transaction_timestamp                   TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT(NOW()),
    customer_id                             integer NOT NULL REFERENCES inventory.customers,
    price_type_id                           integer NOT NULL REFERENCES sales.price_types,
    user_id                                 integer NOT NULL REFERENCES account.users,
    office_id                               integer NOT NULL REFERENCES core.offices,
    reference_number                        national character varying(24),
    memo                                    national character varying(500),
    internal_memo                           national character varying(500),
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE TABLE sales.order_details
(
    order_detail_id                         BIGSERIAL PRIMARY KEY,
    order_id                                bigint NOT NULL REFERENCES sales.orders,
    value_date                              date NOT NULL,
    item_id                                 integer NOT NULL REFERENCES inventory.items,
    price                                   public.money_strict NOT NULL,
    discount                                public.money_strict2 NOT NULL DEFAULT(0),    
    shipping_charge                         public.money_strict2 NOT NULL DEFAULT(0),    
    unit_id                                 integer NOT NULL REFERENCES inventory.units,
    quantity                                public.integer_strict2 NOT NULL,
    base_unit_id                            integer NOT NULL REFERENCES inventory.units,
    base_quantity                           numeric NOT NULL
);


CREATE TABLE sales.coupons
(
    coupon_id                                   SERIAL PRIMARY KEY,
    coupon_name                                 national character varying(100) NOT NULL,
    coupon_code                                 national character varying(100) NOT NULL,
    discount_rate                               public.decimal_strict,
    is_percentage                               boolean NOT NULL DEFAULT(false),
    maximum_discount_amount                     public.decimal_strict,
    associated_price_type_id                    integer REFERENCES sales.price_types,
    minimum_purchase_amount                     public.decimal_strict2,
    maximum_purchase_amount                     public.decimal_strict2,
    begins_from                                 date,
    expires_on                                  date,
    maximum_usage                               public.integer_strict,
    enable_ticket_printing                      boolean,
    for_ticket_of_price_type_id                 integer REFERENCES sales.price_types,
    for_ticket_having_minimum_amount            public.decimal_strict2,
    for_ticket_having_maximum_amount            public.decimal_strict2,
    for_ticket_of_unknown_customers_only        boolean,
    audit_user_id                               integer REFERENCES account.users,
    audit_ts                                    TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									    boolean DEFAULT(false)    
);

CREATE UNIQUE INDEX coupons_coupon_code_uix
ON sales.coupons(UPPER(coupon_code));



CREATE TABLE sales.sales
(
    sales_id                                BIGSERIAL PRIMARY KEY,
	cash_repository_id						integer REFERENCES finance.cash_repositories,
	price_type_id							integer NOT NULL REFERENCES sales.price_types,
	sales_order_id							bigint REFERENCES sales.orders,
	sales_quotation_id					    bigint REFERENCES sales.quotations,
	transaction_master_id					bigint NOT NULL REFERENCES finance.transaction_master,
    checkout_id                             bigint NOT NULL REFERENCES inventory.checkouts,
    counter_id                              integer NOT NULL REFERENCES inventory.counters,
    customer_id                             integer REFERENCES inventory.customers,
	salesperson_id							integer REFERENCES account.users,
	coupon_id								integer REFERENCES sales.coupons,
	is_flat_discount						boolean,
	discount								public.decimal_strict2,
	total_discount_amount					public.decimal_strict2,	
    is_credit                               boolean NOT NULL DEFAULT(false),
	credit_settled							boolean,
    payment_term_id                         integer REFERENCES sales.payment_terms,
    tender                                  decimal(24, 4) NOT NULL CHECK(tender > 0),
    change                                  decimal(24, 4) NOT NULL,
    check_number                            national character varying(100),
    check_date                              date,
    check_bank_name                         national character varying(1000),
    check_amount                            public.money_strict2,
    check_cleared                           boolean,    
    check_clear_date                        date,   
    check_clearing_memo                     national character varying(1000),
    check_clearing_transaction_master_id    integer REFERENCES finance.transaction_master,
    gift_card_id                            integer REFERENCES sales.gift_cards
);

CREATE TABLE sales.customer_receipts
(
    receipt_id                              BIGSERIAL PRIMARY KEY,
    transaction_master_id                   bigint NOT NULL REFERENCES finance.transaction_master,
    customer_id                             bigint NOT NULL REFERENCES inventory.customers,
    currency_code                           national character varying(12) NOT NULL REFERENCES finance.currencies,
    er_debit                                decimal_strict NOT NULL,
    er_credit                               decimal_strict NOT NULL,
    cash_repository_id                      integer NULL REFERENCES finance.cash_repositories,
    posted_date                             date NULL,
    tender                                  public.money_strict2,
    change                                  public.money_strict2,
    check_amount                            public.money_strict2,
    bank_name                               national character varying(1000),
    check_number                            national character varying(100),
    check_date                              date,
    gift_card_number                        national character varying(100)
);

CREATE INDEX customer_receipts_transaction_master_id_inx
ON sales.customer_receipts(transaction_master_id);

CREATE INDEX customer_receipts_customer_id_inx
ON sales.customer_receipts(customer_id);

CREATE INDEX customer_receipts_currency_code_inx
ON sales.customer_receipts(currency_code);

CREATE INDEX customer_receipts_cash_repository_id_inx
ON sales.customer_receipts(cash_repository_id);

CREATE INDEX customer_receipts_posted_date_inx
ON sales.customer_receipts(posted_date);



CREATE TABLE sales.returns
(
    return_id                               BIGSERIAL PRIMARY KEY,
    sales_id                                bigint NOT NULL REFERENCES sales.sales,
    checkout_id                             bigint NOT NULL REFERENCES inventory.checkouts,
    counter_id                              integer NOT NULL REFERENCES inventory.counters,
    customer_id                             integer REFERENCES inventory.customers
);


CREATE TYPE sales.sales_detail_type
AS
(
    store_id            integer,
	transaction_type	national character varying(2),
    item_id           	integer,
    quantity            public.integer_strict,
    unit_id           	integer,
    price               public.money_strict,
    discount            public.money_strict2,
    shipping_charge     public.money_strict2
);



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.add_gift_card_fund.sql --<--<--
DROP FUNCTION IF EXISTS sales.add_gift_card_fund
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _gift_card_id                               integer,
    _value_date                                 date,
    _book_date                                  date,
    _debit_account_id                           integer,
    _amount                                     public.money_strict,
    _cost_center_id                             integer,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128)
);

CREATE FUNCTION sales.add_gift_card_fund
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _gift_card_id                               integer,
    _value_date                                 date,
    _book_date                                  date,
    _debit_account_id                           integer,
    _amount                                     public.money_strict,
    _cost_center_id                             integer,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128)
)
RETURNS bigint
AS
$$
    DECLARE _transaction_master_id              bigint;
    DECLARE _book_name                          national character varying(50) = 'Gift Card Fund Transfer';
    DECLARE _payable_account_id                 integer;
    DECLARE _currency_code                      national character varying(12);
BEGIN
    _currency_code                              := core.get_currency_code_by_office_id(_office_id);
    _payable_account_id                         := sales.get_payable_account_id_by_gift_card_id(_gift_card_id);
    _transaction_master_id                      := nextval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id'));

    INSERT INTO finance.transaction_master(transaction_master_id, transaction_counter, transaction_code, book, value_date, book_date, login_id, user_id, office_id, cost_center_id, reference_number, statement_reference)
    SELECT
        _transaction_master_id,
        finance.get_new_transaction_counter(_value_date),
        finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id),
        _book_name,
        _value_date,
        _book_date,
        _login_id,
        _user_id,
        _office_id,
        _cost_center_id,
        _reference_number,
        _statement_reference;

    INSERT INTO finance.transaction_details(transaction_master_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, office_id, audit_user_id)
    SELECT
        _transaction_master_id, 
        _value_date, 
        _book_date,
        'Cr', 
        _payable_account_id, 
        _statement_reference, 
        _currency_code, 
        _amount, 
        _currency_code, 
        1, 
        _amount, 
        _office_id, 
        _user_id;

    INSERT INTO finance.transaction_details(transaction_master_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, office_id, audit_user_id)
    SELECT
        _transaction_master_id, 
        _value_date, 
        _book_date,
        'Dr', 
        _debit_account_id, 
        _statement_reference, 
        _currency_code, 
        _amount, 
        _currency_code, 
        1, 
        _amount, 
        _office_id, 
        _user_id;

    INSERT INTO sales.gift_card_transactions(gift_card_id, value_date, book_date, transaction_master_id, transaction_type, amount)
    SELECT _gift_card_id, _value_date, _book_date, _transaction_master_id, 'Cr', _amount;

    RETURN _transaction_master_id;
END
$$
LANGUAGE plpgsql;

--SELECT * FROM sales.add_gift_card_fund(1, 1, 1, sales.get_gift_card_id_by_gift_card_number('123456'), '1-1-2020', '1-1-2020', 1, 2000, 1, '', '');



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_active_coupon_id_by_coupon_code.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_active_coupon_id_by_coupon_code(_coupon_code national character varying(100));

CREATE FUNCTION sales.get_active_coupon_id_by_coupon_code(_coupon_code national character varying(100))
RETURNS integer
AS
$$
BEGIN
    RETURN sales.coupons.coupon_id
    FROM sales.coupons
    WHERE sales.coupons.coupon_code = _coupon_code
    AND COALESCE(sales.coupons.begins_from, NOW()::date) >= NOW()::date
    AND COALESCE(sales.coupons.expires_on, NOW()::date) <= NOW()::date
    AND NOT sales.coupons.deleted;
END
$$
LANGUAGE plpgsql;


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_gift_card_balance.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_gift_card_balance(_gift_card_id integer, _value_date date);

CREATE FUNCTION sales.get_gift_card_balance(_gift_card_id integer, _value_date date)
RETURNS decimal(24, 4)
AS
$$
    DECLARE _debit          decimal(24, 4);
    DECLARE _credit         decimal(24, 4);
BEGIN
    SELECT SUM(COALESCE(sales.gift_card_transactions.amount, 0))
    INTO _debit
    FROM sales.gift_card_transactions
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = sales.gift_card_transactions.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND sales.gift_card_transactions.transaction_type = 'Dr'
    AND finance.transaction_master.value_date <= _value_date;

    SELECT SUM(COALESCE(sales.gift_card_transactions.amount, 0))
    INTO _credit
    FROM sales.gift_card_transactions
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = sales.gift_card_transactions.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND sales.gift_card_transactions.transaction_type = 'Cr'
    AND finance.transaction_master.value_date <= _value_date;

    --Gift cards are account payables
    RETURN COALESCE(_credit, 0) - COALESCE(_debit, 0);
END
$$
LANGUAGE plpgsql;

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_gift_card_id_by_gift_card_number.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_gift_card_id_by_gift_card_number(_gift_card_number national character varying(100));

CREATE FUNCTION sales.get_gift_card_id_by_gift_card_number(_gift_card_number national character varying(100))
RETURNS integer
AS
$$
BEGIN
    RETURN sales.gift_cards.gift_card_id
    FROM sales.gift_cards
    WHERE sales.gift_cards.gift_card_number = _gift_card_number
    AND NOT sales.gift_cards.deleted;
END
$$
LANGUAGE plpgsql;



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_item_selling_price.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_item_selling_price(_item_id integer, _customer_type_id integer, _price_type_id integer, _unit_id integer);

CREATE FUNCTION sales.get_item_selling_price(_item_id integer, _customer_type_id integer, _price_type_id integer, _unit_id integer)
RETURNS public.money_strict2
AS
$$
    DECLARE _price              public.money_strict2;
    DECLARE _costing_unit_id    integer;
    DECLARE _factor             decimal;
    DECLARE _tax_rate           decimal;
    DECLARE _includes_tax       boolean;
    DECLARE _tax                public.money_strict2;
BEGIN

    --Fist pick the catalog price which matches all these fields:
    --Item, Customer Type, Price Type, and Unit.
    --This is the most effective price.
    SELECT 
        item_selling_prices.price, 
        item_selling_prices.unit_id,
        item_selling_prices.includes_tax
    INTO 
        _price, 
        _costing_unit_id,
        _includes_tax       
    FROM sales.item_selling_prices
    WHERE item_selling_prices.item_id=_item_id
    AND item_selling_prices.customer_type_id=_customer_type_id
    AND item_selling_prices.price_type_id =_price_type_id
    AND item_selling_prices.unit_id = _unit_id
	AND NOT sales.item_selling_prices.deleted;

    IF(_costing_unit_id IS NULL) THEN
        --We do not have a selling price of this item for the unit supplied.
        --Let's see if this item has a price for other units.
        SELECT 
            item_selling_prices.price, 
            item_selling_prices.unit_id,
            item_selling_prices.includes_tax
        INTO 
            _price, 
            _costing_unit_id,
            _includes_tax
        FROM sales.item_selling_prices
        WHERE item_selling_prices.item_id=_item_id
        AND item_selling_prices.customer_type_id=_customer_type_id
        AND item_selling_prices.price_type_id =_price_type_id
		AND NOT sales.item_selling_prices.deleted;
    END IF;

    IF(_price IS NULL) THEN
        SELECT 
            item_selling_prices.price, 
            item_selling_prices.unit_id,
            item_selling_prices.includes_tax
        INTO 
            _price, 
            _costing_unit_id,
            _includes_tax
        FROM sales.item_selling_prices
        WHERE item_selling_prices.item_id=_item_id
        AND item_selling_prices.price_type_id =_price_type_id
		AND NOT sales.item_selling_prices.deleted;
    END IF;

    
    IF(_price IS NULL) THEN
        --This item does not have selling price defined in the catalog.
        --Therefore, getting the default selling price from the item definition.
        SELECT 
            selling_price, 
            unit_id,
            false
        INTO 
            _price, 
            _costing_unit_id,
            _includes_tax
        FROM inventory.items
        WHERE inventory.items.item_id = _item_id
		AND NOT inventory.items.deleted;
    END IF;

    IF(_includes_tax) THEN
        _tax_rate := core.get_item_tax_rate(_item_id);
        _price := _price / ((100 + _tax_rate)/ 100);
    END IF;

    --Get the unitary conversion factor if the requested unit does not match with the price defition.
    _factor := inventory.convert_unit(_unit_id, _costing_unit_id);

    RETURN _price * _factor;
END
$$
LANGUAGE plpgsql;


SELECT * FROM sales.get_item_selling_price(1, 1, 1, 1);


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_late_fee_id_by_late_fee_code.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_late_fee_id_by_late_fee_code(_late_fee_code national character varying(24));

CREATE FUNCTION sales.get_late_fee_id_by_late_fee_code(_late_fee_code national character varying(24))
RETURNS integer
AS
$$
BEGIN
    RETURN sales.late_fee.late_fee_id
    FROM sales.late_fee
    WHERE sales.late_fee.late_fee_code = _late_fee_code
    AND NOT sales.late_fee.deleted;    
END
$$
LANGUAGE plpgsql;


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_payable_account_for_gift_card.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_payable_account_for_gift_card(_gift_card_id integer);

CREATE FUNCTION sales.get_payable_account_for_gift_card(_gift_card_id integer)
RETURNS integer
AS
$$
BEGIN
    RETURN sales.gift_cards.payable_account_id
    FROM sales.gift_cards
    WHERE sales.gift_cards.gift_card_id= _gift_card_id
    AND NOT sales.gift_cards.deleted;
END
$$
LANGUAGE plpgsql;



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_payable_account_id_by_gift_card_id.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_payable_account_id_by_gift_card_id(_gift_card_id integer);

CREATE FUNCTION sales.get_payable_account_id_by_gift_card_id(_gift_card_id integer)
RETURNS integer
AS
$$
BEGIN
    RETURN sales.gift_cards.payable_account_id
    FROM sales.gift_cards
    WHERE NOT sales.gift_cards.deleted
    AND sales.gift_cards.gift_card_id = _gift_card_id;
END
$$
LANGUAGE plpgsql;

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.get_receivable_account_for_check_receipts.sql --<--<--
DROP FUNCTION IF EXISTS sales.get_receivable_account_for_check_receipts(_store_id integer);

CREATE FUNCTION sales.get_receivable_account_for_check_receipts(_store_id integer)
RETURNS integer
AS
$$
BEGIN
    RETURN inventory.stores.default_account_id_for_checks
    FROM inventory.stores
    WHERE inventory.stores.store_id = _store_id
    AND NOT inventory.stores.deleted;
END
$$
LANGUAGE plpgsql;



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.post_cash_receipt.sql --<--<--
DROP FUNCTION IF EXISTS sales.post_cash_receipt
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _customer_id                                integer,
    _customer_account_id                        integer,
    _currency_code                              national character varying(12),
    _local_currency_code                        national character varying(12),
    _base_currency_code                         national character varying(12),
    _exchange_rate_debit                        public.decimal_strict, 
    _exchange_rate_credit                       public.decimal_strict,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128), 
    _cost_center_id                             integer,
    _cash_account_id                            integer,
    _cash_repository_id                         integer,
    _value_date                                 date,
    _book_date                                  date,
    _tender                                     public.money_strict2,
    _change                                     public.money_strict2,
    _cascading_tran_id                          bigint
);

CREATE FUNCTION sales.post_cash_receipt
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _customer_id                                integer,
    _customer_account_id                        integer,
    _currency_code                              national character varying(12),
    _local_currency_code                        national character varying(12),
    _base_currency_code                         national character varying(12),
    _exchange_rate_debit                        public.decimal_strict, 
    _exchange_rate_credit                       public.decimal_strict,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128), 
    _cost_center_id                             integer,
    _cash_account_id                            integer,
    _cash_repository_id                         integer,
    _value_date                                 date,
    _book_date                                  date,
    _tender                                     public.money_strict2,
    _change                                     public.money_strict2,
    _cascading_tran_id                          bigint
)
RETURNS bigint
AS
$$
    DECLARE _book                               text = 'Sales Receipt';
    DECLARE _transaction_master_id              bigint;
    DECLARE _debit                              public.money_strict2;
    DECLARE _credit                             public.money_strict2;
    DECLARE _lc_debit                           public.money_strict2;
    DECLARE _lc_credit                          public.money_strict2;
BEGIN           
    _debit                                  := _tender;
    _lc_debit                               := _tender * _exchange_rate_debit;

    _credit                                 := _tender * (_exchange_rate_debit/ _exchange_rate_credit);
    _lc_credit                              := _tender * _exchange_rate_debit;
    
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
        nextval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id')), 
        finance.get_new_transaction_counter(_value_date), 
        finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id),
        _book,
        _value_date,
        _book_date,
        _user_id,
        _login_id,
        _office_id,
        _cost_center_id,
        _reference_number,
        _statement_reference,
        _user_id,
        _cascading_tran_id;


    _transaction_master_id := currval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id'));

    --Debit
    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
    SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Dr', _cash_account_id, _statement_reference, _cash_repository_id, _currency_code, _debit, _local_currency_code, _exchange_rate_debit, _lc_debit, _user_id;

    --Credit
    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date,  book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
    SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Cr', _customer_account_id, _statement_reference, NULL, _base_currency_code, _credit, _local_currency_code, _exchange_rate_credit, _lc_credit, _user_id;
    
    
    INSERT INTO sales.customer_receipts(transaction_master_id, customer_id, currency_code, er_debit, er_credit, cash_repository_id, posted_date, tender, change)
    SELECT _transaction_master_id, _customer_id, _currency_code, _exchange_rate_debit, _exchange_rate_credit, _cash_repository_id, _value_date, _tender, _change;

    RETURN _transaction_master_id;
END
$$
LANGUAGE plpgsql;

--SELECT * FROM sales.post_cash_receipt(1, 1, 1, 1, 1, 'USD', 'USD', 'USD', 1, 1, '', '', 1, 1, 1, '1-1-2020', '1-1-2020', 2000, 0, NULL);

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.post_check_receipt.sql --<--<--
DROP FUNCTION IF EXISTS sales.post_check_receipt
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _customer_id                                integer,
    _customer_account_id                        integer,
    _receivable_account_id                      integer,--sales.get_receivable_account_for_check_receipts(_store_id)
    _currency_code                              national character varying(12),
    _local_currency_code                        national character varying(12),
    _base_currency_code                         national character varying(12),
    _exchange_rate_debit                        public.decimal_strict, 
    _exchange_rate_credit                       public.decimal_strict,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128), 
    _cost_center_id                             integer,
    _value_date                                 date,
    _book_date                                  date,
    _check_amount                               public.money_strict2,
    _check_bank_name                            national character varying(1000),
    _check_number                               national character varying(100),
    _check_date                                 date,
    _cascading_tran_id                          bigint
);

CREATE FUNCTION sales.post_check_receipt
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _customer_id                                integer,
    _customer_account_id                        integer,
    _receivable_account_id                      integer,--sales.get_receivable_account_for_check_receipts(_store_id)
    _currency_code                              national character varying(12),
    _local_currency_code                        national character varying(12),
    _base_currency_code                         national character varying(12),
    _exchange_rate_debit                        public.decimal_strict, 
    _exchange_rate_credit                       public.decimal_strict,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128), 
    _cost_center_id                             integer,
    _value_date                                 date,
    _book_date                                  date,
    _check_amount                               public.money_strict2,
    _check_bank_name                            national character varying(1000),
    _check_number                               national character varying(100),
    _check_date                                 date,
    _cascading_tran_id                          bigint
)
RETURNS bigint
AS
$$
    DECLARE _book                               text = 'Sales Receipt';
    DECLARE _transaction_master_id              bigint;
    DECLARE _debit                              public.money_strict2;
    DECLARE _credit                             public.money_strict2;
    DECLARE _lc_debit                           public.money_strict2;
    DECLARE _lc_credit                          public.money_strict2;
BEGIN            
    _debit                                  := _check_amount;
    _lc_debit                               := _check_amount * _exchange_rate_debit;

    _credit                                 := _check_amount * (_exchange_rate_debit/ _exchange_rate_credit);
    _lc_credit                              := _check_amount * _exchange_rate_debit;
    
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
        nextval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id')), 
        finance.get_new_transaction_counter(_value_date), 
        finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id),
        _book,
        _value_date,
        _book_date,
        _user_id,
        _login_id,
        _office_id,
        _cost_center_id,
        _reference_number,
        _statement_reference,
        _audit_user_id,
        _cascading_tran_id;


    _transaction_master_id := currval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id'));

    --Debit
    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
    SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Dr', _receivable_account_id, _statement_reference, NULL, _currency_code, _debit, _local_currency_code, _exchange_rate_debit, _lc_debit, _user_id;        

    --Credit
    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
    SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Cr', _customer_account_id, _statement_reference, NULL, _base_currency_code, _credit, _local_currency_code, _exchange_rate_credit, _lc_credit, _user_id;
    
    
    INSERT INTO sales.customer_receipts(transaction_master_id, customer_id, currency_code, er_debit, er_credit, posted_date, check_amount, bank_name, check_number, check_date)
    SELECT _transaction_master_id, _customer_id, _currency_code, _exchange_rate_debit, _exchange_rate_credit, _value_date, _check_amount, _check_bank_name, _check_number, _check_date;

    RETURN _transaction_master_id;
END
$$
LANGUAGE plpgsql;

--SELECT * FROM sales.post_check_receipt(1, 1, 1, 1, 1, 1, 'USD', 'USD', 'USD', 1, 1, '', '', 1, '1-1-2020', '1-1-2020', 2000, '', '', '1-1-2020', null);

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.post_receipt.sql --<--<--
DROP FUNCTION IF EXISTS sales.post_receipt
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    
    _customer_id                                integer,
    _currency_code                              national character varying(12), 
    _exchange_rate_debit                        public.decimal_strict, 

    _exchange_rate_credit                       public.decimal_strict,
    _reference_number                           national character varying(24), 
    _statement_reference                        text, 

    _cost_center_id                             integer,
    _cash_account_id                            integer,
    _cash_repository_id                         integer,

    _value_date                                 date,
    _book_date                                  date,
    _receipt_amount                             public.money_strict,

    _tender                                     public.money_strict2,
    _change                                     public.money_strict2,
    _check_amount                               public.money_strict2,

    _check_bank_name                            national character varying(1000),
    _check_number                               national character varying(100),
    _check_date                                 date,

    _gift_card_number                           national character varying(100),
    _store_id                                   integer,
    _cascading_tran_id                          bigint
);

CREATE FUNCTION sales.post_receipt
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    
    _customer_id                                integer,
    _currency_code                              national character varying(12), 
    _exchange_rate_debit                        public.decimal_strict, 

    _exchange_rate_credit                       public.decimal_strict,
    _reference_number                           national character varying(24), 
    _statement_reference                        text, 

    _cost_center_id                             integer,
    _cash_account_id                            integer,
    _cash_repository_id                         integer,

    _value_date                                 date,
    _book_date                                  date,
    _receipt_amount                             public.money_strict,

    _tender                                     public.money_strict2,
    _change                                     public.money_strict2,
    _check_amount                               public.money_strict2,

    _check_bank_name                            national character varying(1000),
    _check_number                               national character varying(100),
    _check_date                                 date,

    _gift_card_number                           national character varying(100),
    _store_id                                   integer DEFAULT NULL,
    _cascading_tran_id                          bigint DEFAULT NULL
)
RETURNS bigint
AS
$$
    DECLARE _book                               text;
    DECLARE _transaction_master_id              bigint;
    DECLARE _base_currency_code                 national character varying(12);
    DECLARE _local_currency_code                national character varying(12);
    DECLARE _customer_account_id                integer;
    DECLARE _debit                              public.money_strict2;
    DECLARE _credit                             public.money_strict2;
    DECLARE _lc_debit                           public.money_strict2;
    DECLARE _lc_credit                          public.money_strict2;
    DECLARE _is_cash                            boolean;
    DECLARE _gift_card_id                       integer;
    DECLARE _receivable_account_id              integer;
BEGIN
    IF(_cash_repository_id > 0 AND _cash_account_id > 0) THEN
        _is_cash                            := true;
    END IF;

    _receivable_account_id                  := sales.get_receivable_account_for_check_receipts(_store_id);
    _gift_card_id                           := sales.get_gift_card_id_by_gift_card_number(_gift_card_number);
    _customer_account_id                    := inventory.get_account_id_by_customer_id(_customer_id);    
    _local_currency_code                    := core.get_currency_code_by_office_id(_office_id);
    _base_currency_code                     := inventory.get_currency_code_by_customer_id(_customer_id);


    IF(_local_currency_code = _currency_code AND _exchange_rate_debit != 1) THEN
        RAISE EXCEPTION 'Invalid exchange rate.'
        USING ERRCODE='P3055';
    END IF;

    IF(_base_currency_code = _currency_code AND _exchange_rate_credit != 1) THEN
        RAISE EXCEPTION 'Invalid exchange rate.'
        USING ERRCODE='P3055';
    END IF;

    --raise exception     '%', _cash_account_id;

    
    IF(_tender >= _receipt_amount) THEN
        _transaction_master_id              := sales.post_cash_receipt(_user_id, _office_id, _login_id, _customer_id, _customer_account_id, _currency_code, _local_currency_code, _base_currency_code, _exchange_rate_debit, _exchange_rate_credit, _reference_number, _statement_reference, _cost_center_id, _cash_account_id, _cash_repository_id, _value_date, _book_date, _tender, _change, _cascading_tran_id);
    ELSIF(_check_amount >= _receipt_amount) THEN
        _transaction_master_id              := sales.post_check_receipt(_user_id, _office_id, _login_id, _customer_id, _customer_account_id, _receivable_account_id, _currency_code, _local_currency_code, _base_currency_code, _exchange_rate_debit, _exchange_rate_credit, _reference_number, _statement_reference, _cost_center_id, _value_date, _book_date, _check_amount, _check_bank_name, _check_number, _check_date, _cascading_tran_id);
    ELSIF(_gift_card_id > 0) THEN
        _transaction_master_id              := sales.post_receipt_by_gift_card(_user_id, _office_id, _login_id, _customer_id, _customer_account_id, _currency_code, _local_currency_code, _base_currency_code, _exchange_rate_debit, _exchange_rate_credit, _reference_number, _statement_reference, _cost_center_id, _value_date, _book_date, _gift_card_id, _gift_card_number, _receipt_amount, _cascading_tran_id);
    ELSE
        RAISE EXCEPTION 'Cannot post receipt. Please check the form and submit again';    
    END IF;

    
    PERFORM finance.auto_verify(_transaction_master_id, _office_id);
    PERFORM sales.settle_customer_due(_customer_id, _office_id);
    RETURN _transaction_master_id;
END
$$
LANGUAGE plpgsql;


--SELECT * FROM sales.post_receipt(1, 1, 1,inventory.get_customer_id_by_customer_code('APP'), 'USD', 1, 1, '', '', 1, 1, 1, '1-1-2020', '1-1-2020', 100, 0, 1000, '', '', null, '', null);
--SELECT * FROM sales.post_receipt(1,1,1,inventory.get_customer_id_by_customer_code('DEF'),'USD',1,1,'','', 1, 1, 1, '1-1-2020', '1-1-2020', 2000, 0, 0, 0, '', '', null, '123456', 1, null);


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.post_receipt_by_gift_card.sql --<--<--
DROP FUNCTION IF EXISTS sales.post_receipt_by_gift_card
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _customer_id                                integer,
    _customer_account_id                        integer,
    _currency_code                              national character varying(12),
    _local_currency_code                        national character varying(12),
    _base_currency_code                         national character varying(12),
    _exchange_rate_debit                        public.decimal_strict, 
    _exchange_rate_credit                       public.decimal_strict,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128), 
    _cost_center_id                             integer,
    _value_date                                 date,
    _book_date                                  date,
    _gift_card_id                               integer,
    _gift_card_number                           national character varying(100),
    _amount                                     public.money_strict,
    _cascading_tran_id                          bigint
);

CREATE FUNCTION sales.post_receipt_by_gift_card
(
    _user_id                                    integer, 
    _office_id                                  integer, 
    _login_id                                   bigint,
    _customer_id                                integer,
    _customer_account_id                        integer,
    _currency_code                              national character varying(12),
    _local_currency_code                        national character varying(12),
    _base_currency_code                         national character varying(12),
    _exchange_rate_debit                        public.decimal_strict, 
    _exchange_rate_credit                       public.decimal_strict,
    _reference_number                           national character varying(24), 
    _statement_reference                        national character varying(128), 
    _cost_center_id                             integer,
    _value_date                                 date,
    _book_date                                  date,
    _gift_card_id                               integer,
    _gift_card_number                           national character varying(100),
    _amount                                     public.money_strict,
    _cascading_tran_id                          bigint
)
RETURNS bigint
AS
$$
    DECLARE _book                               text = 'Sales Receipt';
    DECLARE _transaction_master_id              bigint;
    DECLARE _debit                              public.money_strict2;
    DECLARE _credit                             public.money_strict2;
    DECLARE _lc_debit                           public.money_strict2;
    DECLARE _lc_credit                          public.money_strict2;
    DECLARE _is_cash                            boolean;
    DECLARE _gift_card_payable_account_id       integer;
BEGIN        
    _gift_card_payable_account_id           := sales.get_payable_account_for_gift_card(_gift_card_id);
    _debit                                  := _amount;
    _lc_debit                               := _amount * _exchange_rate_debit;

    _credit                                 := _amount * (_exchange_rate_debit/ _exchange_rate_credit);
    _lc_credit                              := _amount * _exchange_rate_debit;
    
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
        nextval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id')), 
        finance.get_new_transaction_counter(_value_date), 
        finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id),
        _book,
        _value_date,
        _book_date,
        _user_id,
        _login_id,
        _office_id,
        _cost_center_id,
        _reference_number,
        _statement_reference,
        _user_id,
        _cascading_tran_id;


    _transaction_master_id := currval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id'));

    --Debit
    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
    SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Dr', _gift_card_payable_account_id, _statement_reference, NULL, _currency_code, _debit, _local_currency_code, _exchange_rate_debit, _lc_debit, _user_id;        

    --Credit
    INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
    SELECT _transaction_master_id, _office_id, _value_date, _book_date, 'Cr', _customer_account_id, _statement_reference, NULL, _base_currency_code, _credit, _local_currency_code, _exchange_rate_credit, _lc_credit, _user_id;
    
    
    INSERT INTO sales.customer_receipts(transaction_master_id, customer_id, currency_code, er_debit, er_credit, posted_date, gift_card_number)
    SELECT _transaction_master_id, _customer_id, _currency_code, _exchange_rate_debit, _exchange_rate_credit, _value_date, _gift_card_number;

    RETURN _transaction_master_id;
END
$$
LANGUAGE plpgsql;

--select * from sales.post_receipt_by_gift_card(1,1, 1,1,1,'USD','USD','USD',1,1,'','',1,'1-1-2020', '1-1-2020', 1, '123456', 1000, NULL);

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/sales.settle_customer_due.sql --<--<--
DROP FUNCTION IF EXISTS sales.settle_customer_due(_customer_id bigint, _office_id integer);

CREATE FUNCTION sales.settle_customer_due(_customer_id bigint, _office_id integer)
RETURNS void
STRICT VOLATILE
AS
$$
    DECLARE _settled_transactions           bigint[];
    DECLARE _settling_amount                numeric;
    DECLARE _closing_balance                numeric;
    DECLARE _total_sales                    numeric;
    DECLARE _customer_account_id            bigint = inventory.get_account_id_by_customer_id(_customer_id);
BEGIN   
    --Closing balance of the customer
    SELECT
        SUM
        (
            CASE WHEN tran_type = 'Cr' 
            THEN amount_in_local_currency 
            ELSE amount_in_local_currency  * -1 
            END
        ) INTO _closing_balance
    FROM finance.transaction_details
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = finance.transaction_details.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND NOT finance.transaction_master.deleted
    AND finance.transaction_master.office_id = _office_id
    AND finance.transaction_details.account_id = _customer_account_id;


    --Since customer account is receivable, change the balance to debit
    _closing_balance := _closing_balance * -1;

    --Sum of total sales amount
    SELECT 
        SUM
        (
            (inventory.checkout_details.quantity * inventory.checkout_details.price) 
            - 
            inventory.checkout_details.discount 
            + 
            inventory.checkout_details.shipping_charge
        ) INTO _total_sales
    FROM inventory.checkouts
    INNER JOIN sales.sales
    ON sales.sales.checkout_id = inventory.checkouts.checkout_id
    INNER JOIN inventory.checkout_details
    ON inventory.checkouts.checkout_id = inventory.checkout_details.checkout_id
    INNER JOIN finance.transaction_master
    ON inventory.checkouts.transaction_master_id = finance.transaction_master.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND finance.transaction_master.office_id = _office_id
    AND sales.sales.customer_id = _customer_id;


    _settling_amount := _total_sales - _closing_balance;

    WITH all_sales
    AS
    (
        SELECT 
            inventory.checkouts.transaction_master_id,
            SUM
            (
                (inventory.checkout_details.quantity * inventory.checkout_details.price) 
                - 
                inventory.checkout_details.discount 
                + 
                inventory.checkout_details.shipping_charge
            ) as due
        FROM inventory.checkouts
        INNER JOIN sales.sales
        ON sales.sales.checkout_id = inventory.checkouts.checkout_id
        INNER JOIN inventory.checkout_details
        ON inventory.checkouts.checkout_id = inventory.checkout_details.checkout_id
        INNER JOIN finance.transaction_master
        ON inventory.checkouts.transaction_master_id = finance.transaction_master.transaction_master_id
        WHERE finance.transaction_master.book = ANY(ARRAY['Sales.Direct', 'Sales.Delivery'])
        AND finance.transaction_master.office_id = _office_id
        AND finance.transaction_master.verification_status_id > 0      --Approved
        AND sales.sales.customer_id = _customer_id                     --of this customer
        GROUP BY inventory.checkouts.transaction_master_id
    ),
    sales_summary
    AS
    (
        SELECT 
            transaction_master_id, 
            due, 
            SUM(due) OVER(ORDER BY transaction_master_id) AS cumulative_due
        FROM all_sales
    )

    SELECT 
        ARRAY_AGG(transaction_master_id) INTO _settled_transactions
    FROM sales_summary
    WHERE cumulative_due <= _settling_amount;

    UPDATE sales.sales
    SET credit_settled = true
    WHERE transaction_master_id = ANY(_settled_transactions);
END
$$
LANGUAGE plpgsql;



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/02.functions-and-logic/transactions.post_sales.sql --<--<--
DROP FUNCTION IF EXISTS sales.post_sales
(
    _office_id                              integer,
    _user_id                                integer,
    _login_id                               bigint,
    _counter_id                             integer,
    _value_date                             date,
    _book_date                              date,
    _cost_center_id                         integer,
    _reference_number                       national character varying(24),
    _statement_reference                    text,
    _tender                                 public.money_strict2,
    _change                                 public.money_strict2,
    _payment_term_id                        integer,
    _check_amount                           public.money_strict2,
    _check_bank_name                        national character varying(1000),
    _check_number                           national character varying(100),
    _check_date                             date,
    _gift_card_number                       national character varying(100),
    _customer_id                            integer,
    _price_type_id                          integer,
    _shipper_id                             integer,
    _store_id                               integer,
    _coupon_code                            national character varying(100),
    _is_flat_discount                       boolean,
    _discount                               public.money_strict2,
    _details                                sales.sales_detail_type[],
    _sales_quotation_id                     bigint,
    _sales_order_id                         bigint
);


CREATE FUNCTION sales.post_sales
(
    _office_id                              integer,
    _user_id                                integer,
    _login_id                               bigint,
    _counter_id                             integer,
    _value_date                             date,
    _book_date                              date,
    _cost_center_id                         integer,
    _reference_number                       national character varying(24),
    _statement_reference                    text,
    _tender                                 public.money_strict2,
    _change                                 public.money_strict2,
    _payment_term_id                        integer,
    _check_amount                           public.money_strict2,
    _check_bank_name                        national character varying(1000),
    _check_number                           national character varying(100),
    _check_date                             date,
    _gift_card_number                       national character varying(100),
    _customer_id                            integer,
    _price_type_id                          integer,
    _shipper_id                             integer,
    _store_id                               integer,
    _coupon_code                            national character varying(100),
    _is_flat_discount                       boolean,
    _discount                               public.money_strict2,
    _details                                sales.sales_detail_type[],
    _sales_quotation_id                     bigint,
    _sales_order_id                         bigint
)
RETURNS bigint
AS
$$
    DECLARE _book_name                      national character varying(48) = 'Sales';
    DECLARE _transaction_master_id          bigint;
    DECLARE _checkout_id                    bigint;
    DECLARE _checkout_detail_id             bigint;
    DECLARE _grand_total                    money_strict;
    DECLARE _discount_total                 money_strict2;
    DECLARE _receivable                     money_strict2;
    DECLARE _default_currency_code          national character varying(12);
    DECLARE _is_periodic                    boolean = inventory.is_periodic_inventory(_office_id);
    DECLARE _cost_of_goods                  money_strict;
    DECLARE _tran_counter                   integer;
    DECLARE _transaction_code               text;
    DECLARE _shipping_charge                money_strict2;
    DECLARE this                            RECORD;
    DECLARE _cash_repository_id             integer;
    DECLARE _cash_account_id                integer;
    DECLARE _is_cash                        boolean = false;
    DECLARE _is_credit                      boolean = false;
    DECLARE _gift_card_id                   integer;
    DECLARE _gift_card_balance              decimal(24, 4);
    DECLARE _coupon_id                      integer;
    DECLARE _coupon_discount                decimal(24, 4);
    
BEGIN        
    _default_currency_code                  := core.get_currency_code_by_office_id(_office_id);
    _cash_account_id                        := inventory.get_cash_account_id_by_store_id(_store_id);
    _cash_repository_id                     := inventory.get_cash_repository_id_by_store_id(_store_id);
    _is_cash                                := finance.is_cash_account_id(_cash_account_id);    

    _coupon_id                              := sales.get_active_coupon_id_by_coupon_code(_coupon_code);
    _gift_card_id                           := sales.get_gift_card_id_by_gift_card_number(_gift_card_number);
    _gift_card_balance                      := sales.get_gift_card_balance(_gift_card_id, _value_date);



    IF(COALESCE(_coupon_code, '') != '' AND COALESCE(_discount) > 0) THEN
        RAISE EXCEPTION 'Please do not specify discount rate when you mention coupon code';
    END IF;

    IF(NOT _is_credit AND NOT _is_cash) THEN
        RAISE EXCEPTION 'Cannot post sales. Invalid cash account mapping on store.'
        USING ERRCODE='P1302';
    END IF; 

    IF(NOT _is_cash) THEN
        _cash_repository_id                 := NULL;
    END IF;

    DROP TABLE IF EXISTS temp_checkout_details CASCADE;
    CREATE TEMPORARY TABLE temp_checkout_details
    (
        id                              SERIAL PRIMARY KEY,
        checkout_id                 bigint, 
        tran_type                       national character varying(2), 
        store_id                        integer,
        item_id                         integer, 
        quantity                        integer_strict,        
        unit_id                         integer,
        base_quantity                   decimal,
        base_unit_id                    integer,                
        price                           money_strict,
        cost_of_goods_sold              money_strict2 DEFAULT(0),
        discount                        money_strict2,
        shipping_charge                 money_strict2,
        sales_account_id                integer,
        sales_discount_account_id       integer,
        inventory_account_id            integer,
        cost_of_goods_sold_account_id   integer
    ) ON COMMIT DROP;
        
    INSERT INTO temp_checkout_details(store_id, item_id, quantity, unit_id, price, discount, shipping_charge)
    SELECT store_id, item_id, quantity, unit_id, price, discount, shipping_charge
    FROM explode_array(_details);


    UPDATE temp_checkout_details 
    SET
        tran_type                       = 'Cr',
        base_quantity                   = inventory.get_base_quantity_by_unit_id(unit_id, quantity),
        base_unit_id                    = inventory.get_root_unit_id(unit_id);


    UPDATE temp_checkout_details
    SET
        sales_account_id                = inventory.get_sales_account_id(item_id),
        sales_discount_account_id       = inventory.get_sales_discount_account_id(item_id),
        inventory_account_id            = inventory.get_inventory_account_id(item_id),
        cost_of_goods_sold_account_id   = inventory.get_cost_of_goods_sold_account_id(item_id);

    DROP TABLE IF EXISTS item_quantities_temp;
    CREATE TEMPORARY TABLE item_quantities_temp
    (
        item_id             integer,
        base_unit_id        integer,
        store_id            integer,
        total_sales         numeric,
        in_stock            numeric,
        maintain_inventory      boolean
    ) ON COMMIT DROP;

    INSERT INTO item_quantities_temp(item_id, base_unit_id, store_id, total_sales)
    SELECT item_id, base_unit_id, store_id, SUM(base_quantity)
    FROM temp_checkout_details
    GROUP BY item_id, base_unit_id, store_id;

    UPDATE item_quantities_temp
    SET maintain_inventory = inventory.items.maintain_inventory
    FROM inventory.items
    WHERE item_quantities_temp.item_id = inventory.items.item_id;
    
    UPDATE item_quantities_temp
    SET in_stock = inventory.count_item_in_stock(item_quantities_temp.item_id, item_quantities_temp.base_unit_id, item_quantities_temp.store_id)
    WHERE maintain_inventory;


    IF EXISTS
    (
        SELECT 0 FROM item_quantities_temp
        WHERE total_sales > in_stock
        AND maintain_inventory
        LIMIT 1
    ) THEN
        RAISE EXCEPTION 'Insufficient item quantity'
        USING ERRCODE='P5500';
    END IF;
    
    IF EXISTS
    (
            SELECT 1 FROM temp_checkout_details AS details
            WHERE inventory.is_valid_unit_id(details.unit_id, details.item_id) = false
            LIMIT 1
    ) THEN
        RAISE EXCEPTION 'Item/unit mismatch.'
        USING ERRCODE='P3201';
    END IF;

    SELECT SUM(COALESCE(discount, 0))                           INTO _discount_total FROM temp_checkout_details;
    SELECT SUM(COALESCE(price, 0) * COALESCE(quantity, 0))      INTO _grand_total FROM temp_checkout_details;
    SELECT SUM(COALESCE(shipping_charge, 0))                    INTO _shipping_charge FROM temp_checkout_details;

     
     _receivable                    := _grand_total - COALESCE(_discount_total, 0)+ COALESCE(_shipping_charge, 0);
    

    IF(_is_flat_discount AND _discount > _receivable) THEN
        RAISE EXCEPTION 'The discount amount cannot be greater than total amount.';
    ELSIF(NOT _is_flat_discount AND _discount > 100) THEN
        RAISE EXCEPTION 'The discount rate cannot be greater than 100.';    
    END IF;

    _coupon_discount                := _discount;

    IF(NOT _is_flat_discount AND COALESCE(_discount, 0) > 0) THEN
        _coupon_discount            := _receivable * (_discount/100);
    END IF;

    IF(COALESCE(_coupon_discount, 0) > 0) THEN
        _discount_total             := _discount_total + _coupon_discount;
        _receivable                 := _receivable - _coupon_discount;
    END IF;

    
    DROP TABLE IF EXISTS temp_transaction_details;
    CREATE TEMPORARY TABLE temp_transaction_details
    (
        transaction_master_id       BIGINT, 
        tran_type                   national character varying(2), 
        account_id                  integer, 
        statement_reference         text, 
        cash_repository_id          integer, 
        currency_code               national character varying(12), 
        amount_in_currency          money_strict, 
        local_currency_code         national character varying(12), 
        er                          decimal_strict, 
        amount_in_local_currency    money_strict
    ) ON COMMIT DROP;


    INSERT INTO temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
    SELECT 'Cr', sales_account_id, _statement_reference, _default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0)), 1, _default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0))
    FROM temp_checkout_details
    GROUP BY sales_account_id;

    IF(NOT _is_periodic) THEN
        --Perpetutal Inventory Accounting System

        UPDATE temp_checkout_details SET cost_of_goods_sold = inventory.get_cost_of_goods_sold(item_id, unit_id, store_id, quantity);
        
        SELECT SUM(cost_of_goods_sold) INTO _cost_of_goods
        FROM temp_checkout_details;

        IF(_cost_of_goods > 0) THEN
            INSERT INTO temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Dr', cost_of_goods_sold_account_id, _statement_reference, _default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, _default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
            FROM temp_checkout_details
            GROUP BY cost_of_goods_sold_account_id;

            INSERT INTO temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Cr', inventory_account_id, _statement_reference, _default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, _default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
            FROM temp_checkout_details
            GROUP BY inventory_account_id;
        END IF;
    END IF;

    IF(COALESCE(_shipping_charge, 0) > 0) THEN
        INSERT INTO temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Cr', inventory.get_account_id_by_shipper_id(_shipper_id), _statement_reference, _default_currency_code, _shipping_charge, 1, _default_currency_code, _shipping_charge;                
    END IF;


    IF(_discount_total > 0) THEN
        INSERT INTO temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Dr', sales_discount_account_id, _statement_reference, _default_currency_code, SUM(COALESCE(discount, 0)), 1, _default_currency_code, SUM(COALESCE(discount, 0))
        FROM temp_checkout_details
        GROUP BY sales_discount_account_id;
    END IF;

    INSERT INTO temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
    SELECT 'Dr', inventory.get_account_id_by_customer_id(_customer_id), _statement_reference, _default_currency_code, _receivable, 1, _default_currency_code, _receivable;

    
    _transaction_master_id  := nextval(pg_get_serial_sequence('finance.transaction_master', 'transaction_master_id'));
    _checkout_id        := nextval(pg_get_serial_sequence('inventory.checkouts', 'checkout_id'));    
    _tran_counter           := finance.get_new_transaction_counter(_value_date);
    _transaction_code       := finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id);

    UPDATE temp_transaction_details     SET transaction_master_id   = _transaction_master_id;
    UPDATE temp_checkout_details           SET checkout_id         = _checkout_id;
    
    INSERT INTO finance.transaction_master(transaction_master_id, transaction_counter, transaction_code, book, value_date, book_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference) 
    SELECT _transaction_master_id, _tran_counter, _transaction_code, _book_name, _value_date, _book_date, _user_id, _login_id, _office_id, _cost_center_id, _reference_number, _statement_reference;


    INSERT INTO finance.transaction_details(value_date, book_date, office_id, transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency)
    SELECT _value_date, _book_date, _office_id, transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency
    FROM temp_transaction_details
    ORDER BY tran_type DESC;

    INSERT INTO inventory.checkouts(transaction_book, value_date, book_date, checkout_id, transaction_master_id, shipper_id, posted_by, office_id, discount)
    SELECT _book_name, _value_date, _book_date, _checkout_id, _transaction_master_id, _shipper_id, _user_id, _office_id, _coupon_discount;

    FOR this IN SELECT * FROM temp_checkout_details ORDER BY id
    LOOP
        _checkout_detail_id        := nextval(pg_get_serial_sequence('inventory.checkout_details', 'checkout_detail_id'));

        INSERT INTO inventory.checkout_details(checkout_detail_id, value_date, book_date, checkout_id, transaction_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, cost_of_goods_sold, discount, shipping_charge)
        SELECT _checkout_detail_id, _value_date, _book_date, this.checkout_id, this.tran_type, this.store_id, this.item_id, this.quantity, this.unit_id, this.base_quantity, this.base_unit_id, this.price, COALESCE(this.cost_of_goods_sold, 0), this.discount, this.shipping_charge 
        FROM temp_checkout_details
        WHERE id = this.id;        
    END LOOP;


    INSERT INTO sales.sales(price_type_id, counter_id, cash_repository_id, sales_order_id, sales_quotation_id, transaction_master_id, checkout_id, customer_id, salesperson_id, coupon_id, is_flat_discount, discount, total_discount_amount, is_credit, payment_term_id, tender, change, check_number, check_date, check_bank_name, check_amount, gift_card_id)
    SELECT _price_type_id, _counter_id, _cash_repository_id, _sales_order_id, _sales_quotation_id, _transaction_master_id, _checkout_id, _customer_id, _user_id, _coupon_id, _is_flat_discount, _discount, _discount_total, _is_credit, _payment_term_id, _tender, _change, _check_number, _check_date, _check_bank_name, _check_amount, _gift_card_id;
    
    
    PERFORM finance.auto_verify(_transaction_master_id, _office_id);

    IF(NOT _is_credit) THEN
        PERFORM sales.post_receipt
        (
            _user_id, 
            _office_id, 
            _login_id,
            _customer_id,
            _default_currency_code, 
            1.0, 
            1.0,
            _reference_number, 
            _statement_reference, 
            _cost_center_id,
            _cash_account_id,
            _cash_repository_id,
            _value_date,
            _book_date,
            _receivable,
            _tender,
            _change,
            _check_amount,
            _check_bank_name,
            _check_number,
            _check_date,
            _gift_card_number,
            _store_id,
            _transaction_master_id
        );

        
    ELSE
        PERFORM sales.settle_customer_due(_customer_id, _office_id);
    END IF;

    RETURN _transaction_master_id;
END
$$
LANGUAGE plpgsql;




-- SELECT * FROM sales.post_sales
-- (
--     1, 1, 1, 1, '1-1-2020', '1-1-2020', 1, 'asdf', 'Test', 
--     500000,2000, 1, 500000, 'Bank', 'C001', '1-1-2020', '234234234',
--     inventory.get_customer_id_by_customer_code('DEF'), 1, 1, 1,
--     '', true, 1000,
--     ARRAY[
--     ROW(1, 'Dr', 1, 1, 1,180000, 0, 200)::sales.sales_detail_type,
--     ROW(1, 'Dr', 2, 1, 7,130000, 300, 30)::sales.sales_detail_type,
--     ROW(1, 'Dr', 3, 1, 1,110000, 5000, 50)::sales.sales_detail_type],
--     NULL,
--     NULL
-- );



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/03.menus/menus.sql --<--<--
DELETE FROM auth.menu_access_policy
WHERE menu_id IN
(
    SELECT menu_id FROM core.menus
    WHERE app_name = 'Sales'
);

DELETE FROM auth.group_menu_access_policy
WHERE menu_id IN
(
    SELECT menu_id FROM core.menus
    WHERE app_name = 'Sales'
);

DELETE FROM core.menus
WHERE app_name = 'Sales';


SELECT * FROM core.create_app('Sales', 'Sales', '1.0', 'MixERP Inc.', 'December 1, 2015', 'shipping blue', '/dashboard/sales/tasks/entry', NULL::text[]);

SELECT * FROM core.create_menu('Sales', 'Tasks', '', 'lightning', '');
SELECT * FROM core.create_menu('Sales', 'Sales Entry', '/dashboard/sales/tasks/entry', 'user', 'Tasks');
SELECT * FROM core.create_menu('Sales', 'Sales Returns', '/dashboard/sales/tasks/return', 'ticket', 'Tasks');
SELECT * FROM core.create_menu('Sales', 'Sales Quotation', '/dashboard/sales/tasks/quotation', 'food', 'Tasks');
SELECT * FROM core.create_menu('Sales', 'Sales Orders', '/dashboard/sales/tasks/orders', 'keyboard', 'Tasks');
SELECT * FROM core.create_menu('Sales', 'Sales Entry Verification', '/dashboard/sales/tasks/entry/verification', 'keyboard', 'Tasks');
SELECT * FROM core.create_menu('Sales', 'Sales Return Verification', '/dashboard/sales/tasks/return/verification', 'keyboard', 'Tasks');
SELECT * FROM core.create_menu('Sales', 'Check Clearing', '/dashboard/sales/tasks/checks/checks-clearing', 'keyboard', 'Tasks');

SELECT * FROM core.create_menu('Sales', 'Customer Loyalty', 'square outline', 'configure', '');
SELECT * FROM core.create_menu('Sales', 'Gift Cards', '/dashboard/sales/loyalty/gift-cards', 'users', 'Customer Loyalty');
SELECT * FROM core.create_menu('Sales', 'Add Funds to Gift Card', '/dashboard/loyalty/tasks/gift-cards/add-fund', 'keyboard', 'Customer Loyalty');
SELECT * FROM core.create_menu('Sales', 'Sales Coupons', '/dashboard/sales/loyalty/coupons', 'users', 'Customer Loyalty');
SELECT * FROM core.create_menu('Sales', 'Loyalty Point Configuration', '/dashboard/sales/loyalty/points', 'users', 'Customer Loyalty');

SELECT * FROM core.create_menu('Sales', 'Setup', 'square outline', 'configure', '');
SELECT * FROM core.create_menu('Sales', 'Customer Types', '/dashboard/sales/setup/customer-types', 'users', 'Setup');
SELECT * FROM core.create_menu('Sales', 'Customers', '/dashboard/sales/setup/customers', 'users', 'Setup');
SELECT * FROM core.create_menu('Sales', 'Price Types', '/dashboard/sales/setup/price-types', 'users', 'Setup');
SELECT * FROM core.create_menu('Sales', 'Selling Prices', '/dashboard/sales/setup/selling-prices', 'users', 'Setup');
SELECT * FROM core.create_menu('Sales', 'Late Fee', '/dashboard/sales/setup/late-fee', 'users', 'Setup');
SELECT * FROM core.create_menu('Sales', 'Payment Terms', '/dashboard/sales/setup/payment-terms', 'users', 'Setup');
SELECT * FROM core.create_menu('Sales', 'Cashiers', '/dashboard/sales/setup/cashiers', 'users', 'Setup');

SELECT * FROM core.create_menu('Sales', 'Reports', '', 'configure', '');
SELECT * FROM core.create_menu('Sales', 'All Gift Cards', '/dashboard/sales/reports/gift-cards/account-statement', 'money', 'Reports');
SELECT * FROM core.create_menu('Sales', 'Gift Card Usage Statement', '/dashboard/sales/reports/gift-cards/account-statement', 'money', 'Reports');
SELECT * FROM core.create_menu('Sales', 'Customer Account Statement', '/dashboard/sales/reports/customer/account-statement', 'money', 'Reports');
SELECT * FROM core.create_menu('Sales', 'Credit Statement', '/dashboard/sales/reports/credit-statement', 'money', 'Reports');
SELECT * FROM core.create_menu('Sales', 'Credit Statement', '/dashboard/sales/reports/credit-statement', 'money', 'Reports');
SELECT * FROM core.create_menu('Sales', 'Top Selling Items', '/dashboard/sales/reports/sales-account-statement', 'money', 'Reports');
SELECT * FROM core.create_menu('Sales', 'Sales by Office', '/dashboard/sales/reports/sales-account-statement', 'money', 'Reports');


SELECT * FROM auth.create_app_menu_policy
(
    'Admin', 
    core.get_office_id_by_office_name('Default'), 
    'Sales',
    '{*}'::text[]
);



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/04.default-values/01.default-values.sql --<--<--


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.reports/cinesys.sales_by_cashier_view.sql --<--<--


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.scrud-views/sales.cashier_scrud_view.sql --<--<--
DROP VIEW IF EXISTS sales.cashier_scrud_view;

CREATE VIEW sales.cashier_scrud_view
AS
SELECT
    sales.cashiers.cashier_id,
    sales.cashiers.cashier_code,
    account.users.name AS associated_user,
    inventory.counters.counter_code || ' (' || inventory.counters.counter_name || ')' AS counter,
    sales.cashiers.valid_from,
    sales.cashiers.valid_till
FROM sales.cashiers
INNER JOIN account.users
ON account.users.user_id = sales.cashiers.associated_user_id
INNER JOIN inventory.counters
ON inventory.counters.counter_id = sales.cashiers.counter_id
WHERE NOT sales.cashiers.deleted;

-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.scrud-views/sales.item_selling_price_scrud_view.sql --<--<--
DROP VIEW IF EXISTS sales.item_selling_price_scrud_view;

CREATE VIEW sales.item_selling_price_scrud_view
AS
SELECT 
    sales.item_selling_prices.item_selling_price_id,
    inventory.items.item_code || ' (' || inventory.items.item_name || ')' AS item,
    inventory.units.unit_code || ' (' || inventory.units.unit_name || ')' AS unit,
    inventory.customer_types.customer_type_code || ' (' || inventory.customer_types.customer_type_name || ')' AS customer_type,
    sales.price_types.price_type_code || ' (' || sales.price_types.price_type_name || ')' AS price_type,
    sales.item_selling_prices.includes_tax,
    sales.item_selling_prices.price
FROM sales.item_selling_prices
INNER JOIN inventory.items
ON inventory.items.item_id = sales.item_selling_prices.item_id
INNER JOIN inventory.units
ON inventory.units.unit_id = sales.item_selling_prices.unit_id
INNER JOIN inventory.customer_types
ON inventory.customer_types.customer_type_id = sales.item_selling_prices.customer_type_id
INNER JOIN sales.price_types
ON sales.price_types.price_type_id = sales.item_selling_prices.price_type_id
WHERE NOT sales.item_selling_prices.deleted;


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.scrud-views/sales.payment_term_scrud_view.sql --<--<--
DROP VIEW IF EXISTS sales.payment_term_scrud_view;

CREATE VIEW sales.payment_term_scrud_view
AS
SELECT
    sales.payment_terms.payment_term_id,
    sales.payment_terms.payment_term_code,
    sales.payment_terms.payment_term_name,
    sales.payment_terms.due_on_date,
    sales.payment_terms.due_days,
    due_fequency.frequency_code || ' (' || due_fequency.frequency_name || ')' AS due_fequency,
    sales.payment_terms.grace_period,
    sales.late_fee.late_fee_code || ' (' || sales.late_fee.late_fee_name || ')' AS late_fee,
    late_fee_frequency.frequency_code || ' (' || late_fee_frequency.frequency_name || ')' AS late_fee_frequency
FROM sales.payment_terms
INNER JOIN finance.frequencies AS due_fequency
ON due_fequency.frequency_id = sales.payment_terms.due_frequency_id
INNER JOIN finance.frequencies AS late_fee_frequency
ON late_fee_frequency.frequency_id = sales.payment_terms.late_fee_posting_frequency_id
INNER JOIN sales.late_fee
ON sales.late_fee.late_fee_id = sales.payment_terms.late_fee_id
WHERE NOT sales.payment_terms.deleted;



-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.views/sales.item_view.sql --<--<--
DROP VIEW IF EXISTS sales.item_view;

CREATE VIEW sales.item_view
AS
SELECT
    inventory.items.item_id,
    inventory.items.item_code,
    inventory.items.item_name,
    inventory.items.barcode,
    inventory.items.item_group_id,
    inventory.item_groups.item_group_name,
    inventory.item_types.item_type_id,
    inventory.item_types.item_type_name,
    inventory.items.brand_id,
    inventory.brands.brand_name,
    inventory.items.preferred_supplier_id,
    inventory.items.unit_id,
    array_to_string(inventory.get_associated_unit_list(inventory.items.unit_id), ',') AS valid_units,
    inventory.units.unit_code,
    inventory.units.unit_name,
    inventory.items.hot_item,
    inventory.items.cost_price,
    inventory.items.photo
FROM inventory.items
INNER JOIN inventory.item_groups
ON inventory.item_groups.item_group_id = inventory.items.item_group_id
INNER JOIN inventory.item_types
ON inventory.item_types.item_type_id = inventory.items.item_type_id
INNER JOIN inventory.brands
ON inventory.brands.brand_id = inventory.items.brand_id
INNER JOIN inventory.units
ON inventory.units.unit_id = inventory.items.unit_id
WHERE NOT inventory.items.deleted
AND inventory.items.allow_sales;


-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/99.ownership.sql --<--<--
DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_tables 
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND tableowner <> 'frapid_db_user'
    LOOP
        EXECUTE 'ALTER TABLE '|| this.schemaname || '.' || this.tablename ||' OWNER TO frapid_db_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;

DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT 'ALTER '
        || CASE WHEN p.proisagg THEN 'AGGREGATE ' ELSE 'FUNCTION ' END
        || quote_ident(n.nspname) || '.' || quote_ident(p.proname) || '(' 
        || pg_catalog.pg_get_function_identity_arguments(p.oid) || ') OWNER TO frapid_db_user;' AS sql
    FROM   pg_catalog.pg_proc p
    JOIN   pg_catalog.pg_namespace n ON n.oid = p.pronamespace
    WHERE  NOT n.nspname = ANY(ARRAY['pg_catalog', 'information_schema'])
    LOOP        
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_views
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND viewowner <> 'frapid_db_user'
    LOOP
        EXECUTE 'ALTER VIEW '|| this.schemaname || '.' || this.viewname ||' OWNER TO frapid_db_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT 'ALTER SCHEMA ' || nspname || ' OWNER TO frapid_db_user;' AS sql FROM pg_namespace
    WHERE nspname NOT LIKE 'pg_%'
    AND nspname <> 'information_schema'
    LOOP
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;



DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT      'ALTER TYPE ' || n.nspname || '.' || t.typname || ' OWNER TO frapid_db_user;' AS sql
    FROM        pg_type t 
    LEFT JOIN   pg_catalog.pg_namespace n ON n.oid = t.typnamespace 
    WHERE       (t.typrelid = 0 OR (SELECT c.relkind = 'c' FROM pg_catalog.pg_class c WHERE c.oid = t.typrelid)) 
    AND         NOT EXISTS(SELECT 1 FROM pg_catalog.pg_type el WHERE el.oid = t.typelem AND el.typarray = t.oid)
    AND         typtype NOT IN ('b')
    AND         n.nspname NOT IN ('pg_catalog', 'information_schema')
    LOOP
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_tables 
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND tableowner <> 'report_user'
    LOOP
        EXECUTE 'GRANT SELECT ON TABLE '|| this.schemaname || '.' || this.tablename ||' TO report_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;

DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT 'GRANT EXECUTE ON '
        || CASE WHEN p.proisagg THEN 'AGGREGATE ' ELSE 'FUNCTION ' END
        || quote_ident(n.nspname) || '.' || quote_ident(p.proname) || '(' 
        || pg_catalog.pg_get_function_identity_arguments(p.oid) || ') TO report_user;' AS sql
    FROM   pg_catalog.pg_proc p
    JOIN   pg_catalog.pg_namespace n ON n.oid = p.pronamespace
    WHERE  NOT n.nspname = ANY(ARRAY['pg_catalog', 'information_schema'])
    LOOP        
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_views
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND viewowner <> 'report_user'
    LOOP
        EXECUTE 'GRANT SELECT ON '|| this.schemaname || '.' || this.viewname ||' TO report_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT 'GRANT USAGE ON SCHEMA ' || nspname || ' TO report_user;' AS sql FROM pg_namespace
    WHERE nspname NOT LIKE 'pg_%'
    AND nspname <> 'information_schema'
    LOOP
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;
