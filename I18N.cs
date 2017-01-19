using System.Collections.Generic;
using System.Globalization;
using Frapid.Configuration;
using Frapid.i18n;

namespace MixERP.Sales
{
	public sealed class Localize : ILocalize
	{
		public Dictionary<string, string> GetResources(CultureInfo culture)
		{
			string resourceDirectory = I18N.ResourceDirectory;
			return I18NResource.GetResources(resourceDirectory, culture);
		}
	}

	public static class I18N
	{
		public static string ResourceDirectory { get; }

		static I18N()
		{
			ResourceDirectory = PathMapper.MapPath("/Areas/MixERP.Sales/i18n");
		}

		/// <summary>
		///Account Id
		/// </summary>
		public static string AccountId => I18NResource.GetString(ResourceDirectory, "AccountId");

		/// <summary>
		///Add a New Sales Entry
		/// </summary>
		public static string AddNewSalesEntry => I18NResource.GetString(ResourceDirectory, "AddNewSalesEntry");

		/// <summary>
		///Address
		/// </summary>
		public static string Address => I18NResource.GetString(ResourceDirectory, "Address");

		/// <summary>
		///Address Line 1
		/// </summary>
		public static string AddressLine1 => I18NResource.GetString(ResourceDirectory, "AddressLine1");

		/// <summary>
		///Address Line 2
		/// </summary>
		public static string AddressLine2 => I18NResource.GetString(ResourceDirectory, "AddressLine2");

		/// <summary>
		///Amount
		/// </summary>
		public static string Amount => I18NResource.GetString(ResourceDirectory, "Amount");

		/// <summary>
		///Approval Memo
		/// </summary>
		public static string ApprovalMemo => I18NResource.GetString(ResourceDirectory, "ApprovalMemo");

		/// <summary>
		///Approved By
		/// </summary>
		public static string ApprovedBy => I18NResource.GetString(ResourceDirectory, "ApprovedBy");

		/// <summary>
		///Associated Price Type Code
		/// </summary>
		public static string AssociatedPriceTypeCode => I18NResource.GetString(ResourceDirectory, "AssociatedPriceTypeCode");

		/// <summary>
		///Associated Price Type Id
		/// </summary>
		public static string AssociatedPriceTypeId => I18NResource.GetString(ResourceDirectory, "AssociatedPriceTypeId");

		/// <summary>
		///Associated Price Type Name
		/// </summary>
		public static string AssociatedPriceTypeName => I18NResource.GetString(ResourceDirectory, "AssociatedPriceTypeName");

		/// <summary>
		///Associated User
		/// </summary>
		public static string AssociatedUser => I18NResource.GetString(ResourceDirectory, "AssociatedUser");

		/// <summary>
		///Associated User Id
		/// </summary>
		public static string AssociatedUserId => I18NResource.GetString(ResourceDirectory, "AssociatedUserId");

		/// <summary>
		///Attempted By
		/// </summary>
		public static string AttemptedBy => I18NResource.GetString(ResourceDirectory, "AttemptedBy");

		/// <summary>
		///Audit Ts
		/// </summary>
		public static string AuditTs => I18NResource.GetString(ResourceDirectory, "AuditTs");

		/// <summary>
		///Audit User Id
		/// </summary>
		public static string AuditUserId => I18NResource.GetString(ResourceDirectory, "AuditUserId");

		/// <summary>
		///Barcode
		/// </summary>
		public static string Barcode => I18NResource.GetString(ResourceDirectory, "Barcode");

		/// <summary>
		///Begins From
		/// </summary>
		public static string BeginsFrom => I18NResource.GetString(ResourceDirectory, "BeginsFrom");

		/// <summary>
		///Book Date
		/// </summary>
		public static string BookDate => I18NResource.GetString(ResourceDirectory, "BookDate");

		/// <summary>
		///Brand Id
		/// </summary>
		public static string BrandId => I18NResource.GetString(ResourceDirectory, "BrandId");

		/// <summary>
		///Brand Name
		/// </summary>
		public static string BrandName => I18NResource.GetString(ResourceDirectory, "BrandName");

		/// <summary>
		///Browser
		/// </summary>
		public static string Browser => I18NResource.GetString(ResourceDirectory, "Browser");

		/// <summary>
		///Cancellation Reason
		/// </summary>
		public static string CancellationReason => I18NResource.GetString(ResourceDirectory, "CancellationReason");

		/// <summary>
		///Cancelled
		/// </summary>
		public static string Cancelled => I18NResource.GetString(ResourceDirectory, "Cancelled");

		/// <summary>
		///Cashier Code
		/// </summary>
		public static string CashierCode => I18NResource.GetString(ResourceDirectory, "CashierCode");

