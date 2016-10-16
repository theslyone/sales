using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using MixERP.Sales.DTO;

namespace MixERP.Sales.DAL.Backend.Service
{
    public static class Items
    {
        public static async Task<List<ItemView>> GetItemsAsync(string tenant)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                return await db.Query<ItemView>().ToListAsync().ConfigureAwait(false);
            }
        }

        public static async Task<decimal> GetSellingPriceAsync(string tenant, int itemId, int customerTypeId, int priceTypeId, int unitId)
        {
            const string sql = "SELECT sales.get_item_selling_price(@0, @1, @2, @3);";
            return await Factory.ScalarAsync<decimal>(tenant, sql, itemId, customerTypeId, priceTypeId, unitId).ConfigureAwait(false);
        }
    }
}