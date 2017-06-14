using Frapid.Configuration;
using Frapid.Paylink;
using MixERP.Sales.Models;
using Newtonsoft.Json;
using System;
using System.Drawing.Imaging;
using System.IO;
using System.Web;
using System.Web.Mvc;
using ZXing;
using ZXing.Common;

namespace MixERP.Sales.Extensions
{
    public static class HtmlHelperExtensions
    {

        public static IHtmlString FreebeQrCode(this HtmlHelper html, long transId, string alt = "Freebe Sales QR code", int height = 250, int width = 250, int margin = 0)
        {
            var model = Tickets.GetTicketViewModelAsync(TenantConvention.GetTenant(), transId).Result;

            if (model.View == null)
            {
                return null;
            }

            SalesQRCode qrCode = SalesQRCode.Generate(model);

            var barcodeWriter = new BarcodeWriter
            {
                Format = BarcodeFormat.QR_CODE,
                Options = new EncodingOptions
                {
                    Height = height,
                    Width = width,
                    Margin = 2
                }
            };

            var encryptedCode = PaylinkSecurity.Encrypt(JsonConvert.SerializeObject(qrCode));

            using (var bitmap = barcodeWriter.Write(encryptedCode))
            using (var stream = new MemoryStream())
            {
                bitmap.Save(stream, ImageFormat.Gif);

                var img = new TagBuilder("img");
                img.MergeAttribute("alt", alt);
                img.Attributes.Add("src", string.Format("data:image/gif;base64,{0}",
                    Convert.ToBase64String(stream.ToArray())));

                return MvcHtmlString.Create(img.ToString(TagRenderMode.SelfClosing));
            }
        }
    }
}