		/// <summary>
		///Cashier Id
		/// </summary>
		public static string CashierId => I18NResource.GetString(ResourceDirectory, "CashierId");

		/// <summary>
		///Cashier Login Info Id
		/// </summary>
		public static string CashierLoginInfoId => I18NResource.GetString(ResourceDirectory, "CashierLoginInfoId");

		/// <summary>
		///Cash Repository Code
		/// </summary>
		public static string CashRepositoryCode => I18NResource.GetString(ResourceDirectory, "CashRepositoryCode");

		/// <summary>
		///Cash Repository Id
		/// </summary>
		public static string CashRepositoryId => I18NResource.GetString(ResourceDirectory, "CashRepositoryId");

		/// <summary>
		///Cash Repository Name
		/// </summary>
		public static string CashRepositoryName => I18NResource.GetString(ResourceDirectory, "CashRepositoryName");

		/// <summary>
		///Change
		/// </summary>
		public static string Change => I18NResource.GetString(ResourceDirectory, "Change");

		/// <summary>
		///Check Amount
		/// </summary>
		public static string CheckAmount => I18NResource.GetString(ResourceDirectory, "CheckAmount");

		/// <summary>
		///Check Bank Name
		/// </summary>
		public static string CheckBankName => I18NResource.GetString(ResourceDirectory, "CheckBankName");

		/// <summary>
		///Check Clear Date
		/// </summary>
		public static string CheckClearDate => I18NResource.GetString(ResourceDirectory, "CheckClearDate");

		/// <summary>
		///Check Cleared
		/// </summary>
		public static string CheckCleared => I18NResource.GetString(ResourceDirectory, "CheckCleared");

		/// <summary>
		///Check Clearing Memo
		/// </summary>
		public static string CheckClearingMemo => I18NResource.GetString(ResourceDirectory, "CheckClearingMemo");

		/// <summary>
		///Check Clearing Transaction Master Id
		/// </summary>
		public static string CheckClearingTransactionMasterId => I18NResource.GetString(ResourceDirectory, "CheckClearingTransactionMasterId");

		/// <summary>
		///Check Date
		/// </summary>
		public static string CheckDate => I18NResource.GetString(ResourceDirectory, "CheckDate");

		/// <summary>
		///Checklist
		/// </summary>
		public static string Checklist => I18NResource.GetString(ResourceDirectory, "Checklist");

		/// <summary>
		///Checklist Window
		/// </summary>
		public static string ChecklistWindow => I18NResource.GetString(ResourceDirectory, "ChecklistWindow");

		/// <summary>
		///Check Number
		/// </summary>
		public static string CheckNumber => I18NResource.GetString(ResourceDirectory, "CheckNumber");

		/// <summary>
		///Checkout Id
		/// </summary>
		public static string CheckoutId => I18NResource.GetString(ResourceDirectory, "CheckoutId");

		/// <summary>
		///City
		/// </summary>
		public static string City => I18NResource.GetString(ResourceDirectory, "City");

		/// <summary>
		///Closed
		/// </summary>
		public static string Closed => I18NResource.GetString(ResourceDirectory, "Closed");

		/// <summary>
		///Closing Cash Id
		/// </summary>
		public static string ClosingCashId => I18NResource.GetString(ResourceDirectory, "ClosingCashId");

		/// <summary>
		///Coins
		/// </summary>
		public static string Coins => I18NResource.GetString(ResourceDirectory, "Coins");

		/// <summary>
		///Cost Center Name
		/// </summary>
		public static string CostCenterName => I18NResource.GetString(ResourceDirectory, "CostCenterName");

		/// <summary>
		///Counter
		/// </summary>
		public static string Counter => I18NResource.GetString(ResourceDirectory, "Counter");

		/// <summary>
		///Counter Code
		/// </summary>
		public static string CounterCode => I18NResource.GetString(ResourceDirectory, "CounterCode");

		/// <summary>
		///Counter Id
		/// </summary>
		public static string CounterId => I18NResource.GetString(ResourceDirectory, "CounterId");

		/// <summary>
		///Counter Name
		/// </summary>
		public static string CounterName => I18NResource.GetString(ResourceDirectory, "CounterName");

		/// <summary>
		///Country
		/// </summary>
		public static string Country => I18NResource.GetString(ResourceDirectory, "Country");

		/// <summary>
		///Coupon Code
		/// </summary>
		public static string CouponCode => I18NResource.GetString(ResourceDirectory, "CouponCode");

		/// <summary>
		///Coupon Id
		/// </summary>
		public static string CouponId => I18NResource.GetString(ResourceDirectory, "CouponId");

