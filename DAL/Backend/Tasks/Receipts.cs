using System;
using System.Linq;
using System.Threading.Tasks;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using Frapid.Mapper.Database;
using MixERP.Sales.DAL.Backend.Tasks.ReceiptEntry;
using MixERP.Sales.DTO;
using MixERP.Sales.ViewModels;

namespace MixERP.Sales.DAL.Backend.Tasks
{
    public static class Receipts
    {
        public static async Task<MerchantFeeSetup> GetMerchantFeeSetupAsync(string tenant, int merchantAccountId, int paymentCardId)
        {
            const string sql = "SELECT * FROM finance.merchant_fee_setup WHERE merchant_account_id=@0 AND payment_card_id=@1 AND deleted=@2;";
            return (await Factory.GetAsync<MerchantFeeSetup>(tenant, sql, merchantAccountId, paymentCardId, false).ConfigureAwait(false)).FirstOrDefault();
        }

        public static async Task<string> GetHomeCurrencyAsync(string tenant, int officeId)
        {
            const string sql = "SELECT core.get_currency_code_by_office_id(@0);";
            return await Factory.ScalarAsync<string>(tenant, sql, officeId).ConfigureAwait(false);
        }

        public static async Task<decimal> GetExchangeRateAsync(string tenant, int officeId, string sourceCurrencyCode, string destinationCurrencyCode)
        {
            const string sql = "SELECT finance.convert_exchange_rate(@0, @1, @2);";
            return await Factory.ScalarAsync<decimal>(tenant, sql, officeId, sourceCurrencyCode, destinationCurrencyCode).ConfigureAwait(false);
        }

        public static async Task<CustomerTransactionSummary> GetCustomerTransactionSummaryAsync(string tenant, int officeId, int customerId)
        {
            const string sql = "SELECT * FROM inventory.get_customer_transaction_summary(@0, @1);";
            return (await Factory.GetAsync<CustomerTransactionSummary>(tenant, sql, officeId, customerId).ConfigureAwait(false)).FirstOrDefault();
        }

        private static IReceiptEntry LocateService(string tenant)
        {
            string providerName = DbProvider.GetProviderName(tenant);
            var type = DbProvider.GetDbType(providerName);

            if (type == DatabaseType.PostgreSQL)
            {
                return new PostgreSQL();
            }

            if (type == DatabaseType.SqlServer)
            {
                return new SqlServer();
            }

            throw new NotImplementedException();
        }

        public static async Task<long> PostAsync(string tenant, SalesReceipt model)
        {
            var service = LocateService(tenant);
            return await service.PostAsync(tenant, model).ConfigureAwait(false);
        }
    }
}