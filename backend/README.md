# CoinScope Backend

Dependency-free Node.js HTTP API used by the Flutter app. It proxies and normalizes CoinGecko v3 responses, caches them briefly, and falls back to deterministic mock data when the upstream API is unavailable or rate-limited.

## Requirements

- Node.js 18+ (uses built-in `fetch`, `AbortController` and `node:test`)

## Start

```bash
npm start
```

PowerShell demo mode:

```powershell
$env:DATA_MODE='mock'; npm start
```

The server logs its listening URL and active mode.

## Modes

| `DATA_MODE` | Behavior |
| --- | --- |
| `auto` (default) | Try CoinGecko, fall back to mock on any failure |
| `mock` | Always serve deterministic sample data; no network calls upstream |
| `live` | Serve upstream data only; return `502` if upstream fails |

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| `PORT` | `3000` | Listen port |
| `COINGECKO_BASE_URL` | `https://api.coingecko.com/api/v3` | Upstream base URL |
| `COINGECKO_API_KEY` | empty | Sent as `x-cg-demo-api-key` when set |
| `CACHE_TTL_MS` | `60000` | Live cache lifetime |
| `FALLBACK_TTL_MS` | `60000` | Mock cache lifetime |
| `UPSTREAM_TIMEOUT_MS` | `4000` | Abort timeout for upstream calls |

## API

All paths are under `/api`. Responses are JSON with `Access-Control-Allow-Origin: *` and an `X-Data-Source: live|mock` header.

| Path | Query | Response |
| --- | --- | --- |
| `/health` | — | `{ status, mode, timestamp }` |
| `/categories` | — | `{ categories: string[] }` |
| `/coins` | `search`, `category` | `{ coins: Coin[], source, updatedAt }` |
| `/coins/:id` | — | Normalized coin detail object + `source` |
| `/coins/:id/market_chart` | `days` (default `7`) | `{ prices, marketCaps, totalVolumes, id, days, source }` |
| `/global` | — | Global stats object + `source` |

Unknown paths return `404`; non-GET methods return `405`. Upstream failures in `live` mode return `502`.

Normalized coin fields include `id`, `symbol`, `name`, `image`, `category`, `currentPrice`, `marketCap`, `marketCapRank`, `totalVolume`, `circulatingSupply`, optional `totalSupply`/`maxSupply`, and percentage changes.

## Tests

```bash
npm test
npm run smoke
```

`npm test` covers normalization and route behavior with `node:test`. `npm run smoke` spins up the real server on an ephemeral port and checks the complete HTTP contract end-to-end.
