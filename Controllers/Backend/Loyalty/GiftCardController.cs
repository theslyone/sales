using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Dashboard;
using MixERP.Sales.DAL.Backend.Service;
using MixERP.Sales.DAL.Backend.Tasks;
using MixERP.Sales.QueryModels;
using MixERP.Sales.ViewModels;

namespace MixERP.Sales.Controllers.Backend.Loyalty
{
    public class GiftCardController : SalesDashboardController
    {
        [Route("dashboard/sales/loyalty/gift-cards")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Loyalty/GiftCards/Index.cshtml", this.Tenant));
        }

        [Route("dashboard/loyalty/tasks/gift-cards/add-fund")]
        public ActionResult AddFundIndex()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Loyalty/GiftCards/AddFund/Index.cshtml", this.Tenant));
        }

        [Route("dashboard/loyalty/tasks/gift-cards/add-fund/checklist/{tranId}")]
        [MenuPolicy(OverridePath = "/dashboard/loyalty/tasks/gift-cards/add-fund")]
        public ActionResult CheckList(long tranId)
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Loyalty/GiftCards/AddFund/CheckList.cshtml", this.Tenant), tranId);
        }

        [Route("dashboard/loyalty/tasks/gift-cards/add-fund/entry")]
        [MenuPolicy(OverridePath = "/dashboard/loyalty/tasks/gift-cards/add-fund")]
        public ActionResult AddFundEntry()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Loyalty/GiftCards/AddFund/Entry.cshtml", this.Tenant));
        }

        [Route("dashboard/loyalty/tasks/gift-cards/add-fund/entry")]
        [MenuPolicy(OverridePath = "/dashboard/loyalty/tasks/gift-cards/add-fund")]
        [HttpPost]
        public async Task<ActionResult> AddFundEntryAsync(GiftCardFund model)
        {
            if (!this.ModelState.IsValid)
            {
                return this.InvalidModelState(this.ModelState);
            }

            try
            {
                var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

                model.OfficeId = meta.OfficeId;
                model.UserId = meta.UserId;
                model.LoginId = meta.LoginId;

                long id = await GiftCardFunds.AddAsync(this.Tenant, model).ConfigureAwait(true);
                return this.Ok(id);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

        [Route("dashboard/loyalty/tasks/gift-cards/search")]
        [HttpPost]
        public async Task<ActionResult> SearchGiftCardsAsync(GiftCardSearch model)
        {
            var result = await GiftCards.SearchAsync(this.Tenant, model).ConfigureAwait(false);
            return this.Ok(result);
        }

        [Route("dashboard/loyalty/tasks/gift-cards/get-balance/{giftCardNumber}")]
        [HttpPost]
        public async Task<ActionResult> GetBalanceAsync(string giftCardNumber)
        {
            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            decimal result = await DAL.Backend.Tasks.GiftCardFunds.GetBalanceAsync(this.Tenant, giftCardNumber, meta.OfficeId).ConfigureAwait(true);
            return this.Ok(result);
        }
    }
}