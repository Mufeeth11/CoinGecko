import 'package:coingecko_mini/features/crypto/data/models/json_helpers.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/market_chart.dart';

class MarketChartModel extends MarketChart {
  const MarketChartModel({
    required super.coinId,
    required super.days,
    required super.source,
    required super.prices,
    required super.marketCaps,
    required super.totalVolumes,
  });

  factory MarketChartModel.fromJson(Map<String, dynamic> json) {
    return MarketChartModel(
      coinId: json.stringAt('id'),
      days: json.stringAt('days', '7'),
      source: json.stringAt('source', 'mock'),
      prices: _parsePoints(json['prices']),
      marketCaps: _parsePoints(json['marketCaps']),
      totalVolumes: _parsePoints(json['totalVolumes']),
    );
  }

  static List<MarketPoint> _parsePoints(dynamic raw) {
    if (raw is! List) return const <MarketPoint>[];
    final points = <MarketPoint>[];
    for (final entry in raw) {
      if (entry is! List || entry.length < 2) continue;
      final time = entry[0];
      final value = entry[1];
      if (time is! num || value is! num) continue;
      points.add(
        MarketPoint(
          time: DateTime.fromMillisecondsSinceEpoch(time.toInt()),
          value: value.toDouble(),
        ),
      );
    }
    return points;
  }
}
