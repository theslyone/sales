window.prepareChecklist({
    TranId: window.tranId,
    Title: "Sales Return Checklist #" + window.tranId,
    ViewText: "View Sales Returns",
    ViewUrl: "/dashboard/sales/tasks/return",
    ReportPath: "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Return.xml?transaction_master_id=" + window.tranId
});