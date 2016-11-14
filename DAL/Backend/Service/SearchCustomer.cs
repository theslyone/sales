using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.DataAccess;
using MixERP.Sales.ViewModels;

namespace MixERP.Sales.DAL.Backend.Service
{
    public static class Customers
    {
        public static async Task<List<CustomerSearchResult>> SearchAsync(string tenant, string query)
        {
            const string sql = @"SELECT 
                                    customer_id, 
                                    customer_code, 
                                    customer_name,
                                    COALESCE(photo, '/Static/images/mixerp/logo.png') AS photo,
                                    contact_phone_numbers AS phone_numbers
                                FROM inventory.customers
                                WHERE UPPER(inventory.customers.customer_name)LIKE @0
                                OR UPPER(inventory.customers.customer_code) LIKE @0
                                OR UPPER(inventory.customers.contact_address_line_1) LIKE @0
                                OR UPPER(inventory.customers.contact_address_line_2) LIKE @0
                                OR UPPER(inventory.customers.contact_street) LIKE @0
                                OR UPPER(inventory.customers.contact_city) LIKE @0
                                OR UPPER(inventory.customers.contact_phone_numbers) LIKE @0
                                ORDER BY inventory.customers.customer_id
                                LIMIT 10;";

            var result =  await Factory.GetAsync<CustomerSearchResult>(tenant, sql, "%" + query.ToUpper() + "%").ConfigureAwait(false);
            return result.ToList();
        }
    }
}