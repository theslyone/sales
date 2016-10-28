using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.DataAccess;
using Frapid.WebsiteBuilder.ViewModels;
using SearchResult = MixERP.Sales.ViewModels.SearchResult;

namespace MixERP.Sales.DAL.Backend.Service
{
    public static class SearchCustomer
    {
        public static async Task<List<ViewModels.SearchResult>> SearchCustomers(string tenant, string query)
        {
            const string sql = @"SELECT customer_name ""name"", customer_id ""value"" FROM inventory.customers
                WHERE UPPER(inventory.customers.customer_name)LIKE @0
                OR UPPER(inventory.customers.contact_address_line_1) LIKE @0
                OR UPPER(inventory.customers.contact_address_line_2) LIKE @0
                OR UPPER(inventory.customers.contact_street) LIKE @0
                OR UPPER(inventory.customers.contact_city) LIKE @0
                OR UPPER(inventory.customers.contact_phone_numbers) LIKE @0
                ORDER BY inventory.customers.customer_id
                LIMIT 5;";

            var result = (List<SearchResult>) await Factory.GetAsync<ViewModels.SearchResult>(tenant, sql, "%" + query.ToUpper() + "%").ConfigureAwait(false);
            return result;
        }
    }
}