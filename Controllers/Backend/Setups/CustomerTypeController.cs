using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Sales.Controllers.Backend.Setups
{
    public class CustomerTypeController : SalesDashboardController
    {
        [Route("dashboard/sales/setup/customer-types")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/CustomerTypes.cshtml", this.Tenant));
        }
    }
}