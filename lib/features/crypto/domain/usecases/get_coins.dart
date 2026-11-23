import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/core/usecase/usecase.dart';
import 'package:coingecko_mini/core/utils/either.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/market_snapshot.dart';
import 'package:coingecko_mini/features/crypto/domain/repositories/crypto_repository.dart';

class GetCoins extends UseCase<Either<Failure, MarketSnapshot>, NoParams> {
  const GetCoins(this._repository);

  final CryptoRepository _repository;

  @override
  Future<Either<Failure, MarketSnapshot>> call(NoParams params) =>
      _repository.getCoins();
}
