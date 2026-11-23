'use strict';

const http = require('node:http');

const PORT = Number(process.env.PORT || 3000);
const UPSTREAM = process.env.COINGECKO_BASE_URL || 'https://api.coingecko.com/api/v3';
const API_KEY = process.env.COINGECKO_API_KEY || '';
const CACHE_TTL = Number(process.env.CACHE_TTL_MS || 60_000);
const TIMEOUT_MS = Number(process.env.UPSTREAM_TIMEOUT_MS || 4_000);
const SOURCE = 'live';

const cache = new Map();

const CATEGORY_HINTS = {
  bitcoin: 'Layer 1',
  ethereum: 'Smart Contract',
  solana: 'Layer 1',
  cardano: 'Layer 1',
  ripple: 'Payment',
  dogecoin: 'Meme',
  'avalanche-2': 'Smart Contract',
  polkadot: 'Layer 1',
  chainlink: 'Oracle',
  'polygon-ecosystem-token': 'Layer 2',
  litecoin: 'Payment',
  uniswap: 'DeFi',
  tether: 'Stablecoin',
  'usd-coin': 'Stablecoin',
  binancecoin: 'Exchange',
};

function num(value, fallback = 0) {
  const parsed = typeof value === 'number' ? value : Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function stripHtml(value) {
  return String(value || '')
    .replace(/<[^>]*>/g, ' ')
    .replace(/&#\d+;/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function sendJson(res, status, body, source = SOURCE) {
  const payload = JSON.stringify(body);
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': Buffer.byteLength(payload),
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Cache-Control': 'no-store',
    'X-Data-Source': source,
  });
  res.end(payload);
}

async function upstreamJson(path) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), TIMEOUT_MS);
  const headers = { Accept: 'application/json' };
  if (API_KEY) headers['x-cg-demo-api-key'] = API_KEY;
  try {
    const response = await fetch(`${UPSTREAM}${path}`, { headers, signal: controller.signal });
    if (!response.ok) throw new Error(`CoinGecko responded ${response.status}`);
    return await response.json();
  } finally {
    clearTimeout(timer);
  }
}

async function resolve(key, upstream) {
  const cached = cache.get(key);
  if (cached && cached.expires > Date.now()) {
    return cached.data;
  }

  const raw = await upstream();
  const data = normalize(key, raw);
  cache.set(key, { data, expires: Date.now() + CACHE_TTL });
  return data;
}

function normalize(key, raw) {
  if (key === 'markets') {
    if (!Array.isArray(raw) || raw.length === 0) throw new Error('Empty market response');
    return raw.map((item) => ({
      id: String(item.id || ''),
      symbol: String(item.symbol || '').toUpperCase(),
      name: String(item.name || ''),
      image: String(item.image || ''),
      category: CATEGORY_HINTS[item.id] || 'Other',
      currentPrice: num(item.current_price),
      marketCap: num(item.market_cap),
      marketCapRank: num(item.market_cap_rank, 999),
      totalVolume: num(item.total_volume),
      circulatingSupply: num(item.circulating_supply),
      totalSupply: item.total_supply == null ? null : num(item.total_supply),
      maxSupply: item.max_supply == null ? null : num(item.max_supply),
      priceChange24h: num(item.price_change_percentage_24h),
      priceChange7d: num(item.price_change_percentage_7d_in_currency),
      sparkline: Array.isArray(item.sparkline_in_7d?.price) ? item.sparkline_in_7d.price : [],
    }));
  }

  if (key === 'categories') {
    const categories = (Array.isArray(raw) ? raw : [])
      .map((item) => String(item?.name || ''))
      .filter((name) => name.length > 0);
    if (categories.length === 0) throw new Error('Empty categories response');
    return categories;
  }

  if (key.startsWith('coin:')) {
    const data = raw || {};
    const market = data.market_data || {};
    if (!data.id || !market.current_price) throw new Error('Incomplete coin response');
    const value = (obj, field) => num(obj?.[field]?.usd);
    return {
      id: String(data.id),
      symbol: String(data.symbol || '').toUpperCase(),
      name: String(data.name || ''),
      image: String(data.image?.large || ''),
      category: CATEGORY_HINTS[data.id] || 'Other',
      categories: Array.isArray(data.categories) && data.categories.length
        ? data.categories
        : [CATEGORY_HINTS[data.id] || 'Cryptocurrency'],
      description: stripHtml(data.description?.en),
      currentPrice: value(market, 'current_price'),
      marketCap: value(market, 'market_cap'),
      marketCapRank: num(market.market_cap_rank),
      totalVolume: value(market, 'total_volume'),
      circulatingSupply: num(market.circulating_supply),
      totalSupply: market.total_supply == null ? null : num(market.total_supply),
      maxSupply: market.max_supply == null ? null : num(market.max_supply),
      priceChange24h: num(market.price_change_percentage_24h),
      priceChange7d: num(market.price_change_percentage_7d_in_currency),
      priceChange30d: num(market.price_change_percentage_30d_in_currency),
      priceChange1y: num(market.price_change_percentage_1y_in_currency),
      high24h: value(market, 'high_24h'),
      low24h: value(market, 'low_24h'),
      ath: value(market, 'ath'),
      atl: value(market, 'atl'),
    };
  }

  if (key.startsWith('chart:')) {
    const prices = Array.isArray(raw?.prices) ? raw.prices : [];
    return {
      prices,
      marketCaps: Array.isArray(raw.market_caps) ? raw.market_caps : [],
      totalVolumes: Array.isArray(raw.total_volumes) ? raw.total_volumes : [],
    };
  }

  if (key === 'global') {
    const data = raw?.data;
    if (!data) throw new Error('Empty global response');
    const totalMarketCap = num(data.total_market_cap?.usd);
    return {
      totalMarketCap,
      totalVolume: num(data.total_volume?.usd),
      marketCapChange24h: num(data.market_cap_change_percentage_24h_usd),
      btcDominance: num(data.market_cap_percentage?.btc),
      ethDominance: num(data.market_cap_percentage?.eth),
      activeCryptocurrencies: num(data.active_cryptocurrencies),
      markets: num(data.markets),
      updatedAt: data.updated_at ? new Date(data.updated_at * 1000).toISOString() : new Date().toISOString(),
    };
  }

  throw new Error(`Unknown cache key ${key}`);
}

