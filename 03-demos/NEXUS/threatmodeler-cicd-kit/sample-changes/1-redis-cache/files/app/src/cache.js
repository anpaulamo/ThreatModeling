const { createClient } = require("redis");

const client = createClient({ url: process.env.REDIS_URL });
client.connect().catch((err) => console.error("redis connect failed", err));

async function cached(key, ttlSeconds, load) {
  const hit = await client.get(key);
  if (hit) return JSON.parse(hit);
  const value = await load();
  await client.set(key, JSON.stringify(value), { EX: ttlSeconds });
  return value;
}

module.exports = { cached };
