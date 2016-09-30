-->-->-- C:/Users/nirvan/Desktop/mixerp/frapid/src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/01.types-domains-tables-and-constraints/tables-and-constraints.sql --<--<--
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
    price                                   public.money_strict NOT NULL
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




-->-->-- C:/Users/nirvan/Desktop/mixerp/frapid/src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/03.menus/menus.sql --<--<--


-->-->-- C:/Users/nirvan/Desktop/mixerp/frapid/src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/04.default-values/01.default-values.sql --<--<--


-->-->-- C:/Users/nirvan/Desktop/mixerp/frapid/src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/05.reports/cinesys.sales_by_cashier_view.sql --<--<--


-->-->-- C:/Users/nirvan/Desktop/mixerp/frapid/src/Frapid.Web/Areas/MixERP.Sales/db/PostgreSQL/2.x/2.0/src/99.ownership.sql --<--<--
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
