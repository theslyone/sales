using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.Dashboard;
using MixERP.Sales.DAL.Backend.Service;

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

        [Route("dashboard/sales/setup/customer-search/{query}")]
        public async Task<ActionResult> SearchCustomerAsync(string query)
        {
            try
            {
                var result = await Customers.SearchAsync(this.Tenant, query.Replace("\\", "").Trim()).ConfigureAwait(false);

                return this.Ok(result);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}