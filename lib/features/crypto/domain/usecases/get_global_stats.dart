import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/core/usecase/usecase.dart';
import 'package:coingecko_mini/core/utils/either.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/global_stats.dart';
import 'package:coingecko_mini/features/crypto/domain/repositories/crypto_repository.dart';

class GetGlobalStats extends UseCase<Either<Failure, GlobalStats>, NoParams> {
  const GetGlobalStats(this._repository);

  final CryptoRepository _repository;

  @override
  Future<Either<Failure, GlobalStats>> call(NoParams params) =>
      _repository.getGlobalStats();
}
