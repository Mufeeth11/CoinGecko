'use strict';

const http = require('node:http');

const SEEDS = [
  ['bitcoin', 'btc', 'Bitcoin', 'Layer 1'],
  ['ethereum', 'eth', 'Ethereum', 'Smart Contract'],
  ['tether', 'usdt', 'Tether', 'Stablecoin'],
  ['binancecoin', 'bnb', 'BNB', 'Exchange'],
  ['solana', 'sol', 'Solana', 'Layer 1'],
  ['usd-coin', 'usdc', 'USD Coin', 'Stablecoin'],
  ['ripple', 'xrp', 'XRP', 'Payment'],
  ['cardano', 'ada', 'Cardano', 'Layer 1'],
  ['dogecoin', 'doge', 'Dogecoin', 'Meme'],
  ['avalanche-2', 'avax', 'Avalanche', 'Smart Contract'],
  ['polkadot', 'dot', 'Polkadot', 'Layer 1'],
  ['chainlink', 'link', 'Chainlink', 'Oracle'],
  ['litecoin', 'ltc', 'Litecoin', 'Payment'],
  ['polygon-ecosystem-token', 'matic', 'Polygon', 'Layer 2'],
  ['uniswap', 'uni', 'Uniswap', 'DeFi'],
];

function round(value, digits = 2) {
  const factor = 10 ** digits;
  return Math.round(value * factor) / factor;
}

const coins = SEEDS.map(([id, symbol, name], index) => {
  const basePrice = round(1200 / (index + 1) + 5, 2);
  return {
    id,
    symbol,
    name,
    image: `https://example.com/${id}.png`,
    current_price: basePrice,
    market_cap: Math.round(1_200_000_000 / (index + 1)),
    market_cap_rank: index + 1,
    total_volume: Math.round(48_000_000 / (index + 1)),
    circulating_supply: 18_000_000 - index * 120_000,
    total_supply: 21_000_000 - index * 120_000,
    max_supply: index % 3 === 0 ? null : 21_000_000,
    price_change_percentage_24h: round(index % 2 === 0 ? 2.5 : -1.75, 2),
    price_change_percentage_7d_in_currency: round(index % 2 === 0 ? 6.2 : -4.1, 2),
    sparkline_in_7d: {
      price: Array.from({ length: 30 }, (_, point) => round(basePrice + Math.sin(point / 4) * 3, 4)),
    },
  };
});

const globalPayload = {
  data: {
    total_market_cap: { usd: 2_400_000_000_000 },
    total_volume: { usd: 130_000_000_000 },
    market_cap_change_percentage_24h_usd: 1.84,
    market_cap_percentage: { btc: 52.4, eth: 17.8 },
    active_cryptocurrencies: 24_000,
    markets: 985,
    updated_at: Math.floor(Date.UTC(2026, 10, 23, 14, 30) / 1000),
  },
};

const categoriesPayload = Array.from(new Set(SEEDS.map((seed) => seed[3]))).map((name) => ({
  category_id: name.toLowerCase().replace(/\s+/g, '-'),
  name,
}));

function coinById(id) {
  return coins.find((coin) => coin.id === id);
}

function detailFor(id) {
  const coin = coinById(id);
  const seed = SEEDS.find((item) => item[0] === id);
  if (!coin || !seed) return null;
  return {
    id,
    symbol: seed[1],
    name: seed[2],
    image: { large: coin.image },
    categories: [seed[3], 'Cryptocurrency'],
    description: { en: `<p>${seed[2]} is a digital asset used by the market terminal.</p>` },
    market_data: {
      current_price: { usd: coin.current_price },
      market_cap: { usd: coin.market_cap },
      market_cap_rank: coin.market_cap_rank,
      total_volume: { usd: coin.total_volume },
      circulating_supply: coin.circulating_supply,
      total_supply: coin.total_supply,
      max_supply: coin.max_supply,
      price_change_percentage_24h: coin.price_change_percentage_24h,
      price_change_percentage_7d_in_currency: coin.price_change_percentage_7d_in_currency,
      price_change_percentage_30d_in_currency: 12.5,
      price_change_percentage_1y_in_currency: 80.5,
      high_24h: { usd: round(coin.current_price * 1.05, 2) },
      low_24h: { usd: round(coin.current_price * 0.95, 2) },
      ath: { usd: round(coin.current_price * 2, 2) },
      atl: { usd: round(coin.current_price * 0.1, 4) },
    },
  };
}

function chartFor(id, days) {
  const coin = coinById(id);
  if (!coin) return { prices: [], market_caps: [], total_volumes: [] };
  const count = days === '1' ? 24 : Math.min(Number(days) || 7, 365) * 2;
  const start = Date.UTC(2026, 10, 23) - count * 3_600_000;
  const prices = [];
  const marketCaps = [];
  const totalVolumes = [];
  for (let index = 0; index < count; index += 1) {
    const value = round(coin.current_price * (0.9 + index / (count * 5)), 4);
    prices.push([start + index * 3_600_000, value]);
    marketCaps.push([start + index * 3_600_000, Math.round(value * coin.circulating_supply)]);
    totalVolumes.push([start + index * 3_600_000, Math.round(coin.total_volume * (0.7 + index / count))]);
  }
  return { prices, market_caps: marketCaps, total_volumes: totalVolumes };
}

function send(res, status, body) {
  const payload = JSON.stringify(body);
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': Buffer.byteLength(payload),
  });
  res.end(payload);
}

function createUpstreamServer() {
  return http.createServer((req, res) => {
    const url = new URL(req.url, 'http://localhost');
    const path = url.pathname;

    if (path === '/coins/markets') {
      send(res, 200, coins);
      return;
    }
    if (path === '/global') {
      send(res, 200, globalPayload);
      return;
    }
    if (path === '/coins/categories') {
      send(res, 200, categoriesPayload);
      return;
    }

    const chartMatch = path.match(/^\/coins\/([^/]+)\/market_chart$/);
    if (chartMatch) {
      const id = decodeURIComponent(chartMatch[1]);
      send(res, 200, chartFor(id, url.searchParams.get('days') || '7'));
      return;
    }

    const coinMatch = path.match(/^\/coins\/([^/]+)$/);
    if (coinMatch) {
      const id = decodeURIComponent(coinMatch[1]);
      const detail = detailFor(id);
      if (!detail) {
        send(res, 404, { error: 'Coin not found' });
        return;
      }
      send(res, 200, detail);
      return;
    }

    send(res, 404, { error: 'Not found' });
  });
}

module.exports = { createUpstreamServer };
