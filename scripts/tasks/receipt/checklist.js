window.prepareChecklist({
    TranId: window.tranId,
    Title: "Receipt Checklist #" + window.tranId,
    ViewText: "View Receipts",
    ViewUrl: "/dashboard/sales/tasks/receipt",
    AddNewText: "Add New Receipt Entry",
    AddNewUrl: "/dashboard/sales/tasks/receipt/new",
    ReportPath: "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Receipt.xml?transaction_master_id=" + window.tranId
});
