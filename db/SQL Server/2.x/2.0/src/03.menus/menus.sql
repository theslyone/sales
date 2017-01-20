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


EXECUTE core.create_app 'Sales', 'Sales', '1.0', 'MixERP Inc.', 'December 1, 2015', 'shipping blue', '/dashboard/sales/tasks/entry', NULL;

EXECUTE core.create_menu 'Sales', 'Tasks', '', 'lightning', '';
EXECUTE core.create_menu 'Sales', 'Opening Cash', '/dashboard/sales/tasks/opening-cash', 'money', 'Tasks';
EXECUTE core.create_menu 'Sales', 'Sales Entry', '/dashboard/sales/tasks/entry', 'write', 'Tasks';
EXECUTE core.create_menu 'Sales', 'Receipt', '/dashboard/sales/tasks/receipt', 'checkmark box', 'Tasks';
EXECUTE core.create_menu 'Sales', 'Sales Returns', '/dashboard/sales/tasks/return', 'minus square', 'Tasks';
EXECUTE core.create_menu 'Sales', 'Sales Quotation', '/dashboard/sales/tasks/quotation', 'quote left', 'Tasks';
EXECUTE core.create_menu 'Sales', 'Sales Orders', '/dashboard/sales/tasks/order', 'file national character varying(1000) outline', 'Tasks';
EXECUTE core.create_menu 'Sales', 'Sales Entry Verification', '/dashboard/sales/tasks/entry/verification', 'checkmark', 'Tasks';
EXECUTE core.create_menu 'Sales', 'Receipt Verification', '/dashboard/sales/tasks/receipt/verification', 'checkmark', 'Tasks';
EXECUTE core.create_menu 'Sales', 'Sales Return Verification', '/dashboard/sales/tasks/return/verification', 'checkmark box', 'Tasks';
EXECUTE core.create_menu 'Sales', 'Check Clearing', '/dashboard/sales/tasks/checks/checks-clearing', 'minus square outline', 'Tasks';
EXECUTE core.create_menu 'Sales', 'EOD', '/dashboard/sales/tasks/eod', 'money', 'Tasks';

EXECUTE core.create_menu 'Sales', 'Customer Loyalty', 'square outline', 'user', '';
EXECUTE core.create_menu 'Sales', 'Gift Cards', '/dashboard/sales/loyalty/gift-cards', 'gift', 'Customer Loyalty';
EXECUTE core.create_menu 'Sales', 'Add Gift Card Fund', '/dashboard/loyalty/tasks/gift-cards/add-fund', 'pound', 'Customer Loyalty';
EXECUTE core.create_menu 'Sales', 'Verify Gift Card Fund', '/dashboard/loyalty/tasks/gift-cards/add-fund/verification', 'checkmark', 'Customer Loyalty';
EXECUTE core.create_menu 'Sales', 'Sales Coupons', '/dashboard/sales/loyalty/coupons', 'browser', 'Customer Loyalty';
--EXECUTE core.create_menu 'Sales', 'Loyalty Point Configuration', '/dashboard/sales/loyalty/points', 'selected radio', 'Customer Loyalty';

EXECUTE core.create_menu 'Sales', 'Setup', 'square outline', 'configure', '';
EXECUTE core.create_menu 'Sales', 'Customer Types', '/dashboard/sales/setup/customer-types', 'child', 'Setup';
EXECUTE core.create_menu 'Sales', 'Customers', '/dashboard/sales/setup/customers', 'street view', 'Setup';
EXECUTE core.create_menu 'Sales', 'Price Types', '/dashboard/sales/setup/price-types', 'ruble', 'Setup';
EXECUTE core.create_menu 'Sales', 'Selling Prices', '/dashboard/sales/setup/selling-prices', 'in cart', 'Setup';
EXECUTE core.create_menu 'Sales', 'Late Fee', '/dashboard/sales/setup/late-fee', 'alarm mute', 'Setup';
EXECUTE core.create_menu 'Sales', 'Payment Terms', '/dashboard/sales/setup/payment-terms', 'checked calendar', 'Setup';
EXECUTE core.create_menu 'Sales', 'Cashiers', '/dashboard/sales/setup/cashiers', 'male', 'Setup';

EXECUTE core.create_menu 'Sales', 'Reports', '', 'block layout', '';
EXECUTE core.create_menu 'Sales', 'Account Receivables', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/AccountReceivables.xml', 'certificate', 'Reports';
EXECUTE core.create_menu 'Sales', 'All Gift Cards', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/AllGiftCards.xml', 'certificate', 'Reports';
EXECUTE core.create_menu 'Sales', 'Gift Card Usage Statement', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/GiftCardUsageStatement.xml', 'columns', 'Reports';
EXECUTE core.create_menu 'Sales', 'Customer Account Statement', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/CustomerAccountStatement.xml', 'content', 'Reports';
EXECUTE core.create_menu 'Sales', 'Top Selling Items', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/TopSellingItems.xml', 'map signs', 'Reports';
EXECUTE core.create_menu 'Sales', 'Sales by Office', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/SalesByOffice.xml', 'building', 'Reports';
EXECUTE core.create_menu 'Sales', 'Customer Receipts', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/CustomerReceipts.xml', 'building', 'Reports';
EXECUTE core.create_menu 'Sales', 'Detailed Payament Report', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/DetailedPayamentReport.xml', 'bar chart', 'Reports';
EXECUTE core.create_menu 'Sales', 'Gift Card(s) Summary', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/GiftCardSummary.xml', 'list', 'Reports';
EXECUTE core.create_menu 'Sales', 'Quotation Status', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/QuotationStatus.xml', 'list', 'Reports';
EXECUTE core.create_menu 'Sales', 'Order Status', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/OrderStatus.xml', 'bar chart', 'Reports';


DECLARE @office_id integer = core.get_office_id_by_office_name('Default');
EXECUTE auth.create_app_menu_policy
'Admin', 
@office_id, 
'Sales',
'{*}';


GO
