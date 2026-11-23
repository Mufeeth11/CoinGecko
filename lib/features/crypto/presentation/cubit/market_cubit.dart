import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/core/state/view_status.dart';
import 'package:coingecko_mini/core/usecase/usecase.dart';
import 'package:coingecko_mini/features/crypto/domain/usecases/get_coins.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/market_filter.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/market_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MarketCubit extends Cubit<MarketState> {
  MarketCubit({required this.getCoins}) : super(const MarketState());

  final GetCoins getCoins;

  Future<void> load({bool refresh = false}) async {
    final isFirstLoad = state.allCoins.isEmpty;
    emit(
      state.copyWith(
        status: isFirstLoad ? ViewStatus.loading : state.status,
        isRefreshing: refresh && !isFirstLoad,
        clearMessage: true,
      ),
    );

    final result = await getCoins(const NoParams());
    result.fold(
      onLeft: (Failure failure) => emit(
        state.copyWith(
          status: state.allCoins.isEmpty
              ? ViewStatus.failure
              : ViewStatus.success,
          message: failure.message,
          isRefreshing: false,
        ),
      ),
      onRight: (snapshot) {
        emit(
          state.copyWith(
            status: ViewStatus.success,
            allCoins: snapshot.coins,
            source: snapshot.source,
            updatedAt: snapshot.updatedAt,
            isRefreshing: false,
          ),
        );
        _applyFilters();
      },
    );
  }

  void setQuery(String query) {
    emit(state.copyWith(query: query));
    _applyFilters();
  }

  void setQuickFilter(MarketQuickFilter filter) {
    emit(state.copyWith(quickFilter: filter));
    _applyFilters();
  }

  void setCategory(String? category) {
    emit(state.copyWith(category: category, clearCategory: category == null));
    _applyFilters();
  }

  void setSort(MarketSort sort) {
    emit(state.copyWith(sort: sort, descending: sort.numeric));
    _applyFilters();
  }

  void toggleSortDirection() {
    emit(state.copyWith(descending: !state.descending));
    _applyFilters();
  }

  void clearFilters() {
    emit(
      state.copyWith(
        query: '',
        quickFilter: MarketQuickFilter.all,
        category: null,
        clearCategory: true,
        clearMessage: true,
      ),
    );
    _applyFilters();
  }

  void _applyFilters() {
    final query = state.query.trim().toLowerCase();
    final filtered = state.allCoins.where((coin) {
      final matchesQuery =
          query.isEmpty ||
          coin.name.toLowerCase().contains(query) ||
          coin.symbol.toLowerCase().contains(query);
      final matchesQuick = switch (state.quickFilter) {
        MarketQuickFilter.all => true,
        MarketQuickFilter.gainers => coin.priceChange24h >= 0,
        MarketQuickFilter.losers => coin.priceChange24h < 0,
      };
      final matchesCategory =
          state.category == null || coin.category == state.category;
      return matchesQuery && matchesQuick && matchesCategory;
    }).toList();

    filtered.sort((a, b) {
      final comparison = switch (state.sort) {
        MarketSort.rank => a.marketCapRank.compareTo(b.marketCapRank),
        MarketSort.marketCap => a.marketCap.compareTo(b.marketCap),
        MarketSort.price => a.currentPrice.compareTo(b.currentPrice),
        MarketSort.volume => a.totalVolume.compareTo(b.totalVolume),
        MarketSort.change24h => a.priceChange24h.compareTo(b.priceChange24h),
        MarketSort.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      };
      return state.descending ? -comparison : comparison;
    });

    emit(state.copyWith(visibleCoins: filtered));
  }
}
