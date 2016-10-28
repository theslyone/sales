using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Sales.Controllers.Backend.Loyalty
{
    public class SalesCouponController : SalesDashboardController
    {
        [Route("dashboard/sales/loyalty/coupons")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Loyalty/Coupons/Index.cshtml", this.Tenant));
        }
    }
}