		/// <summary>
		///Coupon Name
		/// </summary>
		public static string CouponName => I18NResource.GetString(ResourceDirectory, "CouponName");

		/// <summary>
		///Credit Settled
		/// </summary>
		public static string CreditSettled => I18NResource.GetString(ResourceDirectory, "CreditSettled");

		/// <summary>
		///Currency Code
		/// </summary>
		public static string CurrencyCode => I18NResource.GetString(ResourceDirectory, "CurrencyCode");

		/// <summary>
		///Customer Id
		/// </summary>
		public static string CustomerId => I18NResource.GetString(ResourceDirectory, "CustomerId");

		/// <summary>
		///Customer Name
		/// </summary>
		public static string CustomerName => I18NResource.GetString(ResourceDirectory, "CustomerName");

		/// <summary>
		///Customer Type
		/// </summary>
		public static string CustomerType => I18NResource.GetString(ResourceDirectory, "CustomerType");

		/// <summary>
		///Customer Type Id
		/// </summary>
		public static string CustomerTypeId => I18NResource.GetString(ResourceDirectory, "CustomerTypeId");

		/// <summary>
		///Deleted
		/// </summary>
		public static string Deleted => I18NResource.GetString(ResourceDirectory, "Deleted");

		/// <summary>
		///Deno 1
		/// </summary>
		public static string Deno1 => I18NResource.GetString(ResourceDirectory, "Deno1");

		/// <summary>
		///Deno 10
		/// </summary>
		public static string Deno10 => I18NResource.GetString(ResourceDirectory, "Deno10");

		/// <summary>
		///Deno 100
		/// </summary>
		public static string Deno100 => I18NResource.GetString(ResourceDirectory, "Deno100");

		/// <summary>
		///Deno 1000
		/// </summary>
		public static string Deno1000 => I18NResource.GetString(ResourceDirectory, "Deno1000");

		/// <summary>
		///Deno 2
		/// </summary>
		public static string Deno2 => I18NResource.GetString(ResourceDirectory, "Deno2");

		/// <summary>
		///Deno 20
		/// </summary>
		public static string Deno20 => I18NResource.GetString(ResourceDirectory, "Deno20");

		/// <summary>
		///Deno 200
		/// </summary>
		public static string Deno200 => I18NResource.GetString(ResourceDirectory, "Deno200");

		/// <summary>
		///Deno 25
		/// </summary>
		public static string Deno25 => I18NResource.GetString(ResourceDirectory, "Deno25");

		/// <summary>
		///Deno 250
		/// </summary>
		public static string Deno250 => I18NResource.GetString(ResourceDirectory, "Deno250");

		/// <summary>
		///Deno 5
		/// </summary>
		public static string Deno5 => I18NResource.GetString(ResourceDirectory, "Deno5");

		/// <summary>
		///Deno 50
		/// </summary>
		public static string Deno50 => I18NResource.GetString(ResourceDirectory, "Deno50");

		/// <summary>
		///Deno 500
		/// </summary>
		public static string Deno500 => I18NResource.GetString(ResourceDirectory, "Deno500");

		/// <summary>
		///Discount
		/// </summary>
		public static string Discount => I18NResource.GetString(ResourceDirectory, "Discount");

		/// <summary>
		///Discount Coupons
		/// </summary>
		public static string DiscountCoupons => I18NResource.GetString(ResourceDirectory, "DiscountCoupons");

		/// <summary>
		///Discount Rate
		/// </summary>
		public static string DiscountRate => I18NResource.GetString(ResourceDirectory, "DiscountRate");

		/// <summary>
		///Due Days
		/// </summary>
		public static string DueDays => I18NResource.GetString(ResourceDirectory, "DueDays");

		/// <summary>
		///Due Fequency
		/// </summary>
		public static string DueFequency => I18NResource.GetString(ResourceDirectory, "DueFequency");

		/// <summary>
		///Due Frequency Id
		/// </summary>
		public static string DueFrequencyId => I18NResource.GetString(ResourceDirectory, "DueFrequencyId");

		/// <summary>
		///Due On Date
		/// </summary>
		public static string DueOnDate => I18NResource.GetString(ResourceDirectory, "DueOnDate");

		/// <summary>
		///Enable Ticket Printing
		/// </summary>
		public static string EnableTicketPrinting => I18NResource.GetString(ResourceDirectory, "EnableTicketPrinting");

		/// <summary>
		///Entered By
		/// </summary>
		public static string EnteredBy => I18NResource.GetString(ResourceDirectory, "EnteredBy");

		/// <summary>
		///Er Credit
		/// </summary>
		public static string ErCredit => I18NResource.GetString(ResourceDirectory, "ErCredit");

		/// <summary>
		///Er Debit
		/// </summary>
		public static string ErDebit => I18NResource.GetString(ResourceDirectory, "ErDebit");

