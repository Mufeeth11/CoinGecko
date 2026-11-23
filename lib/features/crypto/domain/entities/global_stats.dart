import 'package:equatable/equatable.dart';

class GlobalStats extends Equatable {
  const GlobalStats({
    required this.totalMarketCap,
    required this.totalVolume,
    required this.marketCapChange24h,
    required this.btcDominance,
    required this.ethDominance,
    required this.activeCryptocurrencies,
    required this.markets,
    required this.updatedAt,
    required this.source,
  });

  final double totalMarketCap;
  final double totalVolume;
  final double marketCapChange24h;
  final double btcDominance;
  final double ethDominance;
  final int activeCryptocurrencies;
  final int markets;
  final DateTime updatedAt;
  final String source;

  double get otherDominance {
    final value = 100 - btcDominance - ethDominance;
    return value < 0 ? 0 : value;
  }

  @override
  List<Object?> get props => [
    totalMarketCap,
    totalVolume,
    marketCapChange24h,
    btcDominance,
    ethDominance,
    activeCryptocurrencies,
    markets,
    updatedAt,
    source,
  ];
}
