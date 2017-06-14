using Frapid.Configuration;
using Frapid.Paylink.DTO;
using MixERP.Sales.ViewModels;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace MixERP.Sales.Models
{
    public class SalesQRCode
    {
        public SalesQRCode ()
        {
            MetaData = new Dictionary<string, string>();
        }

        [JsonProperty("amount")]
        public decimal Amount { get; set; }

        [JsonProperty("remark")]
        public string Remark { get; set; }

        [JsonProperty("accountName")]
        public string AccountName { get; set; }

        [JsonProperty("accountNumber")]
        public string AccountNumber { get; internal set; }

        [JsonProperty("destination")]
        public Frapid.Paylink.Models.Destination Destination {
            get
            { return Frapid.Paylink.Models.Destination.DirectTransfer; } // this signals to freebe paylink to perform a direct bank transfer transfer
        } 

        [JsonProperty("type")]
        public string Type { get { return SubaccountType.BankAccount; } }

        [JsonProperty("bankName")]
        public string BankName { get; set; }

        [JsonProperty("bankCode")]
        public string BankCode { get; set; }

        [JsonProperty("metaData")]
        public Dictionary<string, string> MetaData { get; set; }

        
        public static SalesQRCode Generate(TicketViewModel model)
        {
            SalesQRCode qrCode = new SalesQRCode()
            {
                BankCode = model.View.BankTypeId,
                BankName = model.View.BankTypeName,
                AccountName = model.View.BankAccountName,
                AccountNumber = model.View.BankAccountNumber,
                Amount = model.View.TaxableTotal + model.View.Tax + model.View.NontaxableTotal - model.View.Discount,
                Remark = $"Sales Payment TransId#{ model.View.TransactionMasterId }"
            };
            qrCode.MetaData.Add("TransId", model.View.TransactionMasterId.ToString());
            qrCode.MetaData.Add("StoreId", model.View.StoreId.ToString());
            qrCode.MetaData.Add("OfficeId", model.View.OfficeId.ToString());
            qrCode.MetaData.Add("CostCenterId", "1");
            qrCode.MetaData.Add("CreditExchangeRate", "1");
            qrCode.MetaData.Add("DebitExchangeRate", "1");
            qrCode.MetaData.Add("Tenant", TenantConvention.GetTenant());
            return qrCode;
        }
    }
}