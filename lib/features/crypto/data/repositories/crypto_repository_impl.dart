import 'package:coingecko_mini/core/error/exception.dart';
import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/core/utils/either.dart';
import 'package:coingecko_mini/features/crypto/data/datasources/crypto_remote_data_source.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/coin.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/global_stats.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/market_chart.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/market_snapshot.dart';
import 'package:coingecko_mini/features/crypto/domain/repositories/crypto_repository.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  const CryptoRepositoryImpl(this._remoteDataSource);

  final CryptoRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, MarketSnapshot>> getCoins() =>
      _execute(() => _remoteDataSource.getCoins());

  @override
  Future<Either<Failure, CoinDetail>> getCoinDetail(String id) =>
      _execute(() => _remoteDataSource.getCoinDetail(id));

  @override
  Future<Either<Failure, MarketChart>> getMarketChart({
    required String coinId,
    required String days,
  }) => _execute(
    () => _remoteDataSource.getMarketChart(coinId: coinId, days: days),
  );

  @override
  Future<Either<Failure, GlobalStats>> getGlobalStats() =>
      _execute(() => _remoteDataSource.getGlobalStats());

  Future<Either<Failure, T>> _execute<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on ServerException catch (error) {
      if (error.statusCode == 404) {
        return Left(NotFoundFailure(error.message));
      }
      return Left(ServerFailure(error.message));
    } on ConnectionException catch (error) {
      return Left(ConnectionFailure(error.message));
    } on ParsingException catch (error) {
      return Left(ParsingFailure(error.message));
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    } on FormatException {
      return const Left(
        ParsingFailure('Unexpected data format from the market server.'),
      );
    }
  }
}
