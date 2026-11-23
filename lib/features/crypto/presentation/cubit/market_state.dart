import 'package:coingecko_mini/core/state/view_status.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/coin.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/market_filter.dart';
import 'package:equatable/equatable.dart';

class MarketState extends Equatable {
  const MarketState({
    this.status = ViewStatus.initial,
    this.allCoins = const <Coin>[],
    this.visibleCoins = const <Coin>[],
    this.query = '',
    this.quickFilter = MarketQuickFilter.all,
    this.category,
    this.sort = MarketSort.marketCap,
    this.descending = true,
    this.source = '',
    this.updatedAt,
    this.message,
    this.isRefreshing = false,
  });

  final ViewStatus status;
  final List<Coin> allCoins;
  final List<Coin> visibleCoins;
  final String query;
  final MarketQuickFilter quickFilter;
  final String? category;
  final MarketSort sort;
  final bool descending;
  final String source;
  final DateTime? updatedAt;
  final String? message;
  final bool isRefreshing;

  bool get hasActiveFilters =>
      query.isNotEmpty ||
      quickFilter != MarketQuickFilter.all ||
      category != null;

  List<String> get availableCategories {
    final counts = <String, int>{};
    for (final coin in allCoins) {
      if (coin.category.isEmpty) continue;
      counts[coin.category] = (counts[coin.category] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    return entries.take(5).map((entry) => entry.key).toList();
  }

  MarketState copyWith({
    ViewStatus? status,
    List<Coin>? allCoins,
    List<Coin>? visibleCoins,
    String? query,
    MarketQuickFilter? quickFilter,
    String? category,
    bool clearCategory = false,
    MarketSort? sort,
    bool? descending,
    String? source,
    DateTime? updatedAt,
    String? message,
    bool clearMessage = false,
    bool? isRefreshing,
  }) {
    return MarketState(
      status: status ?? this.status,
      allCoins: allCoins ?? this.allCoins,
      visibleCoins: visibleCoins ?? this.visibleCoins,
      query: query ?? this.query,
      quickFilter: quickFilter ?? this.quickFilter,
      category: clearCategory ? null : category ?? this.category,
      sort: sort ?? this.sort,
      descending: descending ?? this.descending,
      source: source ?? this.source,
      updatedAt: updatedAt ?? this.updatedAt,
      message: clearMessage ? null : message ?? this.message,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allCoins,
    visibleCoins,
    query,
    quickFilter,
    category,
    sort,
    descending,
    source,
    updatedAt,
    message,
    isRefreshing,
  ];
}
