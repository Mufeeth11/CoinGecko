import 'package:equatable/equatable.dart';

class MarketPoint extends Equatable {
  const MarketPoint({required this.time, required this.value});

  final DateTime time;
  final double value;

  @override
  List<Object?> get props => [time, value];
}

class MarketChart extends Equatable {
  const MarketChart({
    required this.coinId,
    required this.days,
    required this.source,
    required this.prices,
    required this.marketCaps,
    required this.totalVolumes,
  });

  final String coinId;
  final String days;
  final String source;
  final List<MarketPoint> prices;
  final List<MarketPoint> marketCaps;
  final List<MarketPoint> totalVolumes;

  bool get isEmpty => prices.isEmpty;

  double? get firstPrice => prices.isEmpty ? null : prices.first.value;
  double? get lastPrice => prices.isEmpty ? null : prices.last.value;

  double? get periodChangePercent {
    if (prices.length < 2) return null;
    final first = prices.first.value;
    if (first == 0) return null;
    return ((prices.last.value - first) / first) * 100;
  }

  @override
  List<Object?> get props => [
    coinId,
    days,
    source,
    prices,
    marketCaps,
    totalVolumes,
  ];
}
