'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { createUpstreamServer } = require('./fixtures/upstream');

let upstreamServer;
let createAppServer;
let stripHtml;

test.before(async () => {
  upstreamServer = createUpstreamServer();
  await new Promise((resolve) => upstreamServer.listen(0, '127.0.0.1', resolve));
  process.env.COINGECKO_BASE_URL = `http://127.0.0.1:${upstreamServer.address().port}`;
  ({ createAppServer, stripHtml } = require('../server'));
});

test.after(async () => {
  if (upstreamServer) {
    await new Promise((resolve) => upstreamServer.close(resolve));
  }
});

async function withServer(callback) {
  const server = createAppServer();
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const base = `http://127.0.0.1:${server.address().port}`;
  try {
    await callback(base);
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

test('GET /api/health reports service status', async () => {
  await withServer(async (base) => {
    const response = await fetch(`${base}/api/health`);
    assert.equal(response.status, 200);
    const body = await response.json();
    assert.equal(body.status, 'ok');
    assert.equal(body.mode, 'live');
    assert.equal(response.headers.get('x-data-source'), 'live');
  });
});

test('GET /api/categories returns live upstream categories', async () => {
  await withServer(async (base) => {
    const response = await fetch(`${base}/api/categories`);
    const body = await response.json();
    assert.ok(body.categories.includes('Layer 1'));
    assert.ok(body.categories.includes('Stablecoin'));
    assert.equal(response.headers.get('x-data-source'), 'live');
  });
});

test('GET /api/coins returns normalized market data', async () => {
  await withServer(async (base) => {
    const response = await fetch(`${base}/api/coins`);
    const body = await response.json();
    assert.equal(body.source, 'live');
    assert.ok(body.coins.length >= 10);
    const bitcoin = body.coins.find((coin) => coin.id === 'bitcoin');
    assert.ok(bitcoin.currentPrice > 0);
    assert.ok(bitcoin.marketCap > 0);
    assert.ok(bitcoin.sparkline.length > 10);
    assert.ok(bitcoin.category);
  });
});

test('GET /api/coins supports search and category filters', async () => {
  await withServer(async (base) => {
    const search = await (await fetch(`${base}/api/coins?search=eth`)).json();
    assert.deepEqual(search.coins.map((coin) => coin.id).sort(), ['ethereum', 'tether']);

    const memes = await (await fetch(`${base}/api/coins?category=Meme`)).json();
    assert.ok(memes.coins.length > 0);
    assert.ok(memes.coins.every((coin) => coin.category === 'Meme'));
  });
});

test('GET /api/coins/:id returns detail fields', async () => {
  await withServer(async (base) => {
    const response = await fetch(`${base}/api/coins/solana`);
    assert.equal(response.status, 200);
    const body = await response.json();
    assert.equal(body.id, 'solana');
    assert.equal(body.source, 'live');
    assert.ok(body.description.length > 10);
    assert.ok(body.high24h > body.low24h);
    assert.ok(body.ath > body.currentPrice);
  });
});

test('GET /api/coins/:id/market_chart honours the days window', async () => {
  await withServer(async (base) => {
    const response = await fetch(`${base}/api/coins/bitcoin/market_chart?days=1`);
    assert.equal(response.status, 200);
    const body = await response.json();
    assert.equal(body.days, '1');
    assert.equal(body.prices.length, 24);
    assert.equal(body.marketCaps.length, body.prices.length);
    assert.ok(body.prices.every((point) => point.length === 2 && point[1] > 0));
  });
});

test('GET /api/global and unknown routes', async () => {
  await withServer(async (base) => {
    const global = await (await fetch(`${base}/api/global`)).json();
    assert.ok(global.totalMarketCap > 0);
    assert.ok(global.btcDominance > 0);

    const missing = await fetch(`${base}/api/nope`);
    assert.equal(missing.status, 404);
  });
});

test('stripHtml removes markup from descriptions', () => {
  assert.equal(stripHtml('<p>Hello <b>world</b></p>'), 'Hello world');
});
