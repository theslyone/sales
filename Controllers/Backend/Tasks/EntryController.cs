using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Dashboard;
using Frapid.Areas.CSRF;
using Frapid.DataAccess.Models;

namespace MixERP.Sales.Controllers.Backend.Tasks
{
    [AntiForgery]
    public sealed class EntryController : SalesDashboardController
    {
        [Route("dashboard/sales/tasks/entry/checklist/{tranId}")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/entry")]
        [AccessPolicy("sales", "sales", AccessTypeEnum.Read)]
        public ActionResult CheckList(long tranId)
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Entry/CheckList.cshtml", this.Tenant), tranId);
        }

        [Route("dashboard/sales/tasks/entry")]
        [MenuPolicy]
        [AccessPolicy("sales", "sales", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Entry/Index.cshtml", this.Tenant));
        }

        [Route("dashboard/sales/tasks/entry/verification")]
        [MenuPolicy]
        [AccessPolicy("sales", "sales", AccessTypeEnum.Verify)]
        public ActionResult Verification()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Entry/Verification.cshtml", this.Tenant));
        }

        [Route("dashboard/sales/tasks/entry/new")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/entry")]
        [AccessPolicy("sales", "sales", AccessTypeEnum.Read)]
        public ActionResult New()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Entry/New.cshtml", this.Tenant));
        }


        [HttpPost]
        [Route("dashboard/sales/tasks/entry/new")]
        [AccessPolicy("sales", "sales", AccessTypeEnum.Create)]
        public async Task<ActionResult> PostAsync(ViewModels.Sales model)
        {
            if (!this.ModelState.IsValid)
            {
                return this.InvalidModelState(this.ModelState);
            }

            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            model.UserId = meta.UserId;
            model.OfficeId = meta.OfficeId;
            model.LoginId = meta.LoginId;

            try
            {
                long tranId = await DAL.Backend.Tasks.SalesEntries.PostAsync(this.Tenant, model).ConfigureAwait(true);
                return this.Ok(tranId);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}