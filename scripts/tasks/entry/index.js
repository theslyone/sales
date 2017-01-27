window.prepareView({
    Title: window.translate("Sales"),
    AddNewText: window.translate("AddNew"),
    AddNewUrl: "/dashboard/sales/tasks/entry/new",
    ReturnText: "Return",
    ReturnUrl: "javascript:void(0);",
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

$("#ReturnButton").click(function () {
    function getSelectedItem() {
        const selected = $("#JournalView").find("input:checked").first();

        if (selected.length) {
            const row = selected.parent().parent().parent();
            const id = row.find("td:nth-child(3)").html();
            return parseInt(id);
        };

        return 0;
    };

    const selected = getSelectedItem();
    if (selected) {
        const url = "/dashboard/sales/tasks/return/new?Type=Return&TransactionMasterId=" + selected;
        document.location = url;
        return;
    };

    window.displayMessage(window.translate("PleaseSelectItemFromGrid"));
});

function showInvoice(tranId) {
    $(".advice.modal iframe").attr("src", "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Invoice.xml?transaction_master_id=" + tranId);

    setTimeout(function () {
        $(".advice.modal")
            .modal('setting', 'transition', 'horizontal flip')
            .modal("show");

    }, 300);
};