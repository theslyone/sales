INSERT INTO sales.late_fee(late_fee_code, late_fee_name, is_flat_amount, rate)
SELECT '15F', '15% fine', false, 15;

INSERT INTO sales.price_types(price_type_code, price_type_name)
SELECT 'RET', 'Retail'      UNION ALL
SELECT 'WHO', 'Wholesale';

INSERT INTO sales.payment_terms(payment_term_code, payment_term_name, due_on_date, due_days, grace_period, late_fee_id)
SELECT '07DC', '7 day credit', true,    7, 5, sales.get_late_fee_id_by_late_fee_code('15F') UNION ALL
SELECT '15DC', '15 day credit', true,   30, 5, sales.get_late_fee_id_by_late_fee_code('15F') UNION ALL
SELECT '30DC', '30 day credit', true,   30, 7, sales.get_late_fee_id_by_late_fee_code('15F');

INSERT INTO sales.gift_cards(gift_card_number, payable_account_id, first_name, middle_name, last_name)
SELECT '123456', finance.get_account_id_by_account_number('20100'), 'John', '', 'Doe';
