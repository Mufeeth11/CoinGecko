import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/core/usecase/usecase.dart';
import 'package:coingecko_mini/core/utils/either.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/market_chart.dart';
import 'package:coingecko_mini/features/crypto/domain/repositories/crypto_repository.dart';
import 'package:equatable/equatable.dart';

class MarketChartParams extends Equatable {
  const MarketChartParams({required this.coinId, required this.days});

  final String coinId;
  final String days;

  @override
  List<Object?> get props => [coinId, days];
}

class GetMarketChart
    extends UseCase<Either<Failure, MarketChart>, MarketChartParams> {
  const GetMarketChart(this._repository);

  final CryptoRepository _repository;

  @override
  Future<Either<Failure, MarketChart>> call(MarketChartParams params) {
    return _repository.getMarketChart(coinId: params.coinId, days: params.days);
  }
}
