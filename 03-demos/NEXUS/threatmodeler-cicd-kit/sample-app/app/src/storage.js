const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");

const s3 = new S3Client({});
const bucket = process.env.INVOICE_BUCKET;

async function putInvoicePdf(invoice) {
  const body = Buffer.from(`Invoice ${invoice.id}: ${invoice.amount_cents} ${invoice.currency}`);
  await s3.send(new PutObjectCommand({
    Bucket: bucket,
    Key: `invoices/${invoice.merchant_id}/${invoice.id}.pdf`,
    Body: body,
    ContentType: "application/pdf",
  }));
}

async function signedPdfUrl(invoice) {
  // Pre-signed URL generation omitted in the demo.
  return `s3://${bucket}/invoices/${invoice.merchant_id}/${invoice.id}.pdf`;
}

module.exports = { putInvoicePdf, signedPdfUrl };
