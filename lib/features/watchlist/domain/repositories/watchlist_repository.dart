import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/core/utils/either.dart';

abstract interface class WatchlistRepository {
  Future<Either<Failure, List<String>>> getWatchlist();

  Future<Either<Failure, List<String>>> toggle(String coinId);
}
