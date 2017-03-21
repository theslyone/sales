using System.Threading.Tasks;
using System.Web.Mvc;
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
            var model = await Items.GetItemsAsync(this.Tenant).ConfigureAwait(true);
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

            decimal model = await Items.GetSellingPriceAsync(this.Tenant, itemId, customerId, priceTypeId, unitId).ConfigureAwait(true);
            return this.Ok(model);
        }
    }
}