		/// <summary>
		///Expected Delivery Date
		/// </summary>
		public static string ExpectedDeliveryDate => I18NResource.GetString(ResourceDirectory, "ExpectedDeliveryDate");

		/// <summary>
		///Expires On
		/// </summary>
		public static string ExpiresOn => I18NResource.GetString(ResourceDirectory, "ExpiresOn");

		/// <summary>
		///Fax
		/// </summary>
		public static string Fax => I18NResource.GetString(ResourceDirectory, "Fax");

		/// <summary>
		///First Name
		/// </summary>
		public static string FirstName => I18NResource.GetString(ResourceDirectory, "FirstName");

		/// <summary>
		///Fiscal Year Code
		/// </summary>
		public static string FiscalYearCode => I18NResource.GetString(ResourceDirectory, "FiscalYearCode");

		/// <summary>
		///For Ticket Having Maximum Amount
		/// </summary>
		public static string ForTicketHavingMaximumAmount => I18NResource.GetString(ResourceDirectory, "ForTicketHavingMaximumAmount");

		/// <summary>
		///For Ticket Having Minimum Amount
		/// </summary>
		public static string ForTicketHavingMinimumAmount => I18NResource.GetString(ResourceDirectory, "ForTicketHavingMinimumAmount");

		/// <summary>
		///For Ticket Of Price Type Code
		/// </summary>
		public static string ForTicketOfPriceTypeCode => I18NResource.GetString(ResourceDirectory, "ForTicketOfPriceTypeCode");

		/// <summary>
		///For Ticket Of Price Type Id
		/// </summary>
		public static string ForTicketOfPriceTypeId => I18NResource.GetString(ResourceDirectory, "ForTicketOfPriceTypeId");

		/// <summary>
		///For Ticket Of Price Type Name
		/// </summary>
		public static string ForTicketOfPriceTypeName => I18NResource.GetString(ResourceDirectory, "ForTicketOfPriceTypeName");

		/// <summary>
		///For Ticket Of Unknown Customers Only
		/// </summary>
		public static string ForTicketOfUnknownCustomersOnly => I18NResource.GetString(ResourceDirectory, "ForTicketOfUnknownCustomersOnly");

		/// <summary>
		///Gift Card Fund Sales
		/// </summary>
		public static string GiftCardFundSales => I18NResource.GetString(ResourceDirectory, "GiftCardFundSales");

		/// <summary>
		///Gift Card Id
		/// </summary>
		public static string GiftCardId => I18NResource.GetString(ResourceDirectory, "GiftCardId");

		/// <summary>
		///Gift Card Number
		/// </summary>
		public static string GiftCardNumber => I18NResource.GetString(ResourceDirectory, "GiftCardNumber");

		/// <summary>
		///Gift Card Owner
		/// </summary>
		public static string GiftCardOwner => I18NResource.GetString(ResourceDirectory, "GiftCardOwner");

		/// <summary>
		///Grace Period
		/// </summary>
		public static string GracePeriod => I18NResource.GetString(ResourceDirectory, "GracePeriod");

		/// <summary>
		///Hot Item
		/// </summary>
		public static string HotItem => I18NResource.GetString(ResourceDirectory, "HotItem");

		/// <summary>
		///Includes Tax
		/// </summary>
		public static string IncludesTax => I18NResource.GetString(ResourceDirectory, "IncludesTax");

		/// <summary>
		///Internal Memo
		/// </summary>
		public static string InternalMemo => I18NResource.GetString(ResourceDirectory, "InternalMemo");

		/// <summary>
		///Invoice Number
		/// </summary>
		public static string InvoiceNumber => I18NResource.GetString(ResourceDirectory, "InvoiceNumber");

		/// <summary>
		///Ip Address
		/// </summary>
		public static string IpAddress => I18NResource.GetString(ResourceDirectory, "IpAddress");

		/// <summary>
		///Is Credit
		/// </summary>
		public static string IsCredit => I18NResource.GetString(ResourceDirectory, "IsCredit");

		/// <summary>
		///Is Flat Amount
		/// </summary>
		public static string IsFlatAmount => I18NResource.GetString(ResourceDirectory, "IsFlatAmount");

		/// <summary>
		///Is Flat Discount
		/// </summary>
		public static string IsFlatDiscount => I18NResource.GetString(ResourceDirectory, "IsFlatDiscount");

		/// <summary>
		///Is Percentage
		/// </summary>
		public static string IsPercentage => I18NResource.GetString(ResourceDirectory, "IsPercentage");

		/// <summary>
		///Is Taxable Item
		/// </summary>
		public static string IsTaxableItem => I18NResource.GetString(ResourceDirectory, "IsTaxableItem");

