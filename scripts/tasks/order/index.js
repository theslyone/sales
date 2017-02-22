function displayTable(target, data) {
    target.find("tbody").html("");

    function getCell(text, isDate) {
        const cell = $("<td />");

        cell.text(text);

        if (isDate) {
            if ((text || "").trim()) {
                cell.text(window.moment(new Date(text)).fromNow() || "");
                cell.attr("title", text);
            };
        };

        return cell;
    };

    function getActionCell(id) {
        const cell = $("<td />");

        const checklistAnchor = $(`<a title='${window.translate("ChecklistWindow")}'><i class='list icon'></i></a>`);
        const checklistUrl = "/dashboard/sales/tasks/order/checklist/{id}";
        checklistAnchor.attr("href", checklistUrl.replace("{id}", id));


        const covertToSalesAnchor = $(`<a title='${window.translate("ConvertSales")}'><i class='chevron circle right icon'></i></a>`);
        const convertToSalesUrl = "/dashboard/sales/tasks/entry/new?OrderId={id}";
        covertToSalesAnchor.attr("href", convertToSalesUrl.replace("{id}", id));


        const journalAdviceAnchor = $(`<a title='${window.translate("ViewOrder")}'><i class='print icon'></i></a>`);
        journalAdviceAnchor.attr("href", "javascript:void(0);");
        journalAdviceAnchor.attr("onclick", "showOrder(" + id + ");");

        cell.append(covertToSalesAnchor);
        cell.append(checklistAnchor);
        cell.append(journalAdviceAnchor);

        return cell;
    };


    $.each(data, function () {
        const item = this;

        const row = $("<tr />");

        row.append(getActionCell(item.Id));
        row.append(getCell(item.Id));
        row.append(getCell(item.Customer));
        row.append(getCell(item.ValueDate, true));
        row.append(getCell(item.ExpectedDate, true));
        row.append(getCell(item.ReferenceNumber));
        row.append(getCell(item.Terms));
        row.append(getCell(item.InternalMemo));
        row.append(getCell(item.PostedBy));
        row.append(getCell(item.Office));
        row.append(getCell(item.TransactionTs, true));

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
            const url = "/dashboard/sales/tasks/order/view";
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

function showOrder(id) {
    $(".modal iframe").attr("src", "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Order.xml?order_id=" + id);

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
