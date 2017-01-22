(function () {
    const candidates = $("[data-allow-edit]");

    $.each(candidates, function () {
        const el = $(this);

        const allowEdit = el.attr("data-allow-edit").toLowerCase() === "true";
        el.prop("disabled", !allowEdit);
    });
})();

$(document).ready(function () {
    window.validator.initialize($(".ui.form"));
    $(".decimal").number(true, window.currencyDecimalPlaces, ".", "");
});


$("#SaveButton").off("click").on("click", function () {
    function request(model) {
        const url = "/dashboard/sales/tasks/opening-cash";
        const data = JSON.stringify(model);

        return window.getAjaxRequest(url, "POST", data);
    };

    const confirmed = confirm("Are you sure?");

    if (!confirmed) {
        return;
    };

    const model = window.serializeForm($(".ui.form"));
    const ajax = request(model);

    ajax.success(function () {
        window.displaySuccess();
    });

    ajax.fail(function (xhr) {
        alert(JSON.stringify(xhr));
    });
});