		/// <summary>
		///Item
		/// </summary>
		public static string Item => I18NResource.GetString(ResourceDirectory, "Item");

		/// <summary>
		///Item Code
		/// </summary>
		public static string ItemCode => I18NResource.GetString(ResourceDirectory, "ItemCode");

		/// <summary>
		///Item Group Id
		/// </summary>
		public static string ItemGroupId => I18NResource.GetString(ResourceDirectory, "ItemGroupId");

		/// <summary>
		///Item Group Name
		/// </summary>
		public static string ItemGroupName => I18NResource.GetString(ResourceDirectory, "ItemGroupName");

		/// <summary>
		///Item Id
		/// </summary>
		public static string ItemId => I18NResource.GetString(ResourceDirectory, "ItemId");

		/// <summary>
		///Item Name
		/// </summary>
		public static string ItemName => I18NResource.GetString(ResourceDirectory, "ItemName");

		/// <summary>
		///Item Selling Price Id
		/// </summary>
		public static string ItemSellingPriceId => I18NResource.GetString(ResourceDirectory, "ItemSellingPriceId");

		/// <summary>
		///Item Type Id
		/// </summary>
		public static string ItemTypeId => I18NResource.GetString(ResourceDirectory, "ItemTypeId");

		/// <summary>
		///Item Type Name
		/// </summary>
		public static string ItemTypeName => I18NResource.GetString(ResourceDirectory, "ItemTypeName");

		/// <summary>
		///Last Name
		/// </summary>
		public static string LastName => I18NResource.GetString(ResourceDirectory, "LastName");

		/// <summary>
		///Last Verified On
		/// </summary>
		public static string LastVerifiedOn => I18NResource.GetString(ResourceDirectory, "LastVerifiedOn");

		/// <summary>
		///Late Fee
		/// </summary>
		public static string LateFee => I18NResource.GetString(ResourceDirectory, "LateFee");

		/// <summary>
		///Late Fee Code
		/// </summary>
		public static string LateFeeCode => I18NResource.GetString(ResourceDirectory, "LateFeeCode");

		/// <summary>
		///Late Fee Frequency
		/// </summary>
		public static string LateFeeFrequency => I18NResource.GetString(ResourceDirectory, "LateFeeFrequency");

		/// <summary>
		///Late Fee Id
		/// </summary>
		public static string LateFeeId => I18NResource.GetString(ResourceDirectory, "LateFeeId");

		/// <summary>
		///Late Fee Name
		/// </summary>
		public static string LateFeeName => I18NResource.GetString(ResourceDirectory, "LateFeeName");

		/// <summary>
		///Late Fee Posting Frequency Id
		/// </summary>
		public static string LateFeePostingFrequencyId => I18NResource.GetString(ResourceDirectory, "LateFeePostingFrequencyId");

		/// <summary>
		///Late Fee Tran Id
		/// </summary>
		public static string LateFeeTranId => I18NResource.GetString(ResourceDirectory, "LateFeeTranId");

		/// <summary>
		///Login Date
		/// </summary>
		public static string LoginDate => I18NResource.GetString(ResourceDirectory, "LoginDate");

		/// <summary>
		///Maximum Discount Amount
		/// </summary>
		public static string MaximumDiscountAmount => I18NResource.GetString(ResourceDirectory, "MaximumDiscountAmount");

		/// <summary>
		///Maximum Purchase Amount
		/// </summary>
		public static string MaximumPurchaseAmount => I18NResource.GetString(ResourceDirectory, "MaximumPurchaseAmount");

		/// <summary>
		///Maximum Usage
		/// </summary>
		public static string MaximumUsage => I18NResource.GetString(ResourceDirectory, "MaximumUsage");

		/// <summary>
		///Memo
		/// </summary>
		public static string Memo => I18NResource.GetString(ResourceDirectory, "Memo");

		/// <summary>
		///Middle Name
		/// </summary>
		public static string MiddleName => I18NResource.GetString(ResourceDirectory, "MiddleName");

		/// <summary>
		///Minimum Purchase Amount
		/// </summary>
		public static string MinimumPurchaseAmount => I18NResource.GetString(ResourceDirectory, "MinimumPurchaseAmount");

		/// <summary>
		///Name
		/// </summary>
		public static string Name => I18NResource.GetString(ResourceDirectory, "Name");

		/// <summary>
		///Office Id
		/// </summary>
		public static string OfficeId => I18NResource.GetString(ResourceDirectory, "OfficeId");

		/// <summary>
		///Office Name
		/// </summary>
		public static string OfficeName => I18NResource.GetString(ResourceDirectory, "OfficeName");

