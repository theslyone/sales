function displayTable(target, data) {
    target.find("tbody").html("");

    function getCell(text, isDate, hasTime) {
        const cell = $("<td />");

        cell.text(text);

        if (isDate) {
            const date = new Date(text);

            if (hasTime) {
                if ((text || "").trim()) {
                    cell.text(window.moment(date).fromNow() || "");
                    cell.attr("title", date.toLocaleString());
                };
            } else {
                cell.text(date.toLocaleDateString());
                cell.attr("title", text);
            };
        };

        return cell;
    };

    function getActionCell(id) {
        const cell = $("<td />");

        const covertToOrderAnchor = $(`<a title='${window.translate("ConvertOrder")}'><i class='arrow circle right icon'></i></a>`);
        const convertToOrderUrl = "/dashboard/sales/tasks/order/new?QuotationId={id}";
        covertToOrderAnchor.attr("href", convertToOrderUrl.replace("{id}", id));


        const covertToSalesAnchor = $(`<a title='${window.translate("ConvertSales")}'><i class='chevron circle right icon'></i></a>`);
        const convertToSalesUrl = "/dashboard/sales/tasks/entry/new?QuotationId={id}";
        covertToSalesAnchor.attr("href", convertToSalesUrl.replace("{id}", id));


        const checklistAnchor = $(`<a title='${window.translate("ChecklistWindow")}'><i class='list icon'></i></a>`);
        const checklistUrl = "/dashboard/sales/tasks/quotation/checklist/{id}";
        checklistAnchor.attr("href", checklistUrl.replace("{id}", id));


        const journalAdviceAnchor = $(`<a title='${window.translate("ViewQuotation")}'><i class='print icon'></i></a>`);
        journalAdviceAnchor.attr("href", "javascript:void(0);");
        journalAdviceAnchor.attr("onclick", "showQuotation(" + id + ");");

        cell.append(covertToOrderAnchor);
        cell.append(covertToSalesAnchor);
        cell.append(checklistAnchor);
        cell.append(journalAdviceAnchor);

        return cell;
    };

    const sorted = window.Enumerable.From(data)
        .OrderByDescending(function (x) {
            return new Date(x.ValueDate);
        }).ThenByDescending(function (x) {
            return new Date(x.TransactionTs);
        }).ToArray();

    $.each(sorted, function () {
        const item = this;

        const row = $("<tr />");

        row.append(getActionCell(item.Id));
        row.append(getCell(item.Id));
        row.append(getCell(item.Customer));
        row.append(getCell(item.ValueDate, true, false));
        row.append(getCell(item.ExpectedDate, true, false));
        row.append(getCell(item.ReferenceNumber));
        row.append(getCell(item.Terms));
        row.append(getCell(item.InternalMemo));
        row.append(getCell(item.PostedBy));
        row.append(getCell(item.Office));
        row.append(getCell(item.TransactionTs, true, true));

        target.find("tbody").append(row);
    });
};

function processQuery() {
    function getModel() {
        const form = window.serializeForm($("#Annotation"));
        return form;
    };

    function displayGrid(target) {
        function request(query) {
            const url = "/dashboard/sales/tasks/quotation/view";
            const data = JSON.stringify(query);
            return window.getAjaxRequest(url, "POST", data);
        };

        const query = getModel();

        const ajax = request(query);

        ajax.success(function (response) {
            displayTable(target, response);
            target.removeClass("loading");
        });

        ajax.fail(function (xhr) {
            window.logAjaxErrorMessage(xhr);
        });
    };

    const view = $("#JournalView").addClass("loading");

    displayGrid(view);
};

$("#ShowButton").off("click").on("click", function () {
    processQuery();
});

function showQuotation(id) {
    $(".modal iframe").attr("src", "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Quotation.xml?quotation_id=" + id);

    setTimeout(function () {
        $(".advice.modal")
            .modal('setting', 'transition', 'horizontal flip')
            .modal("show");

    }, 300);
};

window.loadDatepicker();

setTimeout(function () {
    processQuery();
}, 1000);
