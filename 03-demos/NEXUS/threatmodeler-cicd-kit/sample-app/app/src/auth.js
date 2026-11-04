const jwt = require("jsonwebtoken");

// Merchant users authenticate with a bearer JWT issued by the identity provider.
function requireAuth(req, res, next) {
  const header = req.get("authorization") || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;
  if (!token) return res.sendStatus(401);
  try {
    const claims = jwt.verify(token, process.env.JWT_PUBLIC_KEY, { algorithms: ["RS256"] });
    req.user = { id: claims.sub, merchantId: claims.merchant_id };
    next();
  } catch {
    res.sendStatus(401);
  }
}

module.exports = { requireAuth };
