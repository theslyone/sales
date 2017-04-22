using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using MixERP.Sales.DAL.Backend.Service;
using Frapid.Dashboard;
using Frapid.DataAccess.Models;

namespace MixERP.Sales.Controllers.Backend.Tasks
{
    public class ItemController : SalesDashboardController
    {
        [Route("dashboard/sales/tasks/items")]
        [AccessPolicy("sales", "item_view", AccessTypeEnum.Read)]
        public async Task<ActionResult> IndexAsync()
        {
            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);
            var model = await Items.GetItemsAsync(this.Tenant, meta.OfficeId).ConfigureAwait(true);
            return this.Ok(model);
        }

        [Route("dashboard/sales/tasks/selling-price/{itemId}/{customerId}/{priceTypeId}/{unitId}")]
        [AccessPolicy("sales", "item_selling_prices", AccessTypeEnum.Read)]
        public async Task<ActionResult> SellingPriceAsync(int itemId, int customerId, int priceTypeId, int unitId)
        {
            if (itemId < 0 || unitId < 0)
            {
                return this.InvalidModelState(this.ModelState);
            }

            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);
            decimal model = await Items.GetSellingPriceAsync(this.Tenant, meta.OfficeId, itemId, customerId, priceTypeId, unitId).ConfigureAwait(true);
            return this.Ok(model);
        }
    }
}