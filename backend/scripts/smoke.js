'use strict';

// End-to-end HTTP smoke test: starts the real server and exercises the same
// contract the Flutter client consumes. Forces mock mode so CI is offline-safe.
process.env.DATA_MODE = 'mock';

const assert = require('node:assert/strict');
const { createAppServer } = require('../server');

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
    // Keep the raw text; assertions will produce a useful message.
  }
  return { response, body };
}

async function main() {
  const server = createAppServer();
  await new Promise((resolve, reject) => {
    server.once('error', reject);
    server.listen(0, '127.0.0.1', resolve);
  });

  try {
    let result = await request(server, '/api/health');
    assert.equal(result.response.status, 200);
    assert.equal(result.body.status, 'ok');
    assert.equal(result.body.mode, 'mock');
    ok('health reports status and active mode');

    result = await request(server, '/api/categories');
    assert.equal(result.response.status, 200);
    assert.ok(result.body.categories.includes('Layer 1'));
    assert.ok(result.body.categories.includes('Stablecoin'));
    assert.equal(result.response.headers.get('x-data-source'), 'mock');
    ok('categories are returned from the mock source');

    result = await request(server, '/api/coins');
    assert.equal(result.response.status, 200);
    assert.ok(result.body.coins.length > 5);
    assert.equal(result.body.source, 'mock');
    assert.equal(result.response.headers.get('access-control-allow-origin'), '*');
    const sample = result.body.coins[0];
    for (const field of ['id', 'symbol', 'name', 'currentPrice', 'marketCap', 'totalVolume']) {
      assert.ok(sample[field] !== undefined, `missing normalized field: ${field}`);
    }
    ok('markets return normalized coin fields and CORS headers');

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
  }
}

main().catch((error) => {
  console.error('Backend smoke checks failed:', error);
  process.exitCode = 1;
});
