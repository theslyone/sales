using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using System.Web.UI;
using Frapid.ApplicationState.Cache;
using Frapid.Areas.Caching;
using Frapid.Dashboard.Controllers;
using MixERP.Sales.DAL.Backend.Widgets;

namespace MixERP.Sales.Controllers.Backend.Widgets
{
    public class TopCustomersController : BackendController
    {
        [Route("dashboard/sales/widgets/top-customers")]
        [FrapidOutputCache(Duration = 60 * 60, Location = OutputCacheLocation.Client)]
        public async Task<ActionResult> GetAsync()
        {
            var meta = await AppUsers.GetCurrentAsync();

            try
            {
                var model = await TopCustomers.GetAsync(this.Tenant, meta.OfficeId);
                return this.Ok(model);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}