import 'package:coingecko_mini/core/di/app_dependencies.dart';
import 'package:coingecko_mini/core/state/view_status.dart';
import 'package:coingecko_mini/core/theme/app_theme.dart';
import 'package:coingecko_mini/core/utils/formatters.dart';
import 'package:coingecko_mini/core/widgets/state_widgets.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/coin.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/stats_cubit.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/stats_state.dart';
import 'package:coingecko_mini/features/crypto/presentation/screens/coin_detail_screen.dart';
import 'package:coingecko_mini/features/crypto/presentation/widgets/change_chip.dart';
import 'package:coingecko_mini/features/crypto/presentation/widgets/coin_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StatsCubit, StatsState>(
      listener: (context, state) {
        if (state.message != null) {
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
          onRefresh: () => context.read<StatsCubit>().load(refresh: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Market pulse',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontSize: 28),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Global crypto market statistics',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SourceBadge(source: state.source),
                    ],
                  ),
                ),
              ),
              if (state.status.isLoading && state.stats == null)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: LoadingView(
                    message: 'Aggregating global market data…',
                  ),
                )
              else if (state.status.hasError && state.stats == null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorView(
                    message: state.message ?? 'Unable to load global stats.',
                    onRetry: () => context.read<StatsCubit>().load(),
                  ),
                )
              else if (state.stats == null)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyView(
                    title: 'No statistics yet',
                    message: 'Pull down to refresh.',
                  ),
                )
              else ...[
                SliverToBoxAdapter(child: _metrics(state)),
                SliverToBoxAdapter(child: _dominance(state)),
                SliverToBoxAdapter(child: _movers(context, state)),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _metrics(StatsState state) {
    final stats = state.stats!;
    final items = <MapEntry<String, String>>[
      MapEntry(
        'Total market cap',
        Formatters.compactCurrency(stats.totalMarketCap),
      ),
      MapEntry(
        '24h trading volume',
        Formatters.compactCurrency(stats.totalVolume),
      ),
      MapEntry(
        'Market cap (24h)',
        Formatters.signedPercent(stats.marketCapChange24h),
      ),
      MapEntry(
        'Active cryptocurrencies',
        Formatters.compact(stats.activeCryptocurrencies),
      ),
      MapEntry('Tracked markets', Formatters.compact(stats.markets)),
      MapEntry('Last updated', Formatters.dateTime(stats.updatedAt)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.35,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isChange = index == 2;
          final valueColor = isChange
              ? (stats.marketCapChange24h >= 0
                    ? AppColors.positive
                    : AppColors.negative)
              : AppColors.text;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    [
                      Icons.account_balance_wallet_outlined,
                      Icons.swap_horiz_rounded,
                      Icons.trending_up_rounded,
                      Icons.layers_outlined,
                      Icons.public_rounded,
                      Icons.schedule_rounded,
                    ][index],
                    size: 18,
                    color: isChange ? valueColor : AppColors.primary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.key,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.faint,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: valueColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _dominance(StatsState state) {
    final stats = state.stats!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Market dominance',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Share of the total crypto market cap',
                style: TextStyle(fontSize: 11, color: AppColors.faint),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 12,
                  child: Row(
                    children: [
                      Expanded(
                        flex: stats.btcDominance.round().clamp(1, 100),
                        child: Container(color: AppColors.warning),
                      ),
                      Expanded(
                        flex: stats.ethDominance.round().clamp(1, 100),
                        child: Container(color: AppColors.secondary),
                      ),
                      Expanded(
                        flex: stats.otherDominance.round().clamp(1, 100),
                        child: Container(color: AppColors.surfaceSoft),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _legend(
                    AppColors.warning,
                    'BTC',
                    Formatters.percent(stats.btcDominance),
                  ),
                  _legend(
                    AppColors.secondary,
                    'ETH',
                    Formatters.percent(stats.ethDominance),
                  ),
                  _legend(
                    AppColors.surfaceSoft,
                    'Others',
                    Formatters.percent(stats.otherDominance),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legend(Color color, String label, String value) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.faint),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _movers(BuildContext context, StatsState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        children: [
          _moverCard(
            'Top gainers',
            Icons.trending_up_rounded,
            AppColors.positive,
            state.gainers,
            context,
          ),
          const SizedBox(height: 12),
          _moverCard(
            'Top losers',
            Icons.trending_down_rounded,
            AppColors.negative,
            state.losers,
            context,
          ),
        ],
      ),
    );
  }

  Widget _moverCard(
    String title,
    IconData icon,
    Color color,
    List<Coin> coins,
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 17, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (coins.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No movers available.',
                  style: TextStyle(fontSize: 11, color: AppColors.faint),
                ),
              )
            else
              for (final coin in coins.take(4))
                InkWell(
                  onTap: () => _openCoin(context, coin),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        CoinAvatar(
                          imageUrl: coin.image,
                          symbol: coin.symbol,
                          size: 28,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            coin.symbol,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          Formatters.currency(coin.currentPrice),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ChangeChip(value: coin.priceChange24h, compact: true),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
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
