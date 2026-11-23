import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/core/usecase/usecase.dart';
import 'package:coingecko_mini/core/utils/either.dart';
import 'package:coingecko_mini/features/watchlist/domain/repositories/watchlist_repository.dart';

class ToggleWatchlist extends UseCase<Either<Failure, List<String>>, String> {
  const ToggleWatchlist(this._repository);

  final WatchlistRepository _repository;

  @override
  Future<Either<Failure, List<String>>> call(String coinId) =>
      _repository.toggle(coinId);
}
