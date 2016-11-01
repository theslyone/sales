using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.Dashboard.Controllers;
using MixERP.Sales.Models;

namespace MixERP.Sales.Controllers.Backend.Tasks
{
    public class SalesTicketController : BackendController
    {
        [Route("dashboard/sales/ticket/{tranId}")]
        public async Task<ActionResult> IndexAsync(long tranId)
        {
            if (tranId <= 0)
            {
                return this.HttpNotFound($"The ticket {tranId} could not be found.");
            }

            var model = await Tickets.GetTicketViewModelAsync(this.Tenant, tranId).ConfigureAwait(true);
            return this.View(this.GetRazorView<AreaRegistration>("Ticket/Index.cshtml", this.Tenant), model);
        }
    }
}