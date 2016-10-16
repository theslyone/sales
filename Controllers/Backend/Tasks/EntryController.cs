using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Sales.Controllers.Backend.Tasks
{
    public class EntryController : SalesDashboardController
    {
        [Route("dashboard/sales/tasks/entry/checklist/{tranId}")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/entry")]
        public ActionResult CheckList(long tranId)
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Entry/CheckList.cshtml", this.Tenant), tranId);
        }

        [Route("dashboard/sales/tasks/entry")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Entry/Index.cshtml", this.Tenant));
        }

        [Route("dashboard/sales/tasks/entry/new")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/entry")]
        public ActionResult New()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Entry/New.cshtml", this.Tenant));
        }

        //public async Task<ActionResult> PostAsync(Sales model)
        //[HttpPost]

        //[Route("dashboard/sales/tasks/entry/new")]
        //{
        //    if (!this.ModelState.IsValid)
        //    {
        //        return this.InvalidModelState();
        //    }

        //    var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

        //    model.UserId = meta.UserId;
        //    model.OfficeId = meta.OfficeId;
        //    model.LoginId = meta.LoginId;

        //    long tranId = await DAL.Backend.Tasks.Sales.PostAsync(this.Tenant, model).ConfigureAwait(true);
        //    return this.Ok(tranId);
        //}
    }
}