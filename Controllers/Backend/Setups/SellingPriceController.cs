using System.Web.Mvc;
using Frapid.Dashboard;
using Frapid.DataAccess.Models;

namespace MixERP.Sales.Controllers.Backend.Setups
{
    public class SellingPriceController : SalesDashboardController
    {
        [Route("dashboard/sales/setup/selling-prices")]
        [MenuPolicy]
        [AccessPolicy("sales", "item_selling_prices", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/SellingPrices.cshtml", this.Tenant));
        }
    }
}