async function handle(req, res) {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const path = url.pathname.replace(/\/+$/, '') || '/';

  if (req.method === 'OPTIONS') {
    sendJson(res, 204, {});
    return;
  }
  if (req.method !== 'GET') {
    sendJson(res, 405, { error: 'Method not allowed' });
    return;
  }

  if (path === '/api/health') {
    sendJson(res, 200, { status: 'ok', mode: SOURCE, timestamp: new Date().toISOString() });
    return;
  }

  if (path === '/api/categories') {
    const categories = await resolve('categories', () => upstreamJson('/coins/categories'));
    sendJson(res, 200, { categories }, SOURCE);
    return;
  }

  if (path === '/api/coins') {
    const coins = await resolve(
      'markets',
      () => upstreamJson('/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=true&price_change_percentage=24h,7d'),
    );
    let visible = coins;
    const query = (url.searchParams.get('search') || '').trim().toLowerCase();
    const category = (url.searchParams.get('category') || '').trim().toLowerCase();
    if (query) {
      visible = visible.filter((coin) => coin.name.toLowerCase().includes(query) || coin.symbol.toLowerCase().includes(query));
    }
    if (category && category !== 'all') {
      visible = visible.filter((coin) => coin.category.toLowerCase() === category);
    }
    sendJson(res, 200, { coins: visible, source: SOURCE, updatedAt: new Date().toISOString() }, SOURCE);
    return;
  }

  if (path === '/api/global') {
    const stats = await resolve('global', () => upstreamJson('/global'));
    sendJson(res, 200, { ...stats, source: SOURCE }, SOURCE);
    return;
  }

  const chartMatch = path.match(/^\/api\/coins\/([^/]+)\/market_chart$/);
  if (chartMatch) {
    const id = decodeURIComponent(chartMatch[1]);
    const days = url.searchParams.get('days') || '7';
    const key = `chart:${id}:${days}`;
    const chart = await resolve(
      key,
      () => upstreamJson(`/coins/${encodeURIComponent(id)}/market_chart?vs_currency=usd&days=${encodeURIComponent(days)}`),
    );
    if (chart.prices.length === 0) {
      sendJson(res, 404, { error: `No chart data for ${id}` }, SOURCE);
      return;
    }
    sendJson(res, 200, { ...chart, id, days, source: SOURCE }, SOURCE);
    return;
  }

  const coinMatch = path.match(/^\/api\/coins\/([^/]+)$/);
  if (coinMatch) {
    const id = decodeURIComponent(coinMatch[1]);
    const key = `coin:${id}`;
    const coin = await resolve(
      key,
      () => upstreamJson(`/coins/${encodeURIComponent(id)}?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=false`),
    );
    if (!coin || !coin.id) {
      sendJson(res, 404, { error: `Coin ${id} not found` }, SOURCE);
      return;
    }
    sendJson(res, 200, { ...coin, source: SOURCE }, SOURCE);
    return;
  }

  sendJson(res, 404, { error: 'Not found' });
}

function createAppServer() {
  return http.createServer((req, res) => {
    handle(req, res).catch((error) => {
      console.error('[backend] request failed:', error);
      if (!res.headersSent) sendJson(res, 502, { error: error.message || 'Upstream unavailable' });
      else res.end();
    });
  });
}

if (require.main === module) {
  createAppServer().listen(PORT, () => {
    console.log(`[backend] CoinGecko mini API listening on http://localhost:${PORT}/api (source: ${SOURCE})`);
  });
}

module.exports = { createAppServer, normalize, stripHtml };
