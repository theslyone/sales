﻿#pragma warning disable 1591
//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace ASP
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using System.Net;
    using System.Text;
    using System.Web;
    using System.Web.Helpers;
    using System.Web.Mvc;
    using System.Web.Mvc.Ajax;
    using System.Web.Mvc.Html;
    using System.Web.Routing;
    using System.Web.Security;
    using System.Web.UI;
    using System.Web.WebPages;
    using Frapid.Configuration;
    using Frapid.Dashboard;
    using Frapid.DataAccess;
    using Frapid.DbPolicy;
    using Frapid.Framework;
    using Frapid.i18n;
    using Frapid.Messaging;
    using Frapid.Mapper.Decorators;
    using Frapid.WebsiteBuilder;
    using MixERP.Sales;
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("RazorGenerator", "2.0.0.0")]
    [System.Web.WebPages.PageVirtualPathAttribute("~/Views/Shared/ReprintTicketModal.cshtml")]
    public partial class _Views_Shared_ReprintTicketModal_cshtml : System.Web.Mvc.WebViewPage<dynamic>
    {
        public _Views_Shared_ReprintTicketModal_cshtml()
        {
        }
        public override void Execute()
        {
WriteLiteral("<div");

WriteLiteral(" class=\"ui reprint ticket small modal\"");

WriteLiteral(">\r\n    <i");

WriteLiteral(" class=\"close icon\"");

WriteLiteral("></i>\r\n    <div");

WriteLiteral(" class=\"header\"");

WriteLiteral(">\r\n        Reprint Ticket\r\n    </div>\r\n    <div");

WriteLiteral(" class=\"content\"");

WriteLiteral(">\r\n        <div");

WriteLiteral(" class=\"ui big form\"");

WriteLiteral(">\r\n            <div");

WriteLiteral(" class=\"field\"");

WriteLiteral(">\r\n                <label>Enter Transaction Id</label>\r\n                <input");

WriteLiteral(" id=\"TicketTranIdInputText\"");

WriteLiteral(" class=\"integer\"");

WriteLiteral(" placeholder=\"Enter Transaction Id\"");

WriteLiteral(" type=\"text\"");

WriteLiteral(">\r\n            </div>\r\n            <button reprint-ticket-button");

WriteLiteral(" class=\"ui blue button\"");

WriteLiteral(">Reprint</button>\r\n            <button");

WriteLiteral(" onclick=\"$(this).parent().parent().parent().modal(\'hide\');\"");

WriteLiteral(" class=\"ui red button\"");

WriteLiteral(@">Close</button>
        </div>
    </div>
</div>
<script>
    function reprintTicket() {
        const id = $(""#TicketTranIdInputText"").val();

        if (!id) {
            return;
        };

        window.showTicket(id);
        $("".reprint.ticket.modal"").modal(""hide"");
    };

    $(""#TicketTranIdInputText"").keydown(function (e) {
        const code = e.keyCode ? e.keyCode : E.which;

        if (code === 13) {
            reprintTicket();
        };
    });

    $(""[reprint-ticket-button]"").unbind(""click"").bind(""click"", function () {
        reprintTicket();
    });
</script>");

        }
    }
}
#pragma warning restore 1591