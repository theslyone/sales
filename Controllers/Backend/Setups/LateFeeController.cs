using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Sales.Controllers.Backend.Setups
{
    public class LateFeeController : SalesDashboardController
    {
        [Route("dashboard/sales/setup/late-fee")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/LateFee.cshtml", this.Tenant));
        }
    }
}