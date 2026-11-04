// LedgerLite API: a small B2B invoicing service used to exercise the
// ThreatModeler PR pipeline. Behind a public ALB, runs on ECS Fargate,
// stores records in Postgres and invoice PDFs in S3.
const express = require("express");
const { requireAuth } = require("./auth");
const db = require("./db");
const storage = require("./storage");
const { cached } = require("./cache");

const app = express();
app.use(express.json({ limit: "100kb" }));

app.get("/health", (_req, res) => res.json({ status: "ok" }));

app.get("/invoices", requireAuth, async (req, res) => {
  const rows = await cached(`invoices:${req.user.merchantId}`, 60, () =>
    db.listInvoices(req.user.merchantId)
  );
  res.json(rows);
});

app.post("/invoices", requireAuth, async (req, res) => {
  const { customerId, amountCents, currency } = req.body || {};
  if (!customerId || !Number.isInteger(amountCents) || !currency) {
    return res.status(400).json({ error: "invalid invoice" });
  }
  const invoice = await db.createInvoice(req.user.merchantId, { customerId, amountCents, currency });
  await storage.putInvoicePdf(invoice);
  res.status(201).json(invoice);
});

app.get("/invoices/:id/pdf", requireAuth, async (req, res) => {
  const invoice = await db.getInvoice(req.user.merchantId, req.params.id);
  if (!invoice) return res.sendStatus(404);
  res.json({ url: await storage.signedPdfUrl(invoice) });
});

app.listen(8080, () => console.log("ledgerlite-api listening on 8080"));
