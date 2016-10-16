using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Sales.Controllers.Backend.Setups
{
    public class CashierController : SalesDashboardController
    {
        [Route("dashboard/sales/setup/cashiers")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/Cashiers.cshtml", this.Tenant));
        }
    }
}