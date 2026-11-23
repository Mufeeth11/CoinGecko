import 'package:coingecko_mini/core/di/app_dependencies.dart';
import 'package:coingecko_mini/core/state/view_status.dart';
import 'package:coingecko_mini/core/theme/app_theme.dart';
import 'package:coingecko_mini/core/widgets/app_widgets.dart';
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
                    child: PageHeader(
                      eyebrow: 'CoinScope / Personal tape',
                      title: 'Watchlist',
                      subtitle: watchlist.ids.isEmpty
                          ? 'Star coins to follow them in one place.'
                          : '${watchlist.ids.length} asset${watchlist.ids.length == 1 ? '' : 's'} followed, sorted with the market.',
                      trailing: SourceBadge(source: market.source),
                    ),
                  ),
                  if (watchlist.message != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Text(
                          watchlist.message!,
                          style: AppText.sans(
                            size: 11.5,
                            color: AppColors.negative,
                          ),
                        ),
                      ),
                    ),
                  if (market.status.isLoading && market.allCoins.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 18, 16, 0),
                        child: Column(
                          children: [
                            CoinTileSkeleton(),
                            CoinTileSkeleton(),
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
                        message:
                            'Add coins with the star icon to track their prices in one place.',
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
                        message:
                            'Refresh market data or remove these assets from your watchlist.',
                        icon: Icons.cloud_off_rounded,
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                        child: Row(
                          children: [
                            const SectionLabel(label: 'Tracked assets'),
                            const Spacer(),
                            Text(
                              '${watchedCoins.length}',
                              style: AppText.eyebrow(AppColors.faint),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      sliver: SliverList.builder(
                        itemCount: watchedCoins.length,
                        itemBuilder: (context, index) {
                          final coin = watchedCoins[index];
                          return CoinTile(
                            coin: coin,
                            isWatched: true,
                            onTap: () => _openCoin(context, coin),
                            onToggleWatch: () =>
                                context.read<WatchlistCubit>().toggle(coin.id),
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
