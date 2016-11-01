using System.Collections.Generic;
using MixERP.Sales.DTO;

namespace MixERP.Sales.ViewModels
{
    public sealed class TicketViewModel
    {
        public SalesView View { get; set; }
        public List<CheckoutDetailView> Details { get; set; }
        public List<CouponView> DiscountCoupons { get; set; }
    }
}