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
        public static async Task<IEnumerable<ItemView>> GetItemsAsync(string tenant, int officeId)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("SELECT *, finance.get_sales_tax_rate(@0) AS sales_tax_rate FROM sales.item_view;", officeId);
                return await db.SelectAsync<ItemView>(sql).ConfigureAwait(false);
            }
        }

        public static async Task<decimal> GetSellingPriceAsync(string tenant, int officeId,  int itemId, int customerId, int priceTypeId, int unitId)
        {
            const string sql = "SELECT sales.get_selling_price(@0, @1, @2, @3, @4);";
            return await Factory.ScalarAsync<decimal>(tenant, sql, officeId, itemId, customerId, priceTypeId, unitId).ConfigureAwait(false);
        }

        public static async Task<IEnumerable<ViewModels.ItemSerialNumber>> GetSerialNumbersAsync(string tenant, int itemId, int unitId, int storeId)
        {
            const string sql = @"SELECT serial_number_id, item_name, unit_code, batch_number, serial_number, expiry_date
                    FROM inventory.serial_numbers_view WHERE sales_transaction_id IS NULL
                    AND item_id=@0 AND unit_id=@1 AND store_id=@2 ORDER BY expiry_date ASC;";

            return await Factory.GetAsync<ViewModels.ItemSerialNumber>(tenant, sql, itemId, unitId, storeId)
                .ConfigureAwait(false);
        }
    }
}