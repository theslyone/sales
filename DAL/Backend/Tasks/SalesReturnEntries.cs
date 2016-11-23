using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Framework.Extensions;
using MixERP.Sales.ViewModels;
using Npgsql;

namespace MixERP.Sales.DAL.Backend.Tasks
{
    public static class SalesReturnEntries
    {
        public static string GetParametersForDetails(List<SalesDetailType> details)
        {
            if (details == null)
            {
                return "NULL::sales.sales_detail_type";
            }

            var items = new Collection<string>();
            for (int i = 0; i < details.Count; i++)
            {
                items.Add(string.Format(CultureInfo.InvariantCulture,
                    "ROW(@StoreId{0}, @TransactionType{0}, @ItemId{0}, @Quantity{0}, @UnitId{0}, @Price{0}, @DiscountRate{0}, @ShippingCharge{0})::sales.sales_detail_type",
                    i.ToString(CultureInfo.InvariantCulture)));
            }

            return string.Join(",", items);
        }

        public static IEnumerable<NpgsqlParameter> AddParametersForDetails(List<SalesDetailType> details)
        {
            var parameters = new List<NpgsqlParameter>();

            if (details != null)
            {
                for (int i = 0; i < details.Count; i++)
                {
                    parameters.Add(new NpgsqlParameter("@StoreId" + i, details[i].StoreId));
                    parameters.Add(new NpgsqlParameter("@TransactionType" + i, "Cr"));//Inventory is decreased
                    parameters.Add(new NpgsqlParameter("@ItemId" + i, details[i].ItemId));
                    parameters.Add(new NpgsqlParameter("@Quantity" + i, details[i].Quantity));
                    parameters.Add(new NpgsqlParameter("@UnitId" + i, details[i].UnitId));
                    parameters.Add(new NpgsqlParameter("@Price" + i, details[i].Price));
                    parameters.Add(new NpgsqlParameter("@DiscountRate" + i, details[i].DiscountRate));
                    parameters.Add(new NpgsqlParameter("@ShippingCharge" + i, details[i].ShippingCharge));
                }
            }

            return parameters;
        }

        public static async Task<long> PostAsync(string tenant, SalesReturn model)
        {
            string connectionString = FrapidDbServer.GetConnectionString(tenant);
            string sql = @"SELECT * FROM sales.post_return
                            (
                                @TransactionMasterId::bigint, @OfficeId::integer, @UserId::integer, @LoginId::bigint, 
                                @ValueDate::date, @BookDate::date, 
                                @StoreId::integer, @CounterId::integer, @CustomerId, @PriceTypeId::integer,
                                @ReferenceNumber::national character varying(24), @StatementReference::text, 
                                ARRAY[{0}]
                            );";
            sql = string.Format(sql, GetParametersForDetails(model.Details));

            using (var connection = new NpgsqlConnection(connectionString))
            {
                using (var command = new NpgsqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@TransactionMasterId", model.TransactionMasterId);
                    command.Parameters.AddWithValue("@OfficeId", model.OfficeId);
                    command.Parameters.AddWithValue("@UserId", model.UserId);
                    command.Parameters.AddWithValue("@LoginId", model.LoginId);
                    command.Parameters.AddWithValue("@ValueDate", model.ValueDate);
                    command.Parameters.AddWithValue("@BookDate", model.BookDate);

                    command.Parameters.AddWithValue("@StoreId", model.StoreId);
                    command.Parameters.AddWithValue("@CounterId", model.CounterId);
                    command.Parameters.AddWithValue("@CustomerId", model.CustomerId);
                    command.Parameters.AddWithValue("@PriceTypeId", model.PriceTypeId);

                    command.Parameters.AddWithValue("@ReferenceNumber", model.ReferenceNumber);
                    command.Parameters.AddWithValue("@StatementReference", model.StatementReference);


                    command.Parameters.AddRange(AddParametersForDetails(model.Details).ToArray());

                    connection.Open();
                    var awaiter = await command.ExecuteScalarAsync().ConfigureAwait(false);
                    return awaiter.To<long>();
                }
            }



        }
    }
}