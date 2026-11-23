import 'package:coingecko_mini/core/di/app_dependencies.dart';
import 'package:coingecko_mini/core/state/view_status.dart';
import 'package:coingecko_mini/core/theme/app_theme.dart';
import 'package:coingecko_mini/core/utils/formatters.dart';
import 'package:coingecko_mini/core/widgets/state_widgets.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/coin.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/market_cubit.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/market_filter.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/market_state.dart';
import 'package:coingecko_mini/features/crypto/presentation/screens/coin_detail_screen.dart';
import 'package:coingecko_mini/features/crypto/presentation/widgets/coin_tile.dart';
import 'package:coingecko_mini/features/crypto/presentation/widgets/coin_tile_skeleton.dart';
import 'package:coingecko_mini/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:coingecko_mini/features/watchlist/presentation/cubit/watchlist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MarketCubit, MarketState>(
      listener: (context, state) {
        if (state.message != null && state.allCoins.isNotEmpty) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: AppColors.surfaceElevated,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () => context.read<MarketCubit>().load(refresh: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _header(state)),
              SliverToBoxAdapter(child: _controls(state)),
              if (state.message != null && state.allCoins.isNotEmpty)
                SliverToBoxAdapter(child: _errorBanner(state.message!)),
              if (state.status.isLoading && state.allCoins.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      children: [
                        CoinTileSkeleton(),
                        SizedBox(height: 10),
                        CoinTileSkeleton(),
                        SizedBox(height: 10),
                        CoinTileSkeleton(),
                        SizedBox(height: 10),
                        CoinTileSkeleton(),
                        SizedBox(height: 10),
                        CoinTileSkeleton(),
                      ],
                    ),
                  ),
                )
              else if (state.status.hasError && state.allCoins.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorView(
                    message: state.message ?? 'Unable to load market data.',
                    onRetry: () => context.read<MarketCubit>().load(),
                  ),
                )
              else if (state.visibleCoins.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyView(
                    title: 'No coins found',
                    message: state.hasActiveFilters
                        ? 'Try a different search or clear your filters.'
                        : 'Market data is currently empty. Pull down to refresh.',
                    onAction: state.hasActiveFilters
                        ? () {
                            _searchController.clear();
                            context.read<MarketCubit>().clearFilters();
                          }
                        : null,
                    actionLabel: 'Clear filters',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  sliver: SliverList.builder(
                    itemCount: state.visibleCoins.length,
                    itemBuilder: (context, index) {
                      final coin = state.visibleCoins[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: BlocBuilder<WatchlistCubit, WatchlistState>(
                          builder: (context, watchlist) {
                            return CoinTile(
                              coin: coin,
                              isWatched: watchlist.isWatched(coin.id),
                              onTap: () => _openCoin(context, coin),
                              onToggleWatch: () => context
                                  .read<WatchlistCubit>()
                                  .toggle(coin.id),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(MarketState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Markets',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontSize: 28),
                ),
              ),
              SourceBadge(source: state.source),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Live prices, volume and market cap at a glance',
            style: TextStyle(color: AppColors.muted, fontSize: 12.5),
          ),
          if (state.updatedAt != null) ...[
            const SizedBox(height: 6),
            Text(
              'Updated ${Formatters.dateTime(state.updatedAt)}',
              style: const TextStyle(color: AppColors.faint, fontSize: 10.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _controls(MarketState state) {
    final cubit = context.read<MarketCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: cubit.setQuery,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search coins by name or symbol',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: state.query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        cubit.setQuery('');
                      },
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip(
                        label: MarketQuickFilter.all.label,
                        selected:
                            state.quickFilter == MarketQuickFilter.all &&
                            state.category == null,
                        onSelected: (_) {
                          cubit.setQuickFilter(MarketQuickFilter.all);
                          cubit.setCategory(null);
                        },
                      ),
                      _filterChip(
                        label: MarketQuickFilter.gainers.label,
                        selected:
                            state.quickFilter == MarketQuickFilter.gainers,
                        onSelected: (_) =>
                            cubit.setQuickFilter(MarketQuickFilter.gainers),
                      ),
                      _filterChip(
                        label: MarketQuickFilter.losers.label,
                        selected: state.quickFilter == MarketQuickFilter.losers,
                        onSelected: (_) =>
                            cubit.setQuickFilter(MarketQuickFilter.losers),
                      ),
                      for (final category in state.availableCategories)
                        _filterChip(
                          label: category,
                          selected: state.category == category,
                          onSelected: (selected) =>
                              cubit.setCategory(selected ? category : null),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _sortButton(state),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }

  Widget _sortButton(MarketState state) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _showSortSheet(state),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.swap_vert_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                state.sort.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              Text(
                state.descending ? ' ↓' : ' ↑',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortSheet(MarketState state) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final cubit = sheetContext.read<MarketCubit>();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sort by',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.unfold_more_rounded,
                        color: AppColors.primary,
                      ),
                      tooltip: state.descending ? 'Descending' : 'Ascending',
                      onPressed: cubit.toggleSortDirection,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RadioGroup<MarketSort>(
                  groupValue: state.sort,
                  onChanged: (value) {
                    if (value != null) cubit.setSort(value);
                    Navigator.of(sheetContext).pop();
                  },
                  child: Column(
                    children: [
                      for (final option in MarketSort.values)
                        ListTile(
                          title: Text(option.label),
                          leading: Radio<MarketSort>(
                            value: option,
                            activeColor: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _errorBanner(String message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.negative.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.negative.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 17,
              color: AppColors.negative,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.negative,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCoin(BuildContext context, Coin coin) {
    final dependencies = widget.dependencies;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => dependencies.createCoinDetailCubit()..load(coin.id),
          child: CoinDetailScreen(coinId: coin.id, dependencies: dependencies),
        ),
      ),
    );
  }
}
