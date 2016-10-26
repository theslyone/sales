using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Sales.Controllers.Backend.Loyalty
{
    public class GiftCardController : SalesDashboardController
    {
        [Route("dashboard/sales/loyalty/gift-cards")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Loyalty/GiftCards/Index.cshtml", this.Tenant));
        }

        [Route("dashboard/loyalty/tasks/gift-cards/add-fund")]
        [MenuPolicy]
        public ActionResult AddFund()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Loyalty/GiftCards/AddFund.cshtml", this.Tenant));
        }
    }
}