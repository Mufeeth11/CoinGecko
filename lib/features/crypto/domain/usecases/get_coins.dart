import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/core/usecase/usecase.dart';
import 'package:coingecko_mini/core/utils/either.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/coin.dart';
import 'package:coingecko_mini/features/crypto/domain/repositories/crypto_repository.dart';

class GetCoins extends UseCase<Either<Failure, List<Coin>>, NoParams> {
  const GetCoins(this._repository);

  final CryptoRepository _repository;

  @override
  Future<Either<Failure, List<Coin>>> call(NoParams params) =>
      _repository.getCoins();
}
