'use strict';

/**
 * Deterministic sample data used whenever the public CoinGecko API cannot be
 * reached (offline demo, rate limit, CI). It keeps the Flutter app fully
 * usable end-to-end without faking anything inside the client itself.
 */

const DAY_MS = 24 * 60 * 60 * 1000;

const SEED_COINS = [
  {
    id: 'bitcoin',
    symbol: 'btc',
    name: 'Bitcoin',
    category: 'Layer 1',
    image: 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png',
    price: 67432.18,
    rank: 1,
    marketCap: 1_331_800_000_000,
    volume: 34_250_000_000,
    circulating: 19_750_000,
    total: 21_000_000,
    max: 21_000_000,
    change24h: 2.34,
    change7d: 6.12,
    description:
      'Bitcoin is the first decentralized digital currency. It uses proof-of-work to let peers send value directly without a central authority.',
  },
  {
    id: 'ethereum',
    symbol: 'eth',
    name: 'Ethereum',
    category: 'Smart Contract',
    image: 'https://assets.coingecko.com/coins/images/279/large/ethereum.png',
    price: 3512.74,
    rank: 2,
    marketCap: 422_600_000_000,
    volume: 18_940_000_000,
    circulating: 120_310_000,
    total: 120_310_000,
    max: null,
    change24h: 1.82,
    change7d: 4.37,
    description:
      'Ethereum is a programmable blockchain that runs smart contracts and powers a large ecosystem of decentralized applications.',
  },
  {
    id: 'tether',
    symbol: 'usdt',
    name: 'Tether',
    category: 'Stablecoin',
    image: 'https://assets.coingecko.com/coins/images/325/large/Tether.png',
    price: 1.0,
    rank: 3,
    marketCap: 112_400_000_000,
    volume: 51_700_000_000,
    circulating: 112_400_000_000,
    total: 112_400_000_000,
    max: null,
    change24h: 0.01,
    change7d: -0.02,
    description:
      'Tether is a stablecoin designed to track the US dollar, providing a liquid settlement asset for crypto markets.',
  },
  {
    id: 'binancecoin',
    symbol: 'bnb',
    name: 'BNB',
    category: 'Exchange',
    image: 'https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png',
    price: 596.41,
    rank: 4,
    marketCap: 87_900_000_000,
    volume: 2_180_000_000,
    circulating: 147_380_000,
    total: 147_380_000,
    max: 200_000_000,
    change24h: -0.74,
    change7d: 2.15,
    description:
      'BNB is the native asset of the BNB Chain ecosystem and is used for transaction fees, staking and platform utilities.',
  },
  {
    id: 'solana',
    symbol: 'sol',
    name: 'Solana',
    category: 'Layer 1',
    image: 'https://assets.coingecko.com/coins/images/4128/large/solana.png',
    price: 172.86,
    rank: 5,
    marketCap: 79_600_000_000,
    volume: 4_320_000_000,
    circulating: 460_380_000,
    total: 539_000_000,
    max: null,
    change24h: 4.91,
    change7d: 11.28,
    description:
      'Solana is a high-throughput blockchain built for fast, low-cost transactions and consumer-scale applications.',
  },
  {
    id: 'ripple',
    symbol: 'xrp',
    name: 'XRP',
    category: 'Payment',
    image: 'https://assets.coingecko.com/coins/images/44/large/xrp-symbol-white-128.png',
    price: 0.6128,
    rank: 6,
    marketCap: 34_100_000_000,
    volume: 1_760_000_000,
    circulating: 55_640_000_000,
    total: 99_987_000_000,
    max: 100_000_000_000,
    change24h: -1.36,
    change7d: -3.04,
    description:
      'XRP is a digital asset designed for fast cross-border payments and settlement between financial institutions.',
  },
  {
    id: 'usd-coin',
    symbol: 'usdc',
    name: 'USDC',
    category: 'Stablecoin',
    image: 'https://assets.coingecko.com/coins/images/6319/large/usdc.png',
    price: 0.9999,
    rank: 7,
    marketCap: 32_800_000_000,
    volume: 8_940_000_000,
    circulating: 32_810_000_000,
    total: 32_810_000_000,
    max: null,
    change24h: 0.0,
    change7d: 0.01,
    description:
      'USD Coin is a regulated dollar-backed stablecoin issued by Circle and used across many blockchain networks.',
  },
  {
    id: 'cardano',
    symbol: 'ada',
    name: 'Cardano',
    category: 'Layer 1',
    image: 'https://assets.coingecko.com/coins/images/975/large/cardano.png',
    price: 0.4521,
    rank: 8,
    marketCap: 16_200_000_000,
    volume: 512_000_000,
    circulating: 35_840_000_000,
    total: 45_000_000_000,
    max: 45_000_000_000,
    change24h: 1.12,
    change7d: -0.86,
    description:
      'Cardano is a proof-of-stake blockchain platform developed with a research-first approach to smart contracts.',
  },
  {
    id: 'dogecoin',
    symbol: 'doge',
    name: 'Dogecoin',
    category: 'Meme',
    image: 'https://assets.coingecko.com/coins/images/5/large/dogecoin.png',
    price: 0.1483,
    rank: 9,
    marketCap: 21_600_000_000,
    volume: 1_340_000_000,
    circulating: 145_760_000_000,
    total: 145_760_000_000,
    max: null,
    change24h: 6.78,
    change7d: 14.53,
    description:
      'Dogecoin started as a joke but grew into a widely used peer-to-peer currency with a large community.',
  },
  {
    id: 'avalanche-2',
    symbol: 'avax',
    name: 'Avalanche',
    category: 'Smart Contract',
    image: 'https://assets.coingecko.com/coins/images/12559/large/Avalanche_Circle_RedWhite_Trans.png',
    price: 36.28,
    rank: 10,
    marketCap: 14_300_000_000,
    volume: 428_000_000,
    circulating: 394_200_000,
    total: 720_000_000,
    max: 720_000_000,
    change24h: 3.07,
    change7d: 8.41,
    description:
      'Avalanche is a scalable platform for decentralized applications with near-instant transaction finality.',
  },
  {
    id: 'chainlink',
    symbol: 'link',
    name: 'Chainlink',
    category: 'Oracle',
    image: 'https://assets.coingecko.com/coins/images/877/large/chainlink-new-logo.png',
    price: 17.42,
    rank: 11,
    marketCap: 10_900_000_000,
    volume: 486_000_000,
    circulating: 626_800_000,
    total: 1_000_000_000,
    max: 1_000_000_000,
    change24h: -2.18,
    change7d: 1.64,
    description:
      'Chainlink provides decentralized oracle networks that connect smart contracts with real-world data.',
  },
  {
    id: 'polkadot',
    symbol: 'dot',
    name: 'Polkadot',
    category: 'Layer 1',
    image: 'https://assets.coingecko.com/coins/images/12171/large/polkadot.png',
    price: 7.31,
    rank: 12,
    marketCap: 10_600_000_000,
    volume: 312_000_000,
    circulating: 1_450_000_000,
    total: 1_450_000_000,
    max: null,
    change24h: 0.63,
    change7d: -1.92,
    description:
      'Polkadot enables interoperability between independent blockchains through its relay chain and parachains.',
  },
  {
    id: 'polygon-ecosystem-token',
    symbol: 'pol',
    name: 'Polygon',
    category: 'Layer 2',
    image: 'https://assets.coingecko.com/coins/images/4713/large/polygon.png',
    price: 0.5812,
    rank: 13,
    marketCap: 5_800_000_000,
    volume: 264_000_000,
    circulating: 9_980_000_000,
    total: 10_000_000_000,
    max: 10_000_000_000,
    change24h: 2.86,
    change7d: 5.72,
    description:
      'Polygon builds Ethereum-compatible scaling solutions for faster and cheaper transactions.',
  },
  {
    id: 'litecoin',
    symbol: 'ltc',
    name: 'Litecoin',
    category: 'Payment',
    image: 'https://assets.coingecko.com/coins/images/2/large/litecoin.png',
    price: 82.14,
    rank: 14,
    marketCap: 6_100_000_000,
    volume: 398_000_000,
    circulating: 74_260_000,
    total: 84_000_000,
    max: 84_000_000,
    change24h: -0.42,
    change7d: 2.38,
    description:
      'Litecoin is a peer-to-peer cryptocurrency created as a lighter, faster alternative to Bitcoin.',
  },
  {
    id: 'uniswap',
    symbol: 'uni',
    name: 'Uniswap',
    category: 'DeFi',
    image: 'https://assets.coingecko.com/coins/images/12504/large/uniswap-uni.png',
    price: 9.86,
    rank: 15,
    marketCap: 5_900_000_000,
    volume: 221_000_000,
    circulating: 599_100_000,
    total: 1_000_000_000,
    max: 1_000_000_000,
    change24h: 5.24,
    change7d: 9.61,
    description:
      'Uniswap is a decentralized exchange protocol that lets users swap tokens through automated liquidity pools.',
  },
];

