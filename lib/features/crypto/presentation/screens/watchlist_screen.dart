import 'package:coingecko_mini/core/di/app_dependencies.dart';
import 'package:coingecko_mini/core/state/view_status.dart';
import 'package:coingecko_mini/core/theme/app_theme.dart';
import 'package:coingecko_mini/core/widgets/state_widgets.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/coin.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/market_cubit.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/market_state.dart';
import 'package:coingecko_mini/features/crypto/presentation/screens/coin_detail_screen.dart';
import 'package:coingecko_mini/features/crypto/presentation/widgets/coin_tile.dart';
import 'package:coingecko_mini/features/crypto/presentation/widgets/coin_tile_skeleton.dart';
import 'package:coingecko_mini/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:coingecko_mini/features/watchlist/presentation/cubit/watchlist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({
    super.key,
    required this.dependencies,
    required this.onExploreMarkets,
  });

  final AppDependencies dependencies;
  final VoidCallback onExploreMarkets;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistCubit, WatchlistState>(
      builder: (context, watchlist) {
        return BlocBuilder<MarketCubit, MarketState>(
          builder: (context, market) {
            final watchedCoins = market.allCoins
                .where((coin) => watchlist.ids.contains(coin.id))
                .toList();

            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                await Future.wait([
                  context.read<MarketCubit>().load(refresh: true),
                  context.read<WatchlistCubit>().load(),
                ]);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Watchlist',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontSize: 28),
                                ),
                              ),
                              SourceBadge(source: market.source),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            watchlist.ids.isEmpty
                                ? 'Star coins to follow them here'
                                : '${watchlist.ids.length} asset${watchlist.ids.length == 1 ? '' : 's'} followed',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (watchlist.message != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          watchlist.message!,
                          style: const TextStyle(
                            color: AppColors.negative,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ),
                  if (market.status.isLoading && market.allCoins.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            CoinTileSkeleton(),
                            SizedBox(height: 10),
                            CoinTileSkeleton(),
                            SizedBox(height: 10),
                            CoinTileSkeleton(),
                          ],
                        ),
                      ),
                    )
                  else if (market.status.hasError && market.allCoins.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: ErrorView(
                        message: market.message ?? 'Unable to load prices.',
                        onRetry: () => context.read<MarketCubit>().load(),
                      ),
                    )
                  else if (watchlist.ids.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyView(
                        title: 'Your watchlist is empty',
                        message: 'Add coins with the star icon to track their prices in one place.',
                        icon: Icons.star_border_rounded,
                        actionLabel: 'Explore markets',
                        onAction: onExploreMarkets,
                      ),
                    )
                  else if (watchedCoins.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyView(
                        title: 'Watched coins unavailable',
                        message: 'Refresh market data or remove these assets from your watchlist.',
                        icon: Icons.cloud_off_rounded,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                      sliver: SliverList.builder(
                        itemCount: watchedCoins.length,
                        itemBuilder: (context, index) {
                          final coin = watchedCoins[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: CoinTile(
                              coin: coin,
                              isWatched: true,
                              onTap: () => _openCoin(context, coin),
                              onToggleWatch: () => context
                                  .read<WatchlistCubit>()
                                  .toggle(coin.id),
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
      },
    );
  }

  void _openCoin(BuildContext context, Coin coin) {
    final dependencies = this.dependencies;
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
