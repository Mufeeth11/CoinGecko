import 'package:coingecko_mini/core/di/app_dependencies.dart';
import 'package:coingecko_mini/core/state/view_status.dart';
import 'package:coingecko_mini/core/theme/app_theme.dart';
import 'package:coingecko_mini/core/utils/formatters.dart';
import 'package:coingecko_mini/core/widgets/state_widgets.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/coin.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/coin_detail_cubit.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/coin_detail_state.dart';
import 'package:coingecko_mini/features/crypto/presentation/widgets/change_chip.dart';
import 'package:coingecko_mini/features/crypto/presentation/widgets/coin_avatar.dart';
import 'package:coingecko_mini/features/crypto/presentation/widgets/interactive_price_chart.dart';
import 'package:coingecko_mini/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:coingecko_mini/features/watchlist/presentation/cubit/watchlist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoinDetailScreen extends StatelessWidget {
  const CoinDetailScreen({
    super.key,
    required this.coinId,
    required this.dependencies,
  });

  final String coinId;
  final AppDependencies dependencies;

  static const _windows = <String, String>{
    '1': '1D',
    '7': '7D',
    '30': '30D',
    '90': '90D',
    '365': '1Y',
  };

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CoinDetailCubit, CoinDetailState>(
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: AppColors.surfaceElevated,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final detail = state.detail;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(detail?.name ?? 'Coin details'),
            actions: [
              BlocBuilder<WatchlistCubit, WatchlistState>(
                builder: (context, watchlist) {
                  final watched = watchlist.isWatched(coinId);
                  return IconButton(
                    onPressed: () =>
                        context.read<WatchlistCubit>().toggle(coinId),
                    icon: Icon(
                      watched ? Icons.star_rounded : Icons.star_border_rounded,
                      color: watched ? AppColors.warning : AppColors.muted,
                    ),
                    tooltip: watched
                        ? 'Remove from watchlist'
                        : 'Add to watchlist',
                  );
                },
              ),
              IconButton(
                onPressed: () =>
                    context.read<CoinDetailCubit>().load(coinId, refresh: true),
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
              ),
            ],
          ),
          body: _body(context, state),
        );
      },
    );
  }

  Widget _body(BuildContext context, CoinDetailState state) {
    if (state.status.isLoading && state.detail == null) {
      return const LoadingView(message: 'Loading coin research…');
    }
    if (state.status.hasError && state.detail == null) {
      return ErrorView(
        message: state.message ?? 'Unable to load this coin.',
        onRetry: () => context.read<CoinDetailCubit>().load(coinId),
      );
    }
    final detail = state.detail;
    if (detail == null) {
      return const EmptyView(
        title: 'No coin data',
        message: 'This asset is unavailable.',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () =>
          context.read<CoinDetailCubit>().load(coinId, refresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _hero(detail),
          const SizedBox(height: 14),
          _chartCard(context, state),
          const SizedBox(height: 14),
          _statsGrid(detail),
          const SizedBox(height: 14),
          _aboutCard(detail),
        ],
      ),
    );
  }

  Widget _hero(CoinDetail detail) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CoinAvatar(
                imageUrl: detail.image,
                symbol: detail.symbol,
                size: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${detail.symbol}  ·  Rank #${detail.marketCapRank}  ·  ${detail.category}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Formatters.currency(detail.currentPrice),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: -1,
                ),
              ),
              ChangeChip(value: detail.priceChange24h),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '24h change  ·  ${Formatters.signedPercent(detail.priceChange24h)}',
            style: TextStyle(
              fontSize: 11.5,
              color: detail.isPositive
                  ? AppColors.positive
                  : AppColors.negative,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartCard(BuildContext context, CoinDetailState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Price performance',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SourceBadge(source: state.source),
              ],
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final entry in _windows.entries)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(entry.value),
                        selected: state.days == entry.key,
                        onSelected: (_) => context
                            .read<CoinDetailCubit>()
                            .changeDays(entry.key),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _chartContent(context, state),
          ],
        ),
      ),
    );
  }

  Widget _chartContent(BuildContext context, CoinDetailState state) {
    if (state.chartStatus.isLoading && state.chart == null) {
      return const LoadingView(compact: true);
    }
    if (state.chartStatus.hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            Text(
              state.chartMessage ?? 'Chart unavailable.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.negative),
            ),
            TextButton(
              onPressed: () =>
                  context.read<CoinDetailCubit>().changeDays(state.days),
              child: const Text('Retry chart'),
            ),
          ],
        ),
      );
    }
    final chart = state.chart;
    if (chart == null || chart.isEmpty) {
      return const EmptyView(
        title: 'No chart data',
        message: 'Try another time window.',
      );
    }
    return InteractivePriceChart(chart: chart);
  }

  Widget _statsGrid(CoinDetail detail) {
    final stats = <MapEntry<String, String>>[
      MapEntry('Market cap', Formatters.compactCurrency(detail.marketCap)),
      MapEntry('Volume (24h)', Formatters.compactCurrency(detail.totalVolume)),
      MapEntry(
        'Circulating supply',
        Formatters.supply(detail.circulatingSupply, detail.symbol),
      ),
      MapEntry(
        'Total supply',
        Formatters.supply(detail.totalSupply, detail.symbol),
      ),
      MapEntry(
        'Max supply',
        Formatters.supply(detail.maxSupply, detail.symbol),
      ),
      MapEntry('All-time high', Formatters.currency(detail.ath)),
      MapEntry('All-time low', Formatters.currency(detail.atl)),
      MapEntry(
        '24h high / low',
        '${Formatters.currency(detail.high24h)} / ${Formatters.currency(detail.low24h)}',
      ),
      MapEntry('7d change', Formatters.signedPercent(detail.priceChange7d)),
      MapEntry('30d change', Formatters.signedPercent(detail.priceChange30d)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final item = stats[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.key,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.faint,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _aboutCard(CoinDetail detail) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About ${detail.name}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              detail.description.isEmpty
                  ? 'No description available.'
                  : detail.description,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.muted,
                height: 1.55,
              ),
            ),
            if (detail.categories.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: [
                  for (final category in detail.categories.take(4))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