function hashString(value) {
  let hash = 0;
  for (let i = 0; i < value.length; i += 1) {
    hash = (hash << 5) - hash + value.charCodeAt(i);
    hash |= 0;
  }
  return Math.abs(hash);
}

function round(value, digits = 2) {
  if (!Number.isFinite(value)) return 0;
  const factor = 10 ** digits;
  return Math.round(value * factor) / factor;
}

function pointCountForDays(days) {
  const table = { 1: 24, 7: 84, 14: 84, 30: 90, 90: 90, 180: 120, 365: 120, max: 140 };
  return table[String(days)] || 84;
}

function buildSeries(coin, days, kind) {
  const count = pointCountForDays(days);
  const spanMs = days === 'max' ? 365 * DAY_MS : Number(days) * DAY_MS;
  const start = Date.now() - spanMs;
  const step = spanMs / (count - 1);
  const seed = hashString(`${coin.id}:${days}:${kind}`);
  const amplitude = coin.symbol === 'usdt' || coin.symbol === 'usdc' ? 0.0004 : 0.028;
  const cycles = 1 + (seed % 3);
  const drift = kind === 'marketCap' ? coin.change24h / 300 : coin.change24h / 100;

  const prices = [];
  const marketCaps = [];
  const totalVolumes = [];

  for (let i = 0; i < count; i += 1) {
    const t = start + i * step;
    const progress = i / (count - 1);
    const wave = Math.sin(progress * Math.PI * 2 * cycles + (seed % 17)) * amplitude;
    const noise = Math.sin(i * 1.73 + seed) * amplitude * 0.35;
    const trend = (progress - 0.5) * drift;
    const factor = 1 + wave + noise + trend;
    const price = i === count - 1 ? coin.price : Math.max(coin.price * factor, coin.price * 0.5);
    prices.push([Math.round(t), round(price, coin.price < 1 ? 6 : 2)]);
    marketCaps.push([Math.round(t), round(price * coin.circulating, 0)]);
    totalVolumes.push([Math.round(t), round(coin.volume * (0.72 + Math.abs(wave) * 9), 0)]);
  }

  return { prices, marketCaps, totalVolumes };
}

