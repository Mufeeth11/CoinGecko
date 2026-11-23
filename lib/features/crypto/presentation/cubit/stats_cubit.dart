import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/core/state/view_status.dart';
import 'package:coingecko_mini/core/usecase/usecase.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/coin.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/global_stats.dart';
import 'package:coingecko_mini/features/crypto/domain/usecases/get_coins.dart';
import 'package:coingecko_mini/features/crypto/domain/usecases/get_global_stats.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/stats_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatsCubit extends Cubit<StatsState> {
  StatsCubit({required this.getGlobalStats, required this.getCoins})
    : super(const StatsState());

  final GetGlobalStats getGlobalStats;
  final GetCoins getCoins;

  Future<void> load({bool refresh = false}) async {
    final isFirstLoad = state.stats == null;
    emit(
      state.copyWith(
        status: isFirstLoad ? ViewStatus.loading : state.status,
        isRefreshing: refresh && !isFirstLoad,
        clearMessage: true,
      ),
    );

    final statsFuture = getGlobalStats(const NoParams());
    final coinsFuture = getCoins(const NoParams());

    final statsResult = await statsFuture;
    statsResult.fold(
      onLeft: (Failure failure) => emit(
        state.copyWith(
          status: ViewStatus.failure,
          message: failure.message,
          isRefreshing: false,
        ),
      ),
      onRight: (GlobalStats stats) => emit(
        state.copyWith(
          status: ViewStatus.success,
          stats: stats,
          source: stats.source,
          isRefreshing: false,
        ),
      ),
    );

    final coinsResult = await coinsFuture;
    coinsResult.fold(
      onLeft: (_) {}, // Global stats remain usable if the movers list fails.
      onRight: (snapshot) {
        final sorted = List<Coin>.from(snapshot.coins)
          ..sort((a, b) => b.priceChange24h.compareTo(a.priceChange24h));
        emit(
          state.copyWith(
            gainers: sorted
                .where((coin) => coin.priceChange24h > 0)
                .take(5)
                .toList(),
            losers: sorted.reversed
                .where((coin) => coin.priceChange24h < 0)
                .take(5)
                .toList(),
          ),
        );
      },
    );
  }
}