		/// <summary>
		///Opening Cash
		/// </summary>
		public static string OpeningCash => I18NResource.GetString(ResourceDirectory, "OpeningCash");

		/// <summary>
		///Opening Cash Id
		/// </summary>
		public static string OpeningCashId => I18NResource.GetString(ResourceDirectory, "OpeningCashId");

		/// <summary>
		///Order Detail Id
		/// </summary>
		public static string OrderDetailId => I18NResource.GetString(ResourceDirectory, "OrderDetailId");

		/// <summary>
		///Order Id
		/// </summary>
		public static string OrderId => I18NResource.GetString(ResourceDirectory, "OrderId");

		/// <summary>
		///Payable Account Id
		/// </summary>
		public static string PayableAccountId => I18NResource.GetString(ResourceDirectory, "PayableAccountId");

		/// <summary>
		///Payment Term Code
		/// </summary>
		public static string PaymentTermCode => I18NResource.GetString(ResourceDirectory, "PaymentTermCode");

		/// <summary>
		///Payment Term Id
		/// </summary>
		public static string PaymentTermId => I18NResource.GetString(ResourceDirectory, "PaymentTermId");

		/// <summary>
		///Payment Term Name
		/// </summary>
		public static string PaymentTermName => I18NResource.GetString(ResourceDirectory, "PaymentTermName");

		/// <summary>
		///Phone Numbers
		/// </summary>
		public static string PhoneNumbers => I18NResource.GetString(ResourceDirectory, "PhoneNumbers");

		/// <summary>
		///Photo
		/// </summary>
		public static string Photo => I18NResource.GetString(ResourceDirectory, "Photo");

		/// <summary>
		///Pin Code
		/// </summary>
		public static string PinCode => I18NResource.GetString(ResourceDirectory, "PinCode");

		/// <summary>
		///Please select an item from the grid.
		/// </summary>
		public static string PleaseSelectItemFromGrid => I18NResource.GetString(ResourceDirectory, "PleaseSelectItemFromGrid");

		/// <summary>
		///Po Box
		/// </summary>
		public static string PoBox => I18NResource.GetString(ResourceDirectory, "PoBox");

		/// <summary>
		///Posted By
		/// </summary>
		public static string PostedBy => I18NResource.GetString(ResourceDirectory, "PostedBy");

		/// <summary>
		///Posted By Name
		/// </summary>
		public static string PostedByName => I18NResource.GetString(ResourceDirectory, "PostedByName");

		/// <summary>
		///Posted Date
		/// </summary>
		public static string PostedDate => I18NResource.GetString(ResourceDirectory, "PostedDate");

		/// <summary>
		///Preferred Supplier Id
		/// </summary>
		public static string PreferredSupplierId => I18NResource.GetString(ResourceDirectory, "PreferredSupplierId");

		/// <summary>
		///Price
		/// </summary>
		public static string Price => I18NResource.GetString(ResourceDirectory, "Price");

		/// <summary>
		///Price Type
		/// </summary>
		public static string PriceType => I18NResource.GetString(ResourceDirectory, "PriceType");

		/// <summary>
		///Price Type Code
		/// </summary>
		public static string PriceTypeCode => I18NResource.GetString(ResourceDirectory, "PriceTypeCode");

		/// <summary>
		///Price Type Id
		/// </summary>
		public static string PriceTypeId => I18NResource.GetString(ResourceDirectory, "PriceTypeId");

		/// <summary>
		///Price Type Name
		/// </summary>
		public static string PriceTypeName => I18NResource.GetString(ResourceDirectory, "PriceTypeName");

		/// <summary>
		///Provided By
		/// </summary>
		public static string ProvidedBy => I18NResource.GetString(ResourceDirectory, "ProvidedBy");

		/// <summary>
		///Quantity
		/// </summary>
		public static string Quantity => I18NResource.GetString(ResourceDirectory, "Quantity");

		/// <summary>
		///Quotation Detail Id
		/// </summary>
		public static string QuotationDetailId => I18NResource.GetString(ResourceDirectory, "QuotationDetailId");

		/// <summary>
		///Quotation Id
		/// </summary>
		public static string QuotationId => I18NResource.GetString(ResourceDirectory, "QuotationId");

		/// <summary>
		///Rate
		/// </summary>
		public static string Rate => I18NResource.GetString(ResourceDirectory, "Rate");

		/// <summary>
		///Receipt Id
		/// </summary>
		public static string ReceiptId => I18NResource.GetString(ResourceDirectory, "ReceiptId");

		/// <summary>
		///Receipt Transaction Master Id
		/// </summary>
		public static string ReceiptTransactionMasterId => I18NResource.GetString(ResourceDirectory, "ReceiptTransactionMasterId");

