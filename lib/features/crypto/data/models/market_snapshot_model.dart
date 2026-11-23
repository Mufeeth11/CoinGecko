import 'package:coingecko_mini/features/crypto/data/models/coin_model.dart';
import 'package:coingecko_mini/features/crypto/data/models/json_helpers.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/market_snapshot.dart';

class MarketSnapshotModel extends MarketSnapshot {
  const MarketSnapshotModel({
    required super.coins,
    required super.source,
    required super.updatedAt,
  });

  factory MarketSnapshotModel.fromJson(Map<String, dynamic> json) {
    final rawCoins = json['coins'];
    final coins = rawCoins is List
        ? rawCoins
              .whereType<Map>()
              .map(
                (item) => CoinModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <CoinModel>[];

    return MarketSnapshotModel(
      coins: coins,
      source: json.stringAt('source', 'mock'),
      updatedAt:
          DateTime.tryParse(json.stringAt('updatedAt')) ?? DateTime.now(),
    );
  }
}
