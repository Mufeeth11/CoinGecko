# CoinScope Backend

Dependency-free Node.js HTTP API used by the Flutter app. It proxies and normalizes live CoinGecko v3 responses and caches them briefly. There is no offline or fallback dataset: when the upstream API is unavailable, the API returns an error and the client shows its error state.

## Requirements

- Node.js 18+ (uses built-in `fetch`, `AbortController` and `node:test`)

## Start

```bash
npm start
```

The server only serves live upstream data. Upstream failures return `502`, and the Flutter app shows the matching error state instead of displaying cached or sample values.

The server logs its listening URL and source, and each response includes `X-Data-Source: live`.

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| `PORT` | `3000` | Listen port |
| `COINGECKO_BASE_URL` | `https://api.coingecko.com/api/v3` | Upstream base URL |
| `COINGECKO_API_KEY` | empty | Sent as `x-cg-demo-api-key` when set |
| `CACHE_TTL_MS` | `60000` | Live cache lifetime |
| `UPSTREAM_TIMEOUT_MS` | `4000` | Abort timeout for upstream calls |

## API

All paths are under `/api`. Responses are JSON with `Access-Control-Allow-Origin: *` and an `X-Data-Source: live` header.

| Path | Query | Response |
| --- | --- | --- |
| `/health` | — | `{ status, mode, timestamp }` |
| `/categories` | — | `{ categories: string[] }` |
| `/coins` | `search`, `category` | `{ coins: Coin[], source, updatedAt }` |
| `/coins/:id` | — | Normalized coin detail object + `source` |
| `/coins/:id/market_chart` | `days` (default `7`) | `{ prices, marketCaps, totalVolumes, id, days, source }` |
| `/global` | — | Global stats object + `source` |

Unknown paths return `404`; non-GET methods return `405`. Upstream failures return `502`.

Normalized coin fields include `id`, `symbol`, `name`, `image`, `category`, `currentPrice`, `marketCap`, `marketCapRank`, `totalVolume`, `circulatingSupply`, optional `totalSupply`/`maxSupply`, and percentage changes.

## Tests

```bash
npm test
npm run smoke
```

`npm test` covers normalization and route behavior with `node:test`. `npm run smoke` starts the real server against a deterministic local upstream stub on an ephemeral port and checks the complete HTTP contract end-to-end. The stub lives in `test/fixtures/upstream.js` and is used only by tests.