		/// <summary>
		///Reference Number
		/// </summary>
		public static string ReferenceNumber => I18NResource.GetString(ResourceDirectory, "ReferenceNumber");

		/// <summary>
		///Return Id
		/// </summary>
		public static string ReturnId => I18NResource.GetString(ResourceDirectory, "ReturnId");

		/// <summary>
		///Return Transaction Master Id
		/// </summary>
		public static string ReturnTransactionMasterId => I18NResource.GetString(ResourceDirectory, "ReturnTransactionMasterId");

		/// <summary>
		///Reward Points
		/// </summary>
		public static string RewardPoints => I18NResource.GetString(ResourceDirectory, "RewardPoints");

		/// <summary>
		///Sales Id
		/// </summary>
		public static string SalesId => I18NResource.GetString(ResourceDirectory, "SalesId");

		/// <summary>
		///Sales Order Id
		/// </summary>
		public static string SalesOrderId => I18NResource.GetString(ResourceDirectory, "SalesOrderId");

		/// <summary>
		///Salesperson Id
		/// </summary>
		public static string SalespersonId => I18NResource.GetString(ResourceDirectory, "SalespersonId");

		/// <summary>
		///Salesperson Name
		/// </summary>
		public static string SalespersonName => I18NResource.GetString(ResourceDirectory, "SalespersonName");

		/// <summary>
		///Sales Quotation Id
		/// </summary>
		public static string SalesQuotationId => I18NResource.GetString(ResourceDirectory, "SalesQuotationId");

		/// <summary>
		///Selling Price
		/// </summary>
		public static string SellingPrice => I18NResource.GetString(ResourceDirectory, "SellingPrice");

		/// <summary>
		///Selling Price Includes Tax
		/// </summary>
		public static string SellingPriceIncludesTax => I18NResource.GetString(ResourceDirectory, "SellingPriceIncludesTax");

		/// <summary>
		///Shipper Id
		/// </summary>
		public static string ShipperId => I18NResource.GetString(ResourceDirectory, "ShipperId");

		/// <summary>
		///Shipping Charge
		/// </summary>
		public static string ShippingCharge => I18NResource.GetString(ResourceDirectory, "ShippingCharge");

		/// <summary>
		///State
		/// </summary>
		public static string State => I18NResource.GetString(ResourceDirectory, "State");

		/// <summary>
		///Statement Reference
		/// </summary>
		public static string StatementReference => I18NResource.GetString(ResourceDirectory, "StatementReference");

		/// <summary>
		///Status
		/// </summary>
		public static string Status => I18NResource.GetString(ResourceDirectory, "Status");

		/// <summary>
		///Store Code
		/// </summary>
		public static string StoreCode => I18NResource.GetString(ResourceDirectory, "StoreCode");

		/// <summary>
		///Store Id
		/// </summary>
		public static string StoreId => I18NResource.GetString(ResourceDirectory, "StoreId");

		/// <summary>
		///Store Name
		/// </summary>
		public static string StoreName => I18NResource.GetString(ResourceDirectory, "StoreName");

		/// <summary>
		///Street
		/// </summary>
		public static string Street => I18NResource.GetString(ResourceDirectory, "Street");

		/// <summary>
		///Submitted Cash
		/// </summary>
		public static string SubmittedCash => I18NResource.GetString(ResourceDirectory, "SubmittedCash");

		/// <summary>
		///Submitted To
		/// </summary>
		public static string SubmittedTo => I18NResource.GetString(ResourceDirectory, "SubmittedTo");

		/// <summary>
		///Success
		/// </summary>
		public static string Success => I18NResource.GetString(ResourceDirectory, "Success");

		/// <summary>
		///Tax
		/// </summary>
		public static string Tax => I18NResource.GetString(ResourceDirectory, "Tax");

		/// <summary>
		///Tender
		/// </summary>
		public static string Tender => I18NResource.GetString(ResourceDirectory, "Tender");

		/// <summary>
		///Terms
		/// </summary>
		public static string Terms => I18NResource.GetString(ResourceDirectory, "Terms");

		/// <summary>
		///The ticket {0} could not be found.
		/// </summary>
		public static string TicketTranIdCouldNotBeFound => I18NResource.GetString(ResourceDirectory, "TicketTranIdCouldNotBeFound");

		/// <summary>
		///Total Amount
		/// </summary>
		public static string TotalAmount => I18NResource.GetString(ResourceDirectory, "TotalAmount");

		/// <summary>
		///Total Cash Sales
		/// </summary>
		public static string TotalCashSales => I18NResource.GetString(ResourceDirectory, "TotalCashSales");

