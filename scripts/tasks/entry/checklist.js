window.prepareChecklist({
    TranId: window.tranId,
    Title: "Sales Checklist #" + window.tranId,
    ViewText: "View Sales",
    ViewUrl: "/dashboard/sales/tasks/entry",
    AddNewText: "Add New Sales Entry",
    AddNewUrl: "/dashboard/sales/tasks/entry/new",
    ReportPath: "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Invoice.xml?transaction_master_id=" + window.tranId
});
