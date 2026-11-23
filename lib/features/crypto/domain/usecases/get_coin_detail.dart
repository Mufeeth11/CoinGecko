import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/core/usecase/usecase.dart';
import 'package:coingecko_mini/core/utils/either.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/coin.dart';
import 'package:coingecko_mini/features/crypto/domain/repositories/crypto_repository.dart';

class GetCoinDetail extends UseCase<Either<Failure, CoinDetail>, String> {
  const GetCoinDetail(this._repository);

  final CryptoRepository _repository;

  @override
  Future<Either<Failure, CoinDetail>> call(String coinId) =>
      _repository.getCoinDetail(coinId);
}
