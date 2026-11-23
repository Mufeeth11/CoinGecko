# CoinScope — Flutter Crypto Research App

A mini CoinGecko-style research app built with **Flutter** and **Clean Architecture**, backed by a small **Node.js** API that normalizes CoinGecko data and falls back to deterministic mock data when the upstream API is unavailable.

The app is fully usable offline in `mock` mode: real screens, real API calls, real state management, real persistence — only the data source is local to the backend.

## Features

- **Markets**
  - Coin list with price, rank, 24h change, volume, market cap and sparkline
  - Debounced search by name or symbol
  - Quick filters (All, Gainers, Losers, Favorites) and dynamic category chips
  - Sort sheet for market cap, price, volume and 24h change (ascending/descending)
  - Pull-to-refresh, loading skeletons, retryable errors and empty states
- **Coin details**
  - Interactive `fl_chart` price chart with `1D / 7D / 30D / 90D / 1Y` windows and touch tooltip
  - Supply, market cap, volume, ATH/ATL and multi-period change metrics
  - Watchlist star and manual refresh
- **Statistics**
  - Global market cap, 24h volume, 24h market movement, BTC/ETH dominance and active markets
  - Source badge showing whether data came from `live` or `mock`
- **Watchlist**
  - Persistent favorites via `shared_preferences`
  - Empty state with a shortcut back to Markets

## Architecture

```text
lib/
  core/                         # Network, config, errors, Either, theme, shared widgets, DI
  features/
    crypto/
      data/                     # DTOs, remote datasource, repository implementation
      domain/                   # Entities, repository contract, use cases
      presentation/             # Cubits, screens, reusable widgets
    watchlist/
      data/                     # SharedPreferences local datasource + repository impl
      domain/                   # Watchlist repository contract + use cases
      presentation/             # WatchlistCubit
backend/
  server.js                     # HTTP API, normalization, cache, proxy/fallback logic
  mock-data.js                  # Deterministic demo dataset and chart generator
  scripts/smoke.js              # End-to-end API smoke check
test/                           # Dart unit, cubit and widget tests
```

Dependency direction stays strict:

```text
presentation ──▶ domain ◀── data
```

- Presentation depends only on domain entities, repository abstractions and use cases.
- Data layer implements domain repository contracts and maps exceptions to `Failure`.
- Domain has no Flutter, HTTP or storage imports.
- `AppDependencies` is the only manual composition root.

## Backend

Node.js 18+, no third-party packages required.

### Run

```bash
cd backend
npm start
```

`npm start` uses `auto` mode: it tries CoinGecko first, so the app shows **real live data** whenever the upstream API is reachable. If CoinGecko is offline or rate-limited, it falls back to mock data automatically.

Guaranteed live mode — show an error instead of falling back:

```powershell
$env:DATA_MODE='live'; npm start
```

Deterministic offline demo:

```powershell
$env:DATA_MODE='mock'; npm start
```

The app header shows `LIVE API` or `MOCK DATA`, and every response includes an `X-Data-Source` header.

### Configuration

| Variable | Default | Purpose |
| --- | --- | --- |
| `PORT` | `3000` | HTTP port |
| `DATA_MODE` | `auto` | `auto`, `mock` or `live` |
| `COINGECKO_BASE_URL` | public v3 API | Override upstream |
| `COINGECKO_API_KEY` | empty | Optional demo API key |
| `CACHE_TTL_MS` | `60000` | Live response cache |
| `FALLBACK_TTL_MS` | `60000` | Mock response cache |
| `UPSTREAM_TIMEOUT_MS` | `4000` | Upstream request timeout |

### Endpoints

| Method | Path | Description |
| --- | --- | --- |
| `GET` | `/api/health` | Service status and active mode |
| `GET` | `/api/categories` | Available category chips |
| `GET` | `/api/coins?search=&category=` | Normalized market list with filters |
| `GET` | `/api/coins/:id` | Full coin detail payload |
| `GET` | `/api/coins/:id/market_chart?days=7` | Price/market-cap/volume series |
| `GET` | `/api/global` | Global market statistics |

All responses are JSON, CORS-enabled and include an `X-Data-Source: live|mock` header.

See [backend/README.md](backend/README.md) for API details.

## Flutter setup

Prerequisites: Flutter 3.47.5 / Dart 3.13.4 (or newer compatible stable) and Node.js 18+.

```bash
flutter pub get
```

Start the backend first, then run the app:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api
```

For web:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api
```

Default API bases when no override is supplied:

- Android emulator: `http://10.0.2.2:3000/api`
- Web / iOS / macOS / Windows / Linux: `http://localhost:3000/api`
- Physical device: pass your machine's LAN IP, e.g. `--dart-define=API_BASE_URL=http://192.168.1.10:3000/api`

## Verification

```bash
flutter analyze
flutter test
npm test --prefix backend
npm run smoke --prefix backend
flutter build web --release --dart-define=API_BASE_URL=http://localhost:3000/api
```

`npm run smoke` starts the real HTTP server in-process and exercises health, categories, markets, search/filter, detail, chart, global, 404 and method-not-allowed paths.

CI runs the same checks on every push via `.github/workflows/ci.yml`.

## Notes

- No API key is needed to start with the public CoinGecko endpoint; set `COINGECKO_API_KEY` only for higher upstream limits.
- Mock data is deterministic, so charts and values are stable across runs.
- The client never fakes network responses: all screens consume the same backend contract in every mode.
