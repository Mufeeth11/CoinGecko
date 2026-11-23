import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/core/state/view_status.dart';
import 'package:coingecko_mini/core/utils/either.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/market_chart.dart';
import 'package:coingecko_mini/features/crypto/domain/usecases/get_coin_detail.dart';
import 'package:coingecko_mini/features/crypto/domain/usecases/get_market_chart.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/coin_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoinDetailCubit extends Cubit<CoinDetailState> {
  CoinDetailCubit({required this.getCoinDetail, required this.getMarketChart})
    : super(const CoinDetailState());

  final GetCoinDetail getCoinDetail;
  final GetMarketChart getMarketChart;

  String? _coinId;

  Future<void> load(String coinId, {bool refresh = false}) async {
    _coinId = coinId;
    final isFirstLoad = state.detail == null;
    emit(
      state.copyWith(
        status: isFirstLoad ? ViewStatus.loading : state.status,
        chartStatus: isFirstLoad ? ViewStatus.loading : state.chartStatus,
        isRefreshing: refresh && !isFirstLoad,
        clearMessage: true,
        clearChartMessage: true,
      ),
    );

    final detailFuture = getCoinDetail(coinId);
    final chartFuture = getMarketChart(
      MarketChartParams(coinId: coinId, days: state.days),
    );

    final detailResult = await detailFuture;
    detailResult.fold(
      onLeft: (Failure failure) => emit(
        state.copyWith(
          status: ViewStatus.failure,
          message: failure.message,
          isRefreshing: false,
        ),
      ),
      onRight: (detail) =>
          emit(state.copyWith(status: ViewStatus.success, detail: detail)),
    );

    final chartResult = await chartFuture;
    _applyChartResult(chartResult);
  }

  Future<void> changeDays(String days) async {
    if (_coinId == null) return;
    emit(
      state.copyWith(
        days: days,
        chartStatus: ViewStatus.loading,
        clearChartMessage: true,
      ),
    );
    final result = await getMarketChart(
      MarketChartParams(coinId: _coinId!, days: days),
    );
    _applyChartResult(result);
  }

  void _applyChartResult(Either<Failure, MarketChart> result) {
    result.fold(
      onLeft: (Failure failure) => emit(
        state.copyWith(
          chartStatus: ViewStatus.failure,
          chartMessage: failure.message,
          isRefreshing: false,
        ),
      ),
      onRight: (chart) => emit(
        state.copyWith(
          chartStatus: ViewStatus.success,
          chart: chart,
          source: chart.source,
          isRefreshing: false,
        ),
      ),
    );
  }
}
