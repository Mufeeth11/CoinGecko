import 'package:coingecko_mini/features/crypto/domain/entities/coin.dart';
import 'package:equatable/equatable.dart';

class MarketSnapshot extends Equatable {
  const MarketSnapshot({
    required this.coins,
    required this.source,
    required this.updatedAt,
  });

  final List<Coin> coins;
  final String source;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [coins, source, updatedAt];
}
