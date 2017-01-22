window.prepareChecklist({
    TranId: window.tranId,
    Title: "Sales Order Checklist #" + window.tranId,
    ViewText: "View Sales Orders",
    ViewUrl: "/dashboard/sales/tasks/order",
    AddNewText: "Add New Sales Order",
    AddNewUrl: "/dashboard/sales/tasks/order/new",
    ReportPath: "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Order.xml?order_id=" + window.tranId
});

$(".withdraw.button").remove();
