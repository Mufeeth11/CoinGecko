import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/core/usecase/usecase.dart';
import 'package:coingecko_mini/core/utils/either.dart';
import 'package:coingecko_mini/features/watchlist/domain/repositories/watchlist_repository.dart';

class GetWatchlist extends UseCase<Either<Failure, List<String>>, NoParams> {
  const GetWatchlist(this._repository);

  final WatchlistRepository _repository;

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) =>
      _repository.getWatchlist();
}
