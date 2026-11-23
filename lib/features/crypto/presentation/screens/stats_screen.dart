import 'package:coingecko_mini/core/di/app_dependencies.dart';
import 'package:coingecko_mini/core/state/view_status.dart';
import 'package:coingecko_mini/core/theme/app_theme.dart';
import 'package:coingecko_mini/core/utils/formatters.dart';
import 'package:coingecko_mini/core/widgets/app_widgets.dart';
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
                child: PageHeader(
                  eyebrow: 'CoinScope / Global tape',
                  title: 'Market pulse',
                  subtitle: 'Aggregated health of the crypto market.',
                  trailing: SourceBadge(source: state.source),
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
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _metrics(StatsState state) {
    final stats = state.stats!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Panel(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SectionLabel(label: 'Total market cap'),
                    const Spacer(),
                    ChangeChip(value: stats.marketCapChange24h),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  Formatters.compactCurrency(stats.totalMarketCap),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.mono(
                    size: 30,
                    weight: FontWeight.w700,
                    color: AppColors.text,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _inline(
                        '24H VOLUME',
                        Formatters.compactCurrency(stats.totalVolume),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _inline(
                        'LAST UPDATED',
                        Formatters.dateTime(stats.updatedAt),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _metricTile(
                  Icons.layers_outlined,
                  'ACTIVE ASSETS',
                  Formatters.compact(stats.activeCryptocurrencies),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricTile(
                  Icons.public_rounded,
                  'TRACKED MARKETS',
                  Formatters.compact(stats.markets),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inline(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.eyebrow(AppColors.faint)),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.mono(
            size: 11.5,
            weight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _metricTile(IconData icon, String label, String value) {
    return Panel(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(label, style: AppText.eyebrow(AppColors.faint)),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.mono(
              size: 18,
              weight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dominance(StatsState state) {
    final stats = state.stats!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel(label: 'Market dominance'),
            const SizedBox(height: 5),
            Text(
              'Share of total crypto market cap',
              style: AppText.sans(size: 10.5, color: AppColors.faint),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 8,
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
                      child: Container(color: AppColors.faint),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 8,
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
                  AppColors.faint,
                  'OTHERS',
                  Formatters.percent(stats.otherDominance),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(Color color, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppText.mono(
            size: 9,
            weight: FontWeight.w600,
            color: AppColors.faint,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppText.mono(
            size: 10,
            weight: FontWeight.w700,
            color: AppColors.text,
          ),
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
            AppColors.positive,
            state.gainers,
            context,
          ),
          const SizedBox(height: 10),
          _moverCard(
            'Top losers',
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
    Color color,
    List<Coin> coins,
    BuildContext context,
  ) {
    final top = coins.take(4).toList();
    return Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 11),
            child: Row(
              children: [
                SectionLabel(label: title, accent: color),
                const Spacer(),
                Text(
                  '${top.length}',
                  style: AppText.mono(size: 9, color: AppColors.faint),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (top.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No movers available.',
                  style: AppText.sans(size: 11, color: AppColors.faint),
                ),
              ),
            )
          else
            for (var index = 0; index < top.length; index += 1) ...[
              if (index > 0)
                const Divider(height: 1, indent: 14, endIndent: 14),
              InkWell(
                onTap: () => _openCoin(context, top[index]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  child: Row(
                    children: [
                      CoinAvatar(
                        imageUrl: top[index].image,
                        symbol: top[index].symbol,
                        size: 26,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          top[index].symbol.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.mono(
                            size: 10.5,
                            weight: FontWeight.w700,
                            color: AppColors.text,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      Text(
                        Formatters.currency(top[index].currentPrice),
                        style: AppText.mono(
                          size: 10.5,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ChangeChip(
                        value: top[index].priceChange24h,
                        compact: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
        ],
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
