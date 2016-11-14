using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Sales.Controllers.Backend.Setups
{
    public class CustomerController : SalesDashboardController
    {
        [Route("dashboard/sales/setup/customers")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/Customers.cshtml", this.Tenant));
        }
    }
}