import 'package:coingecko_mini/core/di/app_dependencies.dart';
import 'package:coingecko_mini/core/state/view_status.dart';
import 'package:coingecko_mini/core/theme/app_theme.dart';
import 'package:coingecko_mini/core/utils/formatters.dart';
import 'package:coingecko_mini/core/widgets/app_widgets.dart';
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
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                    child: Column(
                      children: [
                        CoinTileSkeleton(),
                        CoinTileSkeleton(),
                        CoinTileSkeleton(),
                        CoinTileSkeleton(),
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
              else ...[
                SliverToBoxAdapter(child: _ledgerHeader(state)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  sliver: SliverList.builder(
                    itemCount: state.visibleCoins.length,
                    itemBuilder: (context, index) {
                      final coin = state.visibleCoins[index];
                      return BlocBuilder<WatchlistCubit, WatchlistState>(
                        builder: (context, watchlist) {
                          return CoinTile(
                            coin: coin,
                            isWatched: watchlist.isWatched(coin.id),
                            onTap: () => _openCoin(context, coin),
                            onToggleWatch: () =>
                                context.read<WatchlistCubit>().toggle(coin.id),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _header(MarketState state) {
    return PageHeader(
      eyebrow: 'CoinScope / Market terminal',
      title: 'Markets',
      subtitle: 'Spot prices, volume and market cap from a single feed.',
      meta: state.updatedAt == null
          ? null
          : 'UPDATED ${Formatters.dateTime(state.updatedAt).toUpperCase()}',
      trailing: SourceBadge(source: state.source),
    );
  }

  Widget _controls(MarketState state) {
    final cubit = context.read<MarketCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: cubit.setQuery,
            textInputAction: TextInputAction.search,
            style: AppText.sans(size: 13, color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'Search by name or ticker',
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              suffixIcon: state.query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        cubit.setQuery('');
                      },
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterTab(
                        label: MarketQuickFilter.all.label,
                        selected:
                            state.quickFilter == MarketQuickFilter.all &&
                            state.category == null,
                        onTap: () {
                          cubit.setQuickFilter(MarketQuickFilter.all);
                          cubit.setCategory(null);
                        },
                      ),
                      _filterTab(
                        label: MarketQuickFilter.gainers.label,
                        selected:
                            state.quickFilter == MarketQuickFilter.gainers,
                        onTap: () =>
                            cubit.setQuickFilter(MarketQuickFilter.gainers),
                      ),
                      _filterTab(
                        label: MarketQuickFilter.losers.label,
                        selected: state.quickFilter == MarketQuickFilter.losers,
                        onTap: () =>
                            cubit.setQuickFilter(MarketQuickFilter.losers),
                      ),
                      for (final category in state.availableCategories)
                        _filterTab(
                          label: category,
                          selected: state.category == category,
                          onTap: () => cubit.setCategory(
                            state.category == category ? null : category,
                          ),
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

  Widget _filterTab({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(3),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                style: AppText.mono(
                  size: 10,
                  weight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.text : AppColors.faint,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 5),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                width: selected ? 18 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sortButton(MarketState state) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () => _showSortSheet(state),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.swap_vert_rounded,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 5),
              Text(
                state.sort.label.toUpperCase(),
                style: AppText.mono(
                  size: 9.5,
                  weight: FontWeight.w700,
                  color: AppColors.text,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                state.descending
                    ? Icons.south_rounded
                    : Icons.north_rounded,
                size: 12,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ledgerHeader(MarketState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        children: [
          const SectionLabel(label: 'Market ledger'),
          const Spacer(),
          Text(
            '${state.visibleCoins.length} ASSETS',
            style: AppText.eyebrow(AppColors.faint),
          ),
        ],
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
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SORT BY',
                            style: AppText.eyebrow(AppColors.faint),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Order the ledger',
                            style: AppText.display(size: 21, spacing: -0.5),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        state.descending
                            ? Icons.south_rounded
                            : Icons.north_rounded,
                        color: AppColors.primary,
                      ),
                      tooltip: state.descending ? 'Descending' : 'Ascending',
                      onPressed: cubit.toggleSortDirection,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(),
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
                          dense: true,
                          title: Text(option.label),
                          trailing: Radio<MarketSort>(value: option),
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Panel(
        padding: const EdgeInsets.all(12),
        borderColor: AppColors.negative.withValues(alpha: 0.3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(
                Icons.error_outline_rounded,
                size: 15,
                color: AppColors.negative,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FEED WARNING',
                    style: AppText.eyebrow(AppColors.negative),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    style: AppText.sans(
                      size: 11.5,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                ],
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
