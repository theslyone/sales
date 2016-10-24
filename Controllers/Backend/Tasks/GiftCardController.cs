using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Sales.Controllers.Backend.Tasks
{
    public class GiftCardController : SalesDashboardController
    {
        [Route("dashboard/sales/tasks/gift-cards")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/GiftCards/Index.cshtml", this.Tenant));
        }
    }
}