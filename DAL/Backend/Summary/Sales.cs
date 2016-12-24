using System.Threading.Tasks;
using Frapid.DataAccess;
using Frapid.Mapper;

namespace MixERP.Sales.DAL.Backend.Summary
{
    public static class Sales
    {
        public static async Task<decimal> GetTodaysTotalSalesAsync(string tenant, int officeId)
        {
            var sql = new Sql("SELECT SUM(sales.sales.total_amount) AS todays_sales");
            sql.Append("FROM cafesys.checkouts");
            sql.Append("INNER JOIN sales.sales");
            sql.Append("ON sales.sales.sales_id = cafesys.checkouts.sales_id");
            sql.Append("INNER JOIN finance.transaction_master");
            sql.Append("ON finance.transaction_master.transaction_master_id = sales.sales.transaction_master_id");
            sql.Append("WHERE finance.transaction_master.verification_status_id > 0");
            sql.Append("AND finance.transaction_master.value_date = finance.get_value_date(finance.transaction_master.office_id)");
            sql.Append("AND finance.transaction_master.office_id = @0", officeId);

            return await Factory.ScalarAsync<decimal>(tenant, sql).ConfigureAwait(false);
        }
    }
}