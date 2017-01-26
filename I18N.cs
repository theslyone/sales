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
		///Actions
		/// </summary>
		public static string Actions => I18NResource.GetString(ResourceDirectory, "Actions");

		/// <summary>
		///Add Fund to Gift Cards
		/// </summary>
		public static string AddFundGiftCards => I18NResource.GetString(ResourceDirectory, "AddFundGiftCards");

		/// <summary>
		///Add Funds to Gift Card
		/// </summary>
		public static string AddFundsGiftCard => I18NResource.GetString(ResourceDirectory, "AddFundsGiftCard");

		/// <summary>
		///Add New
		/// </summary>
		public static string AddNew => I18NResource.GetString(ResourceDirectory, "AddNew");

		/// <summary>
		///Add a New Sales Entry
		/// </summary>
		public static string AddNewSalesEntry => I18NResource.GetString(ResourceDirectory, "AddNewSalesEntry");

		/// <summary>
		///Add a New Sales Order
		/// </summary>
		public static string AddNewSalesOrder => I18NResource.GetString(ResourceDirectory, "AddNewSalesOrder");

		/// <summary>
		///Add a New Sales Quotation
		/// </summary>
		public static string AddNewSalesQuotation => I18NResource.GetString(ResourceDirectory, "AddNewSalesQuotation");

		/// <summary>
		///Add Tax
		/// </summary>
		public static string AddTax => I18NResource.GetString(ResourceDirectory, "AddTax");

		/// <summary>
		///Address
		/// </summary>
		public static string Address => I18NResource.GetString(ResourceDirectory, "Address");

		/// <summary>
		///Amount
		/// </summary>
		public static string Amount => I18NResource.GetString(ResourceDirectory, "Amount");

		/// <summary>
		///Approve
		/// </summary>
		public static string Approve => I18NResource.GetString(ResourceDirectory, "Approve");

		/// <summary>
		///Are you sure?
		/// </summary>
		public static string AreYouSure => I18NResource.GetString(ResourceDirectory, "AreYouSure");

		/// <summary>
		///Are you sure you want to delete this tab?
		/// </summary>
		public static string AreYouSureYouWantDeleteTab => I18NResource.GetString(ResourceDirectory, "AreYouSureYouWantDeleteTab");

		/// <summary>
		///BOD Cash
		/// </summary>
		public static string BODCash => I18NResource.GetString(ResourceDirectory, "BODCash");

		/// <summary>
		///Back
		/// </summary>
		public static string Back => I18NResource.GetString(ResourceDirectory, "Back");

		/// <summary>
		///BankName
		/// </summary>
		public static string BankName => I18NResource.GetString(ResourceDirectory, "BankName");

		/// <summary>
		///Book Date
		/// </summary>
		public static string BookDate => I18NResource.GetString(ResourceDirectory, "BookDate");

		/// <summary>
		///Cancel
		/// </summary>
		public static string Cancel => I18NResource.GetString(ResourceDirectory, "Cancel");

		/// <summary>
		///Cannot add item because the price is zero.
		/// </summary>
		public static string CannotAddItemBecausePriceIsZero => I18NResource.GetString(ResourceDirectory, "CannotAddItemBecausePriceIsZero");

		/// <summary>
		///Cash
		/// </summary>
		public static string Cash => I18NResource.GetString(ResourceDirectory, "Cash");

		/// <summary>
		///Cash Change
		/// </summary>
		public static string CashChange => I18NResource.GetString(ResourceDirectory, "CashChange");

		/// <summary>
		///Cash Tender
		/// </summary>
		public static string CashTender => I18NResource.GetString(ResourceDirectory, "CashTender");

		/// <summary>
		///Cashiers
		/// </summary>
		public static string Cashiers => I18NResource.GetString(ResourceDirectory, "Cashiers");

		/// <summary>
		///Change
		/// </summary>
		public static string Change => I18NResource.GetString(ResourceDirectory, "Change");

		/// <summary>
		///Check
		/// </summary>
		public static string Check => I18NResource.GetString(ResourceDirectory, "Check");

		/// <summary>
		///Check Amount
		/// </summary>
		public static string CheckAmount => I18NResource.GetString(ResourceDirectory, "CheckAmount");

		/// <summary>
		///Check Date
		/// </summary>
		public static string CheckDate => I18NResource.GetString(ResourceDirectory, "CheckDate");

		/// <summary>
		///Check Number
		/// </summary>
		public static string CheckNumber => I18NResource.GetString(ResourceDirectory, "CheckNumber");

		/// <summary>
		///Checklist
		/// </summary>
		public static string Checklist => I18NResource.GetString(ResourceDirectory, "Checklist");

		/// <summary>
		///Checklist Window
		/// </summary>
		public static string ChecklistWindow => I18NResource.GetString(ResourceDirectory, "ChecklistWindow");

		/// <summary>
		///Checkout
		/// </summary>
		public static string Checkout => I18NResource.GetString(ResourceDirectory, "Checkout");

		/// <summary>
		///City
		/// </summary>
		public static string City => I18NResource.GetString(ResourceDirectory, "City");

		/// <summary>
		///Clear
		/// </summary>
		public static string Clear => I18NResource.GetString(ResourceDirectory, "Clear");

		/// <summary>
		///Clear Screen
		/// </summary>
		public static string ClearScreen => I18NResource.GetString(ResourceDirectory, "ClearScreen");

		/// <summary>
		///Close
		/// </summary>
		public static string Close => I18NResource.GetString(ResourceDirectory, "Close");

		/// <summary>
		///Closing Summary
		/// </summary>
		public static string ClosingSummary => I18NResource.GetString(ResourceDirectory, "ClosingSummary");

		/// <summary>
		///CLS
		/// </summary>
		public static string Cls => I18NResource.GetString(ResourceDirectory, "Cls");

		/// <summary>
		///Coins
		/// </summary>
		public static string Coins => I18NResource.GetString(ResourceDirectory, "Coins");

		/// <summary>
		///Convert to Order
		/// </summary>
		public static string ConvertOrder => I18NResource.GetString(ResourceDirectory, "ConvertOrder");

		/// <summary>
		///Convert to Sales
		/// </summary>
		public static string ConvertSales => I18NResource.GetString(ResourceDirectory, "ConvertSales");

		/// <summary>
		///Cost Center
		/// </summary>
		public static string CostCenter => I18NResource.GetString(ResourceDirectory, "CostCenter");

		/// <summary>
		///Count
		/// </summary>
		public static string Count => I18NResource.GetString(ResourceDirectory, "Count");

		/// <summary>
		///Counter
		/// </summary>
		public static string Counter => I18NResource.GetString(ResourceDirectory, "Counter");

		/// <summary>
		///Country
		/// </summary>
		public static string Country => I18NResource.GetString(ResourceDirectory, "Country");

		/// <summary>
		///Coupon Code
		/// </summary>
		public static string CouponCode => I18NResource.GetString(ResourceDirectory, "CouponCode");

		/// <summary>
		///Credit
		/// </summary>
		public static string Credit => I18NResource.GetString(ResourceDirectory, "Credit");

		/// <summary>
		///CTRL + RETURN
		/// </summary>
		public static string CtrlReturn => I18NResource.GetString(ResourceDirectory, "CtrlReturn");

		/// <summary>
		///Current Area
		/// </summary>
		public static string CurrentArea => I18NResource.GetString(ResourceDirectory, "CurrentArea");

		/// <summary>
		///Current Branch Office
		/// </summary>
		public static string CurrentBranchOffice => I18NResource.GetString(ResourceDirectory, "CurrentBranchOffice");

		/// <summary>
		///Customer
		/// </summary>
		public static string Customer => I18NResource.GetString(ResourceDirectory, "Customer");

		/// <summary>
		///Customer Name
		/// </summary>
		public static string CustomerName => I18NResource.GetString(ResourceDirectory, "CustomerName");

		/// <summary>
		///Customer Types
		/// </summary>
		public static string CustomerTypes => I18NResource.GetString(ResourceDirectory, "CustomerTypes");

		/// <summary>
		///Customers
		/// </summary>
		public static string Customers => I18NResource.GetString(ResourceDirectory, "Customers");

		/// <summary>
		///Delete
		/// </summary>
		public static string Delete => I18NResource.GetString(ResourceDirectory, "Delete");

		/// <summary>
		///Denominations
		/// </summary>
		public static string Denominations => I18NResource.GetString(ResourceDirectory, "Denominations");

		/// <summary>
		///Description
		/// </summary>
		public static string Description => I18NResource.GetString(ResourceDirectory, "Description");

		/// <summary>
		///Discount
		/// </summary>
		public static string Discount => I18NResource.GetString(ResourceDirectory, "Discount");

		/// <summary>
		///Discount Coupons
		/// </summary>
		public static string DiscountCoupons => I18NResource.GetString(ResourceDirectory, "DiscountCoupons");

		/// <summary>
		///Discount Type
		/// </summary>
		public static string DiscountType => I18NResource.GetString(ResourceDirectory, "DiscountType");

		/// <summary>
		///EOD Cash
		/// </summary>
		public static string EODCash => I18NResource.GetString(ResourceDirectory, "EODCash");

		/// <summary>
		///Effective From
		/// </summary>
		public static string EffectiveFrom => I18NResource.GetString(ResourceDirectory, "EffectiveFrom");

		/// <summary>
		///Enter Amount
		/// </summary>
		public static string EnterAmount => I18NResource.GetString(ResourceDirectory, "EnterAmount");

		/// <summary>
		///Enter a Gift Card Number
		/// </summary>
		public static string EnterGiftCardNumber => I18NResource.GetString(ResourceDirectory, "EnterGiftCardNumber");

		/// <summary>
		///Enter Transaction Id
		/// </summary>
		public static string EnterTransactionId => I18NResource.GetString(ResourceDirectory, "EnterTransactionId");

		/// <summary>
		///Expected Date
		/// </summary>
		public static string ExpectedDate => I18NResource.GetString(ResourceDirectory, "ExpectedDate");

		/// <summary>
		///Expected From
		/// </summary>
		public static string ExpectedFrom => I18NResource.GetString(ResourceDirectory, "ExpectedFrom");

		/// <summary>
		///Expected To
		/// </summary>
		public static string ExpectedTo => I18NResource.GetString(ResourceDirectory, "ExpectedTo");

		/// <summary>
		///Export
		/// </summary>
		public static string Export => I18NResource.GetString(ResourceDirectory, "Export");

		/// <summary>
		///Export This Document
		/// </summary>
		public static string ExportThisDocument => I18NResource.GetString(ResourceDirectory, "ExportThisDocument");

		/// <summary>
		///Export to Doc
		/// </summary>
		public static string ExportToDoc => I18NResource.GetString(ResourceDirectory, "ExportToDoc");

		/// <summary>
		///Export to Excel
		/// </summary>
		public static string ExportToExcel => I18NResource.GetString(ResourceDirectory, "ExportToExcel");

		/// <summary>
		///Export to PDF
		/// </summary>
		public static string ExportToPDF => I18NResource.GetString(ResourceDirectory, "ExportToPDF");

		/// <summary>
		///50
		/// </summary>
		public static string Fifty => I18NResource.GetString(ResourceDirectory, "Fifty");

		/// <summary>
		///5
		/// </summary>
		public static string Five => I18NResource.GetString(ResourceDirectory, "Five");

		/// <summary>
		///500
		/// </summary>
		public static string FiveHundred => I18NResource.GetString(ResourceDirectory, "FiveHundred");

		/// <summary>
		///From
		/// </summary>
		public static string From => I18NResource.GetString(ResourceDirectory, "From");

		/// <summary>
		///Gift Card #
		/// </summary>
		public static string GiftCard => I18NResource.GetString(ResourceDirectory, "GiftCard");

		/// <summary>
		///Gift Card Balance
		/// </summary>
		public static string GiftCardBalance => I18NResource.GetString(ResourceDirectory, "GiftCardBalance");

		/// <summary>
		///Gift Card Fund Sales
		/// </summary>
		public static string GiftCardFundSales => I18NResource.GetString(ResourceDirectory, "GiftCardFundSales");

		/// <summary>
		///Gift Card Fund Verification
		/// </summary>
		public static string GiftCardFundVerification => I18NResource.GetString(ResourceDirectory, "GiftCardFundVerification");

		/// <summary>
		///Gift card Funds
		/// </summary>
		public static string GiftCardFunds => I18NResource.GetString(ResourceDirectory, "GiftCardFunds");

		/// <summary>
		///Gift Card Funds Verification
		/// </summary>
		public static string GiftCardFundsVerification => I18NResource.GetString(ResourceDirectory, "GiftCardFundsVerification");

		/// <summary>
		///Gift Card #
		/// </summary>
		public static string GiftCardNumber => I18NResource.GetString(ResourceDirectory, "GiftCardNumber");

		/// <summary>
		///Gift Cards
		/// </summary>
		public static string GiftCards => I18NResource.GetString(ResourceDirectory, "GiftCards");

		/// <summary>
		///Grand Total
		/// </summary>
		public static string GrandTotal => I18NResource.GetString(ResourceDirectory, "GrandTotal");

		/// <summary>
		///Hide
		/// </summary>
		public static string Hide => I18NResource.GetString(ResourceDirectory, "Hide");

		/// <summary>
		///100
		/// </summary>
		public static string Hundred => I18NResource.GetString(ResourceDirectory, "Hundred");

		/// <summary>
		///Id
		/// </summary>
		public static string Id => I18NResource.GetString(ResourceDirectory, "Id");

		/// <summary>
		///Internal Memo
		/// </summary>
		public static string InternalMemo => I18NResource.GetString(ResourceDirectory, "InternalMemo");

		/// <summary>
		///Invoice Number
		/// </summary>
		public static string InvoiceNumber => I18NResource.GetString(ResourceDirectory, "InvoiceNumber");

		/// <summary>
		///Inv#
		/// </summary>
		public static string InvoiceNumberAbbreviated => I18NResource.GetString(ResourceDirectory, "InvoiceNumberAbbreviated");

		/// <summary>
		///Late Fee
		/// </summary>
		public static string LateFee => I18NResource.GetString(ResourceDirectory, "LateFee");

		/// <summary>
		///Loading items...
		/// </summary>
		public static string LoadingItems => I18NResource.GetString(ResourceDirectory, "LoadingItems");

		/// <summary>
		///Loyalty Point Manager
		/// </summary>
		public static string LoyaltyPointManager => I18NResource.GetString(ResourceDirectory, "LoyaltyPointManager");

		/// <summary>
		///Maximum purchase amount
		/// </summary>
		public static string MaximumPurchaseAmount => I18NResource.GetString(ResourceDirectory, "MaximumPurchaseAmount");

		/// <summary>
		///Memo
		/// </summary>
		public static string Memo => I18NResource.GetString(ResourceDirectory, "Memo");

		/// <summary>
		///Minimum purchase amount
		/// </summary>
		public static string MinimumPurchaseAmount => I18NResource.GetString(ResourceDirectory, "MinimumPurchaseAmount");

		/// <summary>
		///Name
		/// </summary>
		public static string Name => I18NResource.GetString(ResourceDirectory, "Name");

		/// <summary>
		///Next
		/// </summary>
		public static string Next => I18NResource.GetString(ResourceDirectory, "Next");

		/// <summary>
		///Non Taxable Sales
		/// </summary>
		public static string NonTaxableSales => I18NResource.GetString(ResourceDirectory, "NonTaxableSales");

		/// <summary>
		///Office
		/// </summary>
		public static string Office => I18NResource.GetString(ResourceDirectory, "Office");

		/// <summary>
		///Office Id
		/// </summary>
		public static string OfficeId => I18NResource.GetString(ResourceDirectory, "OfficeId");

		/// <summary>
		///Office Name
		/// </summary>
		public static string OfficeName => I18NResource.GetString(ResourceDirectory, "OfficeName");

		/// <summary>
		///1
		/// </summary>
		public static string One => I18NResource.GetString(ResourceDirectory, "One");

		/// <summary>
		///Opening Cash
		/// </summary>
		public static string OpeningCash => I18NResource.GetString(ResourceDirectory, "OpeningCash");

		/// <summary>
		///PO Box
		/// </summary>
		public static string POBox => I18NResource.GetString(ResourceDirectory, "POBox");

		/// <summary>
		///Pay by Check
		/// </summary>
		public static string PayByCheck => I18NResource.GetString(ResourceDirectory, "PayByCheck");

		/// <summary>
		///Pay by Gift Card
		/// </summary>
		public static string PayByGiftCard => I18NResource.GetString(ResourceDirectory, "PayByGiftCard");

		/// <summary>
		///Pay by Check
		/// </summary>
		public static string PayCheck => I18NResource.GetString(ResourceDirectory, "PayCheck");

		/// <summary>
		///Pay by Gift Card
		/// </summary>
		public static string PayGiftCard => I18NResource.GetString(ResourceDirectory, "PayGiftCard");

		/// <summary>
		///Payment Term
		/// </summary>
		public static string PaymentTerm => I18NResource.GetString(ResourceDirectory, "PaymentTerm");

		/// <summary>
		///Payment Terms
		/// </summary>
		public static string PaymentTerms => I18NResource.GetString(ResourceDirectory, "PaymentTerms");

		/// <summary>
		///Phone
		/// </summary>
		public static string Phone => I18NResource.GetString(ResourceDirectory, "Phone");

		/// <summary>
		///Please enter the bank name.
		/// </summary>
		public static string PleaseEnterBankName => I18NResource.GetString(ResourceDirectory, "PleaseEnterBankName");

		/// <summary>
		///Please enter the check date.
		/// </summary>
		public static string PleaseEnterCheckDate => I18NResource.GetString(ResourceDirectory, "PleaseEnterCheckDate");

		/// <summary>
		///Please enter the check number
		/// </summary>
		public static string PleaseEnterCheckNumber => I18NResource.GetString(ResourceDirectory, "PleaseEnterCheckNumber");

		/// <summary>
		///Please enter the gift card number.
		/// </summary>
		public static string PleaseEnterGiftCardNumber => I18NResource.GetString(ResourceDirectory, "PleaseEnterGiftCardNumber");

		/// <summary>
		///Please select an item.
		/// </summary>
		public static string PleaseSelectItem => I18NResource.GetString(ResourceDirectory, "PleaseSelectItem");

		/// <summary>
		///Please select an item from the grid.
		/// </summary>
		public static string PleaseSelectItemGrid => I18NResource.GetString(ResourceDirectory, "PleaseSelectItemGrid");

		/// <summary>
		///Please select a payment term.
		/// </summary>
		public static string PleaseSelectPaymentTerm => I18NResource.GetString(ResourceDirectory, "PleaseSelectPaymentTerm");

		/// <summary>
		///PostedBy
		/// </summary>
		public static string PostedBy => I18NResource.GetString(ResourceDirectory, "PostedBy");

		/// <summary>
		///Posted On
		/// </summary>
		public static string PostedOn => I18NResource.GetString(ResourceDirectory, "PostedOn");

		/// <summary>
		///Price Type
		/// </summary>
		public static string PriceType => I18NResource.GetString(ResourceDirectory, "PriceType");

		/// <summary>
		///Price Types
		/// </summary>
		public static string PriceTypes => I18NResource.GetString(ResourceDirectory, "PriceTypes");

		/// <summary>
		///Print
		/// </summary>
		public static string Print => I18NResource.GetString(ResourceDirectory, "Print");

		/// <summary>
		///Provided By
		/// </summary>
		public static string ProvidedBy => I18NResource.GetString(ResourceDirectory, "ProvidedBy");

		/// <summary>
		///Rate
		/// </summary>
		public static string Rate => I18NResource.GetString(ResourceDirectory, "Rate");

		/// <summary>
		///Reason
		/// </summary>
		public static string Reason => I18NResource.GetString(ResourceDirectory, "Reason");

		/// <summary>
		///Reference Number
		/// </summary>
		public static string ReferenceNumber => I18NResource.GetString(ResourceDirectory, "ReferenceNumber");

		/// <summary>
		///Ref#
		/// </summary>
		public static string ReferenceNumberAbbreviated => I18NResource.GetString(ResourceDirectory, "ReferenceNumberAbbreviated");

		/// <summary>
		///Reject
		/// </summary>
		public static string Reject => I18NResource.GetString(ResourceDirectory, "Reject");

		/// <summary>
		///Reprint
		/// </summary>
		public static string Reprint => I18NResource.GetString(ResourceDirectory, "Reprint");

		/// <summary>
		///Reprint Ticket
		/// </summary>
		public static string ReprintTicket => I18NResource.GetString(ResourceDirectory, "ReprintTicket");

		/// <summary>
		///Reward Points
		/// </summary>
		public static string RewardPoints => I18NResource.GetString(ResourceDirectory, "RewardPoints");

		/// <summary>
		///Sales
		/// </summary>
		public static string Sales => I18NResource.GetString(ResourceDirectory, "Sales");

		/// <summary>
		///Sales Entries
		/// </summary>
		public static string SalesEntries => I18NResource.GetString(ResourceDirectory, "SalesEntries");

		/// <summary>
		///Sales Order
		/// </summary>
		public static string SalesOrder => I18NResource.GetString(ResourceDirectory, "SalesOrder");

		/// <summary>
		///Sales Order Checklist
		/// </summary>
		public static string SalesOrderChecklist => I18NResource.GetString(ResourceDirectory, "SalesOrderChecklist");

		/// <summary>
		///Sales Orders
		/// </summary>
		public static string SalesOrders => I18NResource.GetString(ResourceDirectory, "SalesOrders");

		/// <summary>
		///Sales Quotation
		/// </summary>
		public static string SalesQuotation => I18NResource.GetString(ResourceDirectory, "SalesQuotation");

		/// <summary>
		///Sales Quotation Checklist
		/// </summary>
		public static string SalesQuotationChecklist => I18NResource.GetString(ResourceDirectory, "SalesQuotationChecklist");

		/// <summary>
		///Sales Quotations
		/// </summary>
		public static string SalesQuotations => I18NResource.GetString(ResourceDirectory, "SalesQuotations");

		/// <summary>
		///Sales Receipt
		/// </summary>
		public static string SalesReceipt => I18NResource.GetString(ResourceDirectory, "SalesReceipt");

		/// <summary>
		///Sales Return Verification
		/// </summary>
		public static string SalesReturnVerification => I18NResource.GetString(ResourceDirectory, "SalesReturnVerification");

		/// <summary>
		///Sales Returns
		/// </summary>
		public static string SalesReturns => I18NResource.GetString(ResourceDirectory, "SalesReturns");

		/// <summary>
		///Sales Verification
		/// </summary>
		public static string SalesVerification => I18NResource.GetString(ResourceDirectory, "SalesVerification");

		/// <summary>
		///Save
		/// </summary>
		public static string Save => I18NResource.GetString(ResourceDirectory, "Save");

		/// <summary>
		///Search ...
		/// </summary>
		public static string Search => I18NResource.GetString(ResourceDirectory, "Search");

		/// <summary>
		///Search Customer
		/// </summary>
		public static string SearchCustomer => I18NResource.GetString(ResourceDirectory, "SearchCustomer");

		/// <summary>
		///Search Gift Card
		/// </summary>
		public static string SearchGiftCard => I18NResource.GetString(ResourceDirectory, "SearchGiftCard");

		/// <summary>
		///Select
		/// </summary>
		public static string Select => I18NResource.GetString(ResourceDirectory, "Select");

		/// <summary>
		///Select & Close
		/// </summary>
		public static string SelectAndClose => I18NResource.GetString(ResourceDirectory, "SelectAndClose");

		/// <summary>
		///Select Cost Center
		/// </summary>
		public static string SelectCostCenter => I18NResource.GetString(ResourceDirectory, "SelectCostCenter");

		/// <summary>
		///Select Debit Account
		/// </summary>
		public static string SelectDebitAccount => I18NResource.GetString(ResourceDirectory, "SelectDebitAccount");

		/// <summary>
		///Selling Prices
		/// </summary>
		public static string SellingPrices => I18NResource.GetString(ResourceDirectory, "SellingPrices");

		/// <summary>
		///Shipper
		/// </summary>
		public static string Shipper => I18NResource.GetString(ResourceDirectory, "Shipper");

		/// <summary>
		///Show
		/// </summary>
		public static string Show => I18NResource.GetString(ResourceDirectory, "Show");

		/// <summary>
		///Show Less
		/// </summary>
		public static string ShowLess => I18NResource.GetString(ResourceDirectory, "ShowLess");

		/// <summary>
		///Show More
		/// </summary>
		public static string ShowMore => I18NResource.GetString(ResourceDirectory, "ShowMore");

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
		///Store
		/// </summary>
		public static string Store => I18NResource.GetString(ResourceDirectory, "Store");

		/// <summary>
		///Sub Total
		/// </summary>
		public static string SubTotal => I18NResource.GetString(ResourceDirectory, "SubTotal");

		/// <summary>
		///Submitted Amount
		/// </summary>
		public static string SubmittedAmount => I18NResource.GetString(ResourceDirectory, "SubmittedAmount");

		/// <summary>
		///The submitted amount must be equal to total amount.
		/// </summary>
		public static string SubmittedAmountMustEqualTotalAmount => I18NResource.GetString(ResourceDirectory, "SubmittedAmountMustEqualTotalAmount");

		/// <summary>
		///Submitted Cash
		/// </summary>
		public static string SubmittedCash => I18NResource.GetString(ResourceDirectory, "SubmittedCash");

		/// <summary>
		///Submitted To
		/// </summary>
		public static string SubmittedTo => I18NResource.GetString(ResourceDirectory, "SubmittedTo");

		/// <summary>
		///Tax
		/// </summary>
		public static string Tax => I18NResource.GetString(ResourceDirectory, "Tax");

		/// <summary>
		///100
		/// </summary>
		public static string Ten => I18NResource.GetString(ResourceDirectory, "Ten");

		/// <summary>
		///Tender
		/// </summary>
		public static string Tender => I18NResource.GetString(ResourceDirectory, "Tender");

		/// <summary>
		///Terms
		/// </summary>
		public static string Terms => I18NResource.GetString(ResourceDirectory, "Terms");

		/// <summary>
		///Terms & Conditions
		/// </summary>
		public static string TermsConditions => I18NResource.GetString(ResourceDirectory, "TermsConditions");

		/// <summary>
		///this evening
		/// </summary>
		public static string ThisEvening => I18NResource.GetString(ResourceDirectory, "ThisEvening");

		/// <summary>
		///1000
		/// </summary>
		public static string Thousand => I18NResource.GetString(ResourceDirectory, "Thousand");

		/// <summary>
		///title
		/// </summary>
		public static string Title => I18NResource.GetString(ResourceDirectory, "Title");

		/// <summary>
		///To
		/// </summary>
		public static string To => I18NResource.GetString(ResourceDirectory, "To");

		/// <summary>
		///Today's Beginning Cash
		/// </summary>
		public static string TodayBeginningCash => I18NResource.GetString(ResourceDirectory, "TodayBeginningCash");

		/// <summary>
		///Toggle View
		/// </summary>
		public static string ToggleView => I18NResource.GetString(ResourceDirectory, "ToggleView");

		/// <summary>
		///Total
		/// </summary>
		public static string Total => I18NResource.GetString(ResourceDirectory, "Total");

		/// <summary>
		///Total Sales
		/// </summary>
		public static string TotalSales => I18NResource.GetString(ResourceDirectory, "TotalSales");

		/// <summary>
		///:Total Usage
		/// </summary>
		public static string TotalUsage => I18NResource.GetString(ResourceDirectory, "TotalUsage");

		/// <summary>
		///Tran Code
		/// </summary>
		public static string TranCode => I18NResource.GetString(ResourceDirectory, "TranCode");

		/// <summary>
		///Tran Date
		/// </summary>
		public static string TranDate => I18NResource.GetString(ResourceDirectory, "TranDate");

		/// <summary>
		///Tran Id
		/// </summary>
		public static string TranId => I18NResource.GetString(ResourceDirectory, "TranId");

		/// <summary>
		///Transaction was posted successfully.
		/// </summary>
		public static string TransactionPostedSuccessfully => I18NResource.GetString(ResourceDirectory, "TransactionPostedSuccessfully");

		/// <summary>
		///20
		/// </summary>
		public static string Twenty => I18NResource.GetString(ResourceDirectory, "Twenty");

		/// <summary>
		///25
		/// </summary>
		public static string TwentyFive => I18NResource.GetString(ResourceDirectory, "TwentyFive");

		/// <summary>
		///2
		/// </summary>
		public static string Two => I18NResource.GetString(ResourceDirectory, "Two");

		/// <summary>
		///200
		/// </summary>
		public static string Twohundred => I18NResource.GetString(ResourceDirectory, "Twohundred");

		/// <summary>
		///250
		/// </summary>
		public static string TwohundredFifty => I18NResource.GetString(ResourceDirectory, "TwohundredFifty");

		/// <summary>
		///Unverified
		/// </summary>
		public static string Unverified => I18NResource.GetString(ResourceDirectory, "Unverified");

		/// <summary>
		///Use
		/// </summary>
		public static string Use => I18NResource.GetString(ResourceDirectory, "Use");

		/// <summary>
		///User Id
		/// </summary>
		public static string UserId => I18NResource.GetString(ResourceDirectory, "UserId");

		/// <summary>
		///Value Date
		/// </summary>
		public static string ValueDate => I18NResource.GetString(ResourceDirectory, "ValueDate");

		/// <summary>
		///Verification Reason
		/// </summary>
		public static string VerificationReason => I18NResource.GetString(ResourceDirectory, "VerificationReason");

		/// <summary>
		///Verified By
		/// </summary>
		public static string VerifiedBy => I18NResource.GetString(ResourceDirectory, "VerifiedBy");

		/// <summary>
		///Verified On
		/// </summary>
		public static string VerifiedOn => I18NResource.GetString(ResourceDirectory, "VerifiedOn");

		/// <summary>
		///Verify
		/// </summary>
		public static string Verify => I18NResource.GetString(ResourceDirectory, "Verify");

		/// <summary>
		///View Order
		/// </summary>
		public static string ViewOrder => I18NResource.GetString(ResourceDirectory, "ViewOrder");

		/// <summary>
		///View Quotation
		/// </summary>
		public static string ViewQuotation => I18NResource.GetString(ResourceDirectory, "ViewQuotation");

		/// <summary>
		///View Sales
		/// </summary>
		public static string ViewSales => I18NResource.GetString(ResourceDirectory, "ViewSales");

		/// <summary>
		///View Sales Orders
		/// </summary>
		public static string ViewSalesOrders => I18NResource.GetString(ResourceDirectory, "ViewSalesOrders");

		/// <summary>
		///View Sales Quotation
		/// </summary>
		public static string ViewSalesQuotation => I18NResource.GetString(ResourceDirectory, "ViewSalesQuotation");

		/// <summary>
		///You
		/// </summary>
		public static string You => I18NResource.GetString(ResourceDirectory, "You");

		/// <summary>
		///you may also edit the beginning cash later
		/// </summary>
		public static string YouMayEditBeginningCashLater => I18NResource.GetString(ResourceDirectory, "YouMayEditBeginningCashLater");

		/// <summary>
		///Your Cash Sales
		/// </summary>
		public static string YourCashSales => I18NResource.GetString(ResourceDirectory, "YourCashSales");

		/// <summary>
		///Your Sales for
		/// </summary>
		public static string YourSalesFor => I18NResource.GetString(ResourceDirectory, "YourSalesFor");

		/// <summary>
		///ZIP Code
		/// </summary>
		public static string ZIPCode => I18NResource.GetString(ResourceDirectory, "ZIPCode");

	}
}