		/// <summary>
		///Total Discount Amount
		/// </summary>
		public static string TotalDiscountAmount => I18NResource.GetString(ResourceDirectory, "TotalDiscountAmount");

		/// <summary>
		///Transaction Code
		/// </summary>
		public static string TransactionCode => I18NResource.GetString(ResourceDirectory, "TransactionCode");

		/// <summary>
		///Transaction Counter
		/// </summary>
		public static string TransactionCounter => I18NResource.GetString(ResourceDirectory, "TransactionCounter");

		/// <summary>
		///Transaction Date
		/// </summary>
		public static string TransactionDate => I18NResource.GetString(ResourceDirectory, "TransactionDate");

		/// <summary>
		///Transaction Id
		/// </summary>
		public static string TransactionId => I18NResource.GetString(ResourceDirectory, "TransactionId");

		/// <summary>
		///Transaction Master Id
		/// </summary>
		public static string TransactionMasterId => I18NResource.GetString(ResourceDirectory, "TransactionMasterId");

		/// <summary>
		///The transaction was posted successfully.
		/// </summary>
		public static string TransactionPostedSuccessfully => I18NResource.GetString(ResourceDirectory, "TransactionPostedSuccessfully");

		/// <summary>
		///Transaction Timestamp
		/// </summary>
		public static string TransactionTimestamp => I18NResource.GetString(ResourceDirectory, "TransactionTimestamp");

		/// <summary>
		///Transaction Ts
		/// </summary>
		public static string TransactionTs => I18NResource.GetString(ResourceDirectory, "TransactionTs");

		/// <summary>
		///Transaction Type
		/// </summary>
		public static string TransactionType => I18NResource.GetString(ResourceDirectory, "TransactionType");

		/// <summary>
		///Unit
		/// </summary>
		public static string Unit => I18NResource.GetString(ResourceDirectory, "Unit");

		/// <summary>
		///Unit Code
		/// </summary>
		public static string UnitCode => I18NResource.GetString(ResourceDirectory, "UnitCode");

		/// <summary>
		///Unit Id
		/// </summary>
		public static string UnitId => I18NResource.GetString(ResourceDirectory, "UnitId");

		/// <summary>
		///Unit Name
		/// </summary>
		public static string UnitName => I18NResource.GetString(ResourceDirectory, "UnitName");

		/// <summary>
		///User Agent
		/// </summary>
		public static string UserAgent => I18NResource.GetString(ResourceDirectory, "UserAgent");

		/// <summary>
		///User Id
		/// </summary>
		public static string UserId => I18NResource.GetString(ResourceDirectory, "UserId");

		/// <summary>
		///Valid From
		/// </summary>
		public static string ValidFrom => I18NResource.GetString(ResourceDirectory, "ValidFrom");

		/// <summary>
		///Valid Till
		/// </summary>
		public static string ValidTill => I18NResource.GetString(ResourceDirectory, "ValidTill");

		/// <summary>
		///Valid Units
		/// </summary>
		public static string ValidUnits => I18NResource.GetString(ResourceDirectory, "ValidUnits");

		/// <summary>
		///Value Date
		/// </summary>
		public static string ValueDate => I18NResource.GetString(ResourceDirectory, "ValueDate");

		/// <summary>
		///Verification Reason
		/// </summary>
		public static string VerificationReason => I18NResource.GetString(ResourceDirectory, "VerificationReason");

		/// <summary>
		///Verification Status Id
		/// </summary>
		public static string VerificationStatusId => I18NResource.GetString(ResourceDirectory, "VerificationStatusId");

		/// <summary>
		///Verification Status Name
		/// </summary>
		public static string VerificationStatusName => I18NResource.GetString(ResourceDirectory, "VerificationStatusName");

		/// <summary>
		///Verified By
		/// </summary>
		public static string VerifiedBy => I18NResource.GetString(ResourceDirectory, "VerifiedBy");

		/// <summary>
		///Verified By User Id
		/// </summary>
		public static string VerifiedByUserId => I18NResource.GetString(ResourceDirectory, "VerifiedByUserId");

		/// <summary>
		///View Journal Advice
		/// </summary>
		public static string ViewJournalAdvice => I18NResource.GetString(ResourceDirectory, "ViewJournalAdvice");

		/// <summary>
		///View Sales
		/// </summary>
		public static string ViewSales => I18NResource.GetString(ResourceDirectory, "ViewSales");

		/// <summary>
		///View Sales Invoice
		/// </summary>
		public static string ViewSalesInvoice => I18NResource.GetString(ResourceDirectory, "ViewSalesInvoice");

		/// <summary>
		///Zipcode
		/// </summary>
		public static string Zipcode => I18NResource.GetString(ResourceDirectory, "Zipcode");

	}
}
