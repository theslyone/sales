window.prepareVerification({
    Title: window.translate("SalesVerification"),
    AddNewText: window.translate("AddNew"),
    AddNewUrl: "/dashboard/sales/tasks/entry/new",
    Book: "Sales Entry",
    ChecklistUrl: "/dashboard/sales/tasks/entry/checklist/{tranId}",
    AdviceButtons: [
        {
            Title: window.translate("ViewSalesInvoice"),
            Href: "javascript:void(0);",
            OnClick: "showInvoice({tranId});"
        }
    ]
});

function showInvoice(tranId) {
    $(".advice.modal iframe").attr("src", "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Invoice.xml?transaction_master_id=" + tranId);

    setTimeout(function () {
        $(".advice.modal")
            .modal('setting', 'transition', 'horizontal flip')
            .modal("show");

    }, 300);
};