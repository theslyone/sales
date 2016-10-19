-->-->-- src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/01.types-domains-tables-and-constraints/tables-and-constraints.sql --<--<--
DROP SCHEMA IF EXISTS sales CASCADE;

CREATE SCHEMA sales;

--TODO: CREATE UNIQUE INDEXES

CREATE TABLE sales.late_fee
(
    late_fee_id                             SERIAL PRIMARY KEY,
    late_fee_code                           national character varying(24) NOT NULL,
    late_fee_name                           national character varying(500) NOT NULL,
    is_flat_amount                          boolean NOT NULL DEFAULT(false),
    rate                                    numeric(24,4) NOT NULL,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)    
);

CREATE TABLE sales.price_types
(
    price_type_id                           SERIAL PRIMARY KEY,
    price_type_code                         national character varying(24) NOT NULL,
    price_type_name                         national character varying(500) NOT NULL,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW()),
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
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW()),
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
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW()),
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
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW()),
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
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);



CREATE TABLE sales.sales
(
    sales_id                                BIGSERIAL PRIMARY KEY,
    checkout_id                             bigint NOT NULL REFERENCES inventory.checkouts,
    counter_id                              integer NOT NULL REFERENCES inventory.counters,
    customer_id                             integer REFERENCES inventory.customers,
	salesperson_id							integer REFERENCES account.users,
    is_credit                               boolean NOT NULL DEFAULT(false),
    payment_term_id                         integer REFERENCES sales.payment_terms,
    tender                                  decimal(24, 4) NOT NULL CHECK(tender > 0),
    change                                  decimal(24, 4) NOT NULL
);

CREATE TABLE sales.returns
(
    return_id                               BIGSERIAL PRIMARY KEY,
    sales_id                                bigint NOT NULL REFERENCES sales.sales,
    checkout_id                             bigint NOT NULL REFERENCES inventory.checkouts,
    counter_id                              integer NOT NULL REFERENCES inventory.counters,
    customer_id                             integer REFERENCES inventory.customers
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
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW()),
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
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW()),
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

SELECT * FROM core.create_menu('Sales', 'Payments', 'square outline', 'configure', '');
SELECT * FROM core.create_menu('Sales', 'Create Gift Cards', '/dashboard/sales/tasks/gift-cards', 'users', 'Payments');
SELECT * FROM core.create_menu('Sales', 'Add Funds to Gift Card', '/dashboard/sales/tasks/gift-cards/add-fund', 'keyboard', 'Payments');
SELECT * FROM core.create_menu('Sales', 'Check Clearing', '/dashboard/sales/tasks/checks/checks-clearing', 'keyboard', 'Payments');

SELECT * FROM core.create_menu('Sales', 'Setup', 'square outline', 'configure', '');
SELECT * FROM core.create_menu('Sales', 'Customer Types', '/dashboard/sales/setup/customer-types', 'users', 'Setup');
SELECT * FROM core.create_menu('Sales', 'Customers', '/dashboard/sales/setup/customers', 'users', 'Setup');
SELECT * FROM core.create_menu('Sales', 'Price Types', '/dashboard/sales/setup/price-types', 'users', 'Setup');
SELECT * FROM core.create_menu('Sales', 'Selling Prices', '/dashboard/sales/setup/selling-prices', 'users', 'Setup');
SELECT * FROM core.create_menu('Sales', 'Late Fee', '/dashboard/sales/setup/late-fee', 'users', 'Setup');
SELECT * FROM core.create_menu('Sales', 'Payment Terms', '/dashboard/sales/setup/payment-terms', 'users', 'Setup');
SELECT * FROM core.create_menu('Sales', 'Cashiers', '/dashboard/sales/setup/cashiers', 'users', 'Setup');

SELECT * FROM core.create_menu('Sales', 'Reports', '', 'configure', '');
SELECT * FROM core.create_menu('Sales', 'Gift Cards', '/dashboard/sales/reports/gift-cards/account-statement', 'money', 'Reports');
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
