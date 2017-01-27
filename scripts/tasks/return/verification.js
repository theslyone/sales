window.prepareVerification({
    Title: window.translate("SalesReturnVerification"),
    Book: "Sales Return",
    ChecklistUrl: "/dashboard/sales/tasks/return/checklist/{tranId}",
    AdviceButtons: [
        {
            Title: window.translate("ViewSalesReturn"),
            Href: "javascript:void(0);",
            OnClick: "showReturn({tranId});"
        }
    ]
});

function showReturn(tranId) {
    $(".advice.modal iframe").attr("src",
        `/dashboard/reports/source/Areas/MixERP.Sales/Reports/Return.xml?transaction_master_id=${tranId}`);

    setTimeout(function() {
        $(".advice.modal")
            .modal("setting", "transition", "horizontal flip")
            .modal("show");

    }, 300);
};