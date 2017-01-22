window.prepareChecklist({
    TranId: window.tranId,
    Title: "Sales Quotation Checklist #" + window.tranId,
    ViewText: "View Sales Quotations",
    ViewUrl: "/dashboard/sales/tasks/quotation",
    AddNewText: "Add New Sales Quotation",
    AddNewUrl: "/dashboard/sales/tasks/quotation/new",
    ReportPath: "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Quotation.xml?quotation_id=" + window.tranId
});

$(".withdraw.button").remove();
