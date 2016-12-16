using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using Frapid.Mapper;
using Frapid.Mapper.Query.Select;
using MixERP.Sales.DTO;

namespace MixERP.Sales.DAL.Backend.Service
{
    public static class Items
    {
        public static async Task<IEnumerable<ItemView>> GetItemsAsync(string tenant)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("SELECT * FROM sales.item_view;");
                return await db.SelectAsync<ItemView>(sql).ConfigureAwait(false);
            }
        }

        public static async Task<decimal> GetSellingPriceAsync(string tenant, int itemId, int customerId, int priceTypeId, int unitId)
        {
            const string sql = "SELECT sales.get_item_selling_price(@0, inventory.get_customer_type_id_by_customer_id(@1), @2, @3);";
            return await Factory.ScalarAsync<decimal>(tenant, sql, itemId, customerId, priceTypeId, unitId).ConfigureAwait(false);
        }
    }
}