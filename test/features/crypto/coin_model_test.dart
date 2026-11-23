import 'package:coingecko_mini/features/crypto/data/models/coin_model.dart';
import 'package:coingecko_mini/features/crypto/data/models/market_chart_model.dart';
import 'package:coingecko_mini/features/crypto/data/models/market_snapshot_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coingecko_mini/features/crypto/data/models/global_stats_model.dart';

import '../../helpers/fakes.dart';

void main() {
  group('API models', () {
    test('CoinModel parses normalized market JSON', () {
      final model = CoinModel.fromJson(coinJson());

      expect(model.id, 'bitcoin');
      expect(model.symbol, 'BTC');
      expect(model.currentPrice, 67432.18);
      expect(model.marketCapRank, 1);
      expect(model.maxSupply, isNull);
      expect(model.sparkline, [1, 2, 3, 4]);
    });

    test('MarketSnapshotModel keeps source metadata for UI badges', () {
      final snapshot = MarketSnapshotModel.fromJson({
        'coins': [coinJson()],
        'source': 'live',
        'updatedAt': '2026-11-23T10:00:00.000Z',
      });

      expect(snapshot.coins, hasLength(1));
      expect(snapshot.source, 'live');
      expect(snapshot.updatedAt.year, 2026);
    });

    test('MarketChartModel converts timestamp pairs into domain points', () {
      final chart = MarketChartModel.fromJson({
        'id': 'bitcoin',
        'days': '7',
        'source': 'live',
        'prices': [
          [1700000000000, 100.5],
          [1700003600000, 102.25],
        ],
        'marketCaps': [],
        'totalVolumes': [],
      });

      expect(chart.prices, hasLength(2));
      expect(chart.prices.last.value, 102.25);
      expect(chart.periodChangePercent, closeTo(1.74, 0.01));
    });

    test('GlobalStatsModel computes other dominance', () {
      final stats = GlobalStatsModel.fromJson({
        'totalMarketCap': 1000,
        'totalVolume': 50,
        'marketCapChange24h': 1.8,
        'btcDominance': 55,
        'ethDominance': 18,
        'activeCryptocurrencies': 14000,
        'markets': 900,
        'updatedAt': '2026-11-23T10:00:00.000Z',
        'source': 'live',
      });

      expect(stats.otherDominance, 27);
      expect(stats.activeCryptocurrencies, 14000);
    });
  });
}
