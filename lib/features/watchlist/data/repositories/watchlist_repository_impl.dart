import 'package:coingecko_mini/core/error/exception.dart';
import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/core/utils/either.dart';
import 'package:coingecko_mini/features/watchlist/data/datasources/watchlist_local_data_source.dart';
import 'package:coingecko_mini/features/watchlist/domain/repositories/watchlist_repository.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  const WatchlistRepositoryImpl(this._localDataSource);

  final WatchlistLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<String>>> getWatchlist() =>
      _guard(_localDataSource.readIds);

  @override
  Future<Either<Failure, List<String>>> toggle(String coinId) async {
    return _guard(() async {
      final current = await _localDataSource.readIds();
      final next = List<String>.from(current);
      if (next.contains(coinId)) {
        next.remove(coinId);
      } else {
        next.add(coinId);
      }
      return _localDataSource.writeIds(next);
    });
  }

  Future<Either<Failure, List<String>>> _guard(
    Future<List<String>> Function() action,
  ) async {
    try {
      return Right(await action());
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    }
  }
}
