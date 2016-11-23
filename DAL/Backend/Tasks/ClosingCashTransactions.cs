using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using Frapid.NPoco;
using MixERP.Sales.DTO;

namespace MixERP.Sales.DAL.Backend.Tasks
{
    public static class ClosingCashTransactions
    {
        public static async Task<List<SalesView>> GetCashSalesViewAsync(string tenant, int userId, DateTime transacitonDate)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                return await db.Query<SalesView>().Where
                    (
                        x => x.Tender > 0 
                        && x.VerificationStatusId > 0
                        && x.ValueDate == transacitonDate.Date
                    ).ToListAsync().ConfigureAwait(false);
            }
        }

        public static async Task<ClosingCash> GetAsync(string tenant, int userId, DateTime transactionDate)
        {
            string sql = "SELECT * FROM sales.closing_cash WHERE user_id=@0 AND transaction_date=@1";
            var result = await Factory.GetAsync<ClosingCash>(tenant, sql, userId, transactionDate).ConfigureAwait(false);
            return result.FirstOrDefault();
        }

        public static async Task AddAsync(string tenant, ClosingCash model)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                db.BeginTransaction();

                await db.InsertAsync("sales.closing_cash", "closing_cash_id", true, model).ConfigureAwait(false);

                var sql = new Sql("UPDATE sales.opening_cash SET closed=@0", true);
                sql.Where("user_id=@0 AND transaction_date=@1", model.UserId, model.TransactionDate);

                await db.ExecuteAsync(sql).ConfigureAwait(false);

                db.CompleteTransaction();
            }
        }

    }
}