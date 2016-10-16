using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Sales.Controllers.Backend.Setups
{
    public class SellingPriceController : SalesDashboardController
    {
        [Route("dashboard/sales/setup/selling-prices")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/SellingPrices.cshtml", this.Tenant));
        }
    }
}