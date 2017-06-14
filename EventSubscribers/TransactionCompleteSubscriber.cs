using Frapid.Configuration.Events;
using Frapid.Configuration.Events.Interfaces;
using MixERP.Sales.ViewModels;
using Serilog;
using System;
using System.Threading.Tasks;
using MixERP.Sales.Models;
using Frapid.Dashboard.Helpers;
using Frapid.Dashboard.DTO;
using Receipts = MixERP.Sales.DAL.Backend.Tasks.Receipts;

namespace MixERP.Sales.EventSubscribers
{
    public class TransactionCompleteSubscriber : IEventSubscriber
    {
        public async Task EventHandler(EntityInserted<TransactionEvent> transactionInsertedEvent)
        {
            try
            {
                var transactionEvent = transactionInsertedEvent.Entity;
                var tenant = transactionEvent.MetaData?["Tenant"];
                var transId = transactionEvent.MetaData["TransId"];

                //var officeId = transactionEvent.MetaData["OfficeId"];
                //var storeId = transactionEvent.MetaData["StoreId"];
                var creditExchangeRate = transactionEvent.MetaData["CreditExchangeRate"];
                var debitExchangeRate = transactionEvent.MetaData["DebitExchangeRate"];
                var costCenterId = transactionEvent.MetaData["CostCenterId"];

                if (string.IsNullOrEmpty(tenant) || string.IsNullOrEmpty(transId))
                    return;

                Log.Information($"Sales Transaction Received on {tenant} {transactionInsertedEvent}");
                
                var model = await Tickets.GetTicketViewModelAsync(tenant, Convert.ToInt64(transId)).ConfigureAwait(true);
                DTO.SalesView sales = model.View;

                SalesReceipt salesReceipt = new SalesReceipt()
                {
                    UserId = 99999999, //Freebe user Id
                    LoginId = 99999999, //Freebe login Id
                    OfficeId = sales.OfficeId,
                    
                    CurrencyCode = transactionEvent.Currency,

                    DebitExchangeRate = debitExchangeRate != null ? Convert.ToDecimal(debitExchangeRate) : 1,
                    CreditExchangeRate = creditExchangeRate != null ? Convert.ToDecimal(creditExchangeRate) : 1,
                    CostCenterId = costCenterId != null ? Convert.ToInt16(costCenterId) : 1,

                    Amount = transactionEvent.Amount,
                    BankAccountId = sales.BankAccountId,
                    CustomerId = sales.CustomerId,
                 
                    PostedDate = transactionEvent.TransactionDate,
                    ReferenceNumber = transactionEvent.Reference,
                    StatementReference = transactionEvent.Purpose                     
                };

                try
                {
                    long receiptId = await Receipts.PostAsync(tenant, salesReceipt).ConfigureAwait(true);
                    //send notification here to erp vendor
                    await NotificationHelper.SendAsync(tenant, new Notification
                    {
                        Tenant = tenant,
                        OfficeId = sales.OfficeId,
                        AssociatedApp = "MixERP.Sales",
                        EventTimestamp = DateTimeOffset.UtcNow,
                        Icon = "money",
                        Url = $"/dashboard/sales/tasks/receipt/checklist/{receiptId}",
                        FormattedText = $"Freebe payment received. Amount: {salesReceipt.CurrencyCode} {salesReceipt.Amount}.",
                        //ToUserId = message.Event.UserId
                    }).ConfigureAwait(false);
                    return;
                }
                catch(Exception exc)
                {
                    Log.Error("{error}", exc.Message);

                    //send error notification to erp vendor
                    await NotificationHelper.SendAsync(tenant, new Notification
                    {
                        Tenant = tenant,
                        OfficeId = salesReceipt.OfficeId,
                        AssociatedApp = "MixERP.Sales",
                        EventTimestamp = DateTimeOffset.UtcNow,
                        Icon = "money",
                        Url = $"/dashboard/sales/tasks/entry/checklist/2{transId}",
                        FormattedText = $@"Error creating customer receipt for freebe payment. 
                            Amount: {salesReceipt.CurrencyCode} {salesReceipt.Amount}.",
                        //ToUserId = message.Event.UserId
                    }).ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                Log.Error("Exception: {Exception}", ex);
                throw ex;
            }
        }

        public string Description
        {
            get
            {
                return "Sales transaction subscriber";
            }
        }

        public void Register(IEventManager eventManager)
        {
            eventManager.Subscribe< EntityInserted<TransactionEvent>>(GetType().Assembly, EventHandler);
        }
    }
}
