window.prepareView({
    Title: "Receipts",
    AddNewText: "Add New",
    AddNewUrl: "/dashboard/sales/tasks/receipt/new",
    ReturnText: "Return",
    Book: "Sales Receipt",
    ChecklistUrl: "/dashboard/sales/tasks/receipt/checklist/{tranId}",
    AdviceButtons: [
        {
            Title: "View Receipt",
            Href: "javascript:void(0);",
            OnClick: "showReceipt({tranId});"
        }
    ]
});

function showReceipt(tranId) {
    $(".advice.modal iframe").attr("src", "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Receipt.xml?transaction_master_id=" + tranId);

    setTimeout(function () {
        $(".advice.modal")
            .modal('setting', 'transition', 'horizontal flip')
            .modal("show");

    }, 300);
};