function toMarketCoin(coin) {
  const series = buildSeries(coin, 7, 'price');
  return {
    id: coin.id,
    symbol: coin.symbol,
    name: coin.name,
    image: coin.image,
    category: coin.category,
    currentPrice: coin.price,
    marketCap: coin.marketCap,
    marketCapRank: coin.rank,
    totalVolume: coin.volume,
    circulatingSupply: coin.circulating,
    totalSupply: coin.total,
    maxSupply: coin.max,
    priceChange24h: coin.change24h,
    priceChange7d: coin.change7d,
    sparkline: series.prices.map((point) => point[1]),
  };
}

function getMockMarkets() {
  return SEED_COINS.map(toMarketCoin).sort((a, b) => a.marketCapRank - b.marketCapRank);
}

function getMockCoin(id) {
  const coin = SEED_COINS.find((item) => item.id === id);
  if (!coin) return null;
  const market = toMarketCoin(coin);
  return {
    ...market,
    description: coin.description,
    categories: [coin.category, 'Cryptocurrency'],
    high24h: round(coin.price * (1 + Math.abs(coin.change24h) / 100 + 0.006), 4),
    low24h: round(coin.price * (1 - Math.abs(coin.change24h) / 100 - 0.004), 4),
    ath: round(coin.price * 1.72, 4),
    atl: round(coin.price * 0.11, 4),
    priceChange30d: round(coin.change7d * 1.9 - 1.2, 2),
    priceChange1y: round(coin.change7d * 5.6 + 18.4, 2),
  };
}

function getMockChart(id, days) {
  const coin = SEED_COINS.find((item) => item.id === id);
  if (!coin) return null;
  const normalizedDays = String(days || 7);
  return buildSeries(coin, normalizedDays, 'price');
}

function getMockGlobal() {
  const coins = getMockMarkets();
  const totalMarketCap = coins.reduce((sum, coin) => sum + coin.marketCap, 0);
  const totalVolume = coins.reduce((sum, coin) => sum + coin.totalVolume, 0);
  const btc = coins.find((coin) => coin.id === 'bitcoin');
  const eth = coins.find((coin) => coin.id === 'ethereum');
  return {
    totalMarketCap,
    totalVolume,
    marketCapChange24h: 1.84,
    btcDominance: round((btc.marketCap / totalMarketCap) * 100, 2),
    ethDominance: round((eth.marketCap / totalMarketCap) * 100, 2),
    activeCryptocurrencies: 14_287,
    markets: 982,
    updatedAt: new Date().toISOString(),
  };
}

function getMockCategories() {
  return [...new Set(SEED_COINS.map((coin) => coin.category))].sort();
}

module.exports = {
  SEED_COINS,
  getMockMarkets,
  getMockCoin,
  getMockChart,
  getMockGlobal,
  getMockCategories,
  round,
};
