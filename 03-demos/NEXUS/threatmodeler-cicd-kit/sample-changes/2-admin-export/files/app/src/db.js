const { Pool } = require("pg");

const creds = JSON.parse(process.env.DB_CREDENTIALS || "{}");
const pool = new Pool({
  host: process.env.DB_HOST,
  database: "ledgerlite",
  user: creds.username,
  password: creds.password,
  ssl: { rejectUnauthorized: true },
});

async function listInvoices(merchantId) {
  const { rows } = await pool.query(
    "SELECT id, customer_id, amount_cents, currency, status FROM invoices WHERE merchant_id = $1",
    [merchantId]
  );
  return rows;
}

async function getInvoice(merchantId, id) {
  const { rows } = await pool.query(
    "SELECT * FROM invoices WHERE merchant_id = $1 AND id = $2",
    [merchantId, id]
  );
  return rows[0];
}

async function createInvoice(merchantId, { customerId, amountCents, currency }) {
  const { rows } = await pool.query(
    "INSERT INTO invoices (merchant_id, customer_id, amount_cents, currency, status) VALUES ($1,$2,$3,$4,'open') RETURNING *",
    [merchantId, customerId, amountCents, currency]
  );
  return rows[0];
}

async function exportAllInvoices() {
  const { rows } = await pool.query("SELECT * FROM invoices");
  return rows;
}

module.exports = { listInvoices, getInvoice, createInvoice, exportAllInvoices };
