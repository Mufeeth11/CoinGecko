import 'package:coingecko_mini/features/crypto/data/models/json_helpers.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/global_stats.dart';

class GlobalStatsModel extends GlobalStats {
  const GlobalStatsModel({
    required super.totalMarketCap,
    required super.totalVolume,
    required super.marketCapChange24h,
    required super.btcDominance,
    required super.ethDominance,
    required super.activeCryptocurrencies,
    required super.markets,
    required super.updatedAt,
    required super.source,
  });

  factory GlobalStatsModel.fromJson(Map<String, dynamic> json) {
    return GlobalStatsModel(
      totalMarketCap: json.doubleAt('totalMarketCap'),
      totalVolume: json.doubleAt('totalVolume'),
      marketCapChange24h: json.doubleAt('marketCapChange24h'),
      btcDominance: json.doubleAt('btcDominance'),
      ethDominance: json.doubleAt('ethDominance'),
      activeCryptocurrencies: json.intAt('activeCryptocurrencies'),
      markets: json.intAt('markets'),
      updatedAt:
          DateTime.tryParse(json.stringAt('updatedAt')) ?? DateTime.now(),
      source: json.stringAt('source'),
    );
  }
}
