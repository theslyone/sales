using System.Web.Mvc;
using Frapid.Areas;
using Frapid.Dashboard;

namespace MixERP.Sales.Controllers.Backend.Tasks
{
    public class CustomerSearchController : FrapidController
    {
        [Route("dashboard/sales/setup/customers/search")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/entry")]
        public ActionResult Index()
        {
            return this.View("/Areas/MixERP.Sales/Views/Setup/CustomerSearch.cshtml");
        }
    }
}