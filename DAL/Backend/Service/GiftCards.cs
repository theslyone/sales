using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.DataAccess;
using Frapid.Framework.Extensions;
using Frapid.NPoco;
using MixERP.Sales.DTO;
using MixERP.Sales.QueryModels;

namespace MixERP.Sales.DAL.Backend.Service
{
    public static class GiftCards
    {
        private static string WrapSearchWildcard(string text)
        {
            return "%" + text.Or("") + "%";
        }

        public static async Task<List<GiftCardSearchView>> SearchAsync(string tenant, GiftCardSearch query)
        {
            var sql = new Sql("SELECT * FROM sales.gift_card_search_view");
            sql.Where("UPPER(COALESCE(name, '')) LIKE @0", WrapSearchWildcard(query.Name).ToUpper());
            sql.Where("UPPER(COALESCE(address, '')) LIKE @0", WrapSearchWildcard(query.Address).ToUpper());
            sql.Where("UPPER(COALESCE(city, '')) LIKE @0", WrapSearchWildcard(query.City).ToUpper());
            sql.Where("UPPER(COALESCE(state, '')) LIKE @0", WrapSearchWildcard(query.State).ToUpper());
            sql.Where("UPPER(COALESCE(country, '')) LIKE @0", WrapSearchWildcard(query.Country).ToUpper());
            sql.Where("UPPER(COALESCE(po_box, '')) LIKE @0", WrapSearchWildcard(query.PoBox).ToUpper());
            sql.Where("UPPER(COALESCE(zipcode, '')) LIKE @0", WrapSearchWildcard(query.Zipcode).ToUpper());
            sql.Where("UPPER(COALESCE(phone_numbers, '')) LIKE @0", WrapSearchWildcard(query.Phone).ToUpper());

            var awaiter = await Factory.GetAsync<GiftCardSearchView>(tenant, sql).ConfigureAwait(false);
            return awaiter.ToList();
        }
    }
}