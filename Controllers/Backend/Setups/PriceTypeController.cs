using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Sales.Controllers.Backend.Setups
{
    public class PriceTypeController : SalesDashboardController
    {
        [Route("dashboard/sales/setup/price-types")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/PriceTypes.cshtml", this.Tenant));
        }
    }
}