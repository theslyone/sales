using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Sales.Controllers.Backend.Setups
{
    public class PaymentTermController : SalesDashboardController
    {
        [Route("dashboard/sales/setup/payment-terms")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/PaymentTerms.cshtml", this.Tenant));
        }
    }
}