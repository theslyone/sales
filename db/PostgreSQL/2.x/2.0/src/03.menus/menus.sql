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

