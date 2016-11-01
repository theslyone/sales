using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using MixERP.Sales.DTO;

namespace MixERP.Sales.DAL.Backend.Tasks
{
    public static class Tickets
    {
        public static async Task<SalesView> GetSalesViewAsync(string tenant, long tranId)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                return await db.Query<SalesView>().Where(x => x.TransactionMasterId == tranId).FirstOrDefaultAsync().ConfigureAwait(false);
            }
        }

        public static async Task<List<CheckoutDetailView>> GetCheckoutDetailViewAsync(string tenant, long tranId)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                return await db.Query<CheckoutDetailView>().Where(x => x.TransactionMasterId == tranId).ToListAsync().ConfigureAwait(false);
            }
        }

        public static async Task<List<CouponView>> GetCouponViewAsync(string tenant, long tranId)
        {
            const string sql = "SELECT * FROM sales.coupon_view WHERE coupon_id IN (SELECT * FROM sales.get_avaiable_coupons_to_print(@0));";
            var awaiter = await Factory.GetAsync<CouponView>(tenant, sql, tranId).ConfigureAwait(false);
            return awaiter.ToList();
        }
    }
}