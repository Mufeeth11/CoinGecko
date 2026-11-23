import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/core/utils/either.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/coin.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/global_stats.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/market_chart.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/market_snapshot.dart';

abstract interface class CryptoRepository {
  Future<Either<Failure, MarketSnapshot>> getCoins();

  Future<Either<Failure, CoinDetail>> getCoinDetail(String id);

  Future<Either<Failure, MarketChart>> getMarketChart({
    required String coinId,
    required String days,
  });

  Future<Either<Failure, GlobalStats>> getGlobalStats();
}
