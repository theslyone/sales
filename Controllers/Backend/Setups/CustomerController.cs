using System.Collections.Generic;
using System.Dynamic;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.Dashboard;
using Frapid.WebsiteBuilder.ViewModels;
using MixERP.Sales.ViewModels;
using SearchResult = MixERP.Sales.ViewModels.SearchResult;

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
        public async Task<ActionResult> SearchCustomer(string query)
        {
            try
            {
                List<SearchResult> result = await DAL.Backend.Service.SearchCustomer.SearchCustomers(this.Tenant, query.Replace("\\","").Trim()).ConfigureAwait(false);

                return this.Ok(result);
            }
            catch (System.Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}