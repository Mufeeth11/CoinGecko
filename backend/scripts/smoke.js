'use strict';

const assert = require('node:assert/strict');
const { createUpstreamServer } = require('../test/fixtures/upstream');

let passed = 0;

function ok(message) {
  passed += 1;
  console.log(`  ✓ ${message}`);
}

async function request(server, path, options) {
  const { port } = server.address();
  const response = await fetch(`http://127.0.0.1:${port}${path}`, options);
  const text = await response.text();
  let body = text;
  try {
    body = text ? JSON.parse(text) : null;
  } catch {
    body = text;
  }
  return { response, body };
}

async function main() {
  const upstream = createUpstreamServer();
  await new Promise((resolve, reject) => {
    upstream.once('error', reject);
    upstream.listen(0, '127.0.0.1', resolve);
  });
  process.env.COINGECKO_BASE_URL = `http://127.0.0.1:${upstream.address().port}`;
  const { createAppServer } = require('../server');

  const server = createAppServer();
  await new Promise((resolve, reject) => {
    server.once('error', reject);
    server.listen(0, '127.0.0.1', resolve);
  });

  try {
    let result = await request(server, '/api/health');
    assert.equal(result.response.status, 200);
    assert.equal(result.body.status, 'ok');
    assert.equal(result.body.mode, 'live');
    ok('health reports status and live source');

    result = await request(server, '/api/categories');
    assert.equal(result.response.status, 200);
    assert.ok(result.body.categories.includes('Layer 1'));
    assert.ok(result.body.categories.includes('Stablecoin'));
    assert.equal(result.response.headers.get('x-data-source'), 'live');
    ok('categories come from the live upstream feed');

    result = await request(server, '/api/coins');
    assert.equal(result.response.status, 200);
    assert.ok(result.body.coins.length > 5);
    assert.equal(result.body.source, 'live');
    assert.equal(result.response.headers.get('access-control-allow-origin'), '*');
    const sample = result.body.coins[0];
    for (const field of ['id', 'symbol', 'name', 'currentPrice', 'marketCap', 'totalVolume']) {
      assert.ok(sample[field] !== undefined, `missing normalized field: ${field}`);
    }
    ok('markets return normalized live coin fields and CORS headers');

    result = await request(server, '/api/coins?search=btc');
    assert.equal(result.response.status, 200);
    assert.deepEqual(
      result.body.coins.map((coin) => coin.id),
      ['bitcoin'],
    );
    ok('market search filters by symbol');

    result = await request(server, '/api/coins?category=Stablecoin');
    assert.equal(result.response.status, 200);
    assert.ok(result.body.coins.length >= 2);
    assert.ok(result.body.coins.every((coin) => coin.category === 'Stablecoin'));
    ok('market category filter is applied server-side');

    result = await request(server, '/api/coins/bitcoin');
    assert.equal(result.response.status, 200);
    assert.equal(result.body.id, 'bitcoin');
    assert.equal(result.body.source, 'live');
    assert.ok(result.body.currentPrice > 0);
    assert.ok(result.body.description.length > 0);
    assert.ok(result.body.circulatingSupply > 0);
    ok('coin detail includes price, supply and description');

    result = await request(server, '/api/coins/bitcoin/market_chart?days=30');
    assert.equal(result.response.status, 200);
    assert.equal(result.body.days, '30');
    assert.ok(result.body.prices.length > 2);
    assert.ok(result.body.prices[0][0] < result.body.prices.at(-1)[0]);
    assert.ok(result.body.marketCaps.length === result.body.prices.length);
    assert.ok(result.body.totalVolumes.length === result.body.prices.length);
    ok('market chart honours the requested window');

    result = await request(server, '/api/coins/missing-coin/market_chart?days=7');
    assert.equal(result.response.status, 404);
    ok('unknown chart ids return 404');

    result = await request(server, '/api/global');
    assert.equal(result.response.status, 200);
    assert.ok(result.body.totalMarketCap > 0);
    assert.ok(result.body.btcDominance > 0);
    assert.ok(result.body.updatedAt);
    ok('global statistics are normalized');

    result = await request(server, '/api/not-a-route');
    assert.equal(result.response.status, 404);
    assert.equal(result.body.error, 'Not found');
    ok('unknown routes return a JSON 404');

    result = await request(server, '/api/health', { method: 'POST' });
    assert.equal(result.response.status, 405);
    ok('non-GET methods return 405');

    console.log(`\nBackend smoke checks passed: ${passed}`);
  } finally {
    await new Promise((resolve) => server.close(resolve));
    await new Promise((resolve) => upstream.close(resolve));
  }
}

main().catch((error) => {
  console.error('Backend smoke checks failed:', error);
  process.exitCode = 1;
});
