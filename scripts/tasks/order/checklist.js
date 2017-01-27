window.prepareChecklist({
    TranId: window.tranId,
    Title: window.translate("SalesOrderChecklist") + " #" + window.tranId,
    ViewText: window.translate("ViewSalesOrders"),
    ViewUrl: "/dashboard/sales/tasks/order",
    AddNewText: window.translate("AddNewSalesOrder"),
    AddNewUrl: "/dashboard/sales/tasks/order/new",
    ReportPath: "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Order.xml?order_id=" + window.tranId
});

$(".withdraw.button").remove();
