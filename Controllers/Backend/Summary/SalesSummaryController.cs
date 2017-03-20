using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Dashboard;
using Frapid.DataAccess.Models;

namespace MixERP.Sales.Controllers.Backend.Summary
{
    public sealed class SalesSummaryController : SalesDashboardController
    {
        [Route("dashboard/sales/summary/total-sales/today")]
        [AccessPolicy("sales", "sales", AccessTypeEnum.Read)]
        public async Task<ActionResult> GetTodaysTotalSalesAsync()
        {
            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            decimal sales = await DAL.Backend.Summary.Sales.GetTodaysTotalSalesAsync(this.Tenant, meta.OfficeId).ConfigureAwait(true);
            return this.Ok(sales);
        }
    }
}