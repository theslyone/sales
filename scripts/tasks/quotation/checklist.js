window.prepareChecklist({
    TranId: window.tranId,
    Title: window.translate("SalesQuotationChecklist") + window.tranId,
    ViewText: window.translate("ViewSalesQuotations"),
    ViewUrl: "/dashboard/sales/tasks/quotation",
    AddNewText: window.translate("AddNewSalesQuotation"),
    AddNewUrl: "/dashboard/sales/tasks/quotation/new",
    ReportPath: "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Quotation.xml?quotation_id=" + window.tranId
});

$(".withdraw.button").remove();
