import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/core/utils/either.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/coin.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/global_stats.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/market_chart.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/market_snapshot.dart';
import 'package:coingecko_mini/features/crypto/domain/repositories/crypto_repository.dart';
import 'package:coingecko_mini/features/watchlist/data/datasources/watchlist_local_data_source.dart';

Coin makeCoin({
  String id = 'bitcoin',
  String symbol = 'BTC',
  String name = 'Bitcoin',
  String category = 'Layer 1',
  double price = 100,
  double change24h = 1,
  int rank = 1,
  double marketCap = 1_000_000,
}) {
  return Coin(
    id: id,
    symbol: symbol,
    name: name,
    image: '',
    category: category,
    currentPrice: price,
    marketCap: marketCap,
    marketCapRank: rank,
    totalVolume: 100_000,
    circulatingSupply: 1000,
    totalSupply: 2000,
    maxSupply: 2000,
    priceChange24h: change24h,
    priceChange7d: change24h * 2,
    sparkline: const [10, 11, 12, 13],
  );
}

Map<String, dynamic> coinJson({
  String id = 'bitcoin',
  String symbol = 'BTC',
  String name = 'Bitcoin',
  double price = 67432.18,
}) {
  return {
    'id': id,
    'symbol': symbol,
    'name': name,
    'image': 'https://example.com/coin.png',
    'category': 'Layer 1',
    'currentPrice': price,
    'marketCap': 1_331_800_000_000,
    'marketCapRank': 1,
    'totalVolume': 34_250_000_000,
    'circulatingSupply': 19_750_000,
    'totalSupply': 21_000_000,
    'maxSupply': null,
    'priceChange24h': 2.34,
    'priceChange7d': 6.12,
    'sparkline': [1, 2, 3, 4],
  };
}

class FakeCryptoRepository implements CryptoRepository {
  FakeCryptoRepository({
    List<Coin>? coins,
    this.detail,
    this.chart,
    this.stats,
    this.failure,
  }) : coins = coins ?? [makeCoin()];

  final List<Coin> coins;
  final CoinDetail? detail;
  final MarketChart? chart;
  final GlobalStats? stats;
  final Failure? failure;

  @override
  Future<Either<Failure, MarketSnapshot>> getCoins() async {
    if (failure != null) return Left(failure!);
    return Right(
      MarketSnapshot(coins: coins, source: 'live', updatedAt: DateTime(2026)),
    );
  }

  @override
  Future<Either<Failure, CoinDetail>> getCoinDetail(String id) async {
    if (failure != null) return Left(failure!);
    if (detail == null) return const Left(NotFoundFailure('Not found'));
    return Right(detail!);
  }

  @override
  Future<Either<Failure, MarketChart>> getMarketChart({
    required String coinId,
    required String days,
  }) async {
    if (failure != null) return Left(failure!);
    if (chart == null) return const Left(NotFoundFailure('No chart'));
    return Right(chart!);
  }

  @override
  Future<Either<Failure, GlobalStats>> getGlobalStats() async {
    if (failure != null) return Left(failure!);
    if (stats == null) return const Left(NotFoundFailure('No stats'));
    return Right(stats!);
  }
}

class InMemoryWatchlistDataSource implements WatchlistLocalDataSource {
  InMemoryWatchlistDataSource([List<String>? ids])
    : _ids = List<String>.from(ids ?? const []);

  final List<String> _ids;

  @override
  Future<List<String>> readIds() async => List<String>.from(_ids);

  @override
  Future<List<String>> writeIds(List<String> ids) async {
    _ids
      ..clear()
      ..addAll(ids);
    return List<String>.from(_ids);
  }
}
