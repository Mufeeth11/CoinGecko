import 'package:coingecko_mini/core/di/app_dependencies.dart';
import 'package:coingecko_mini/core/state/view_status.dart';
import 'package:coingecko_mini/core/theme/app_theme.dart';
import 'package:coingecko_mini/core/utils/formatters.dart';
import 'package:coingecko_mini/core/widgets/app_widgets.dart';
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _hero(detail),
          const SizedBox(height: 12),
          _chartCard(context, state),
          const SizedBox(height: 12),
          _statsGrid(detail),
          const SizedBox(height: 12),
          _aboutCard(detail),
        ],
      ),
    );
  }

  Widget _hero(CoinDetail detail) {
    final positive = detail.isPositive;
    return Panel(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CoinAvatar(
                imageUrl: detail.image,
                symbol: detail.symbol,
                size: 46,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.display(size: 19, spacing: -0.4),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'RANK #${detail.marketCapRank}  /  ${detail.category.toUpperCase()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.eyebrow(AppColors.faint),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PRICE / USD', style: AppText.eyebrow(AppColors.faint)),
                    const SizedBox(height: 5),
                    Text(
                      Formatters.currency(detail.currentPrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.mono(
                        size: 28,
                        weight: FontWeight.w700,
                        color: AppColors.text,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ChangeChip(value: detail.priceChange24h),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 20,
                height: 2,
                color: positive ? AppColors.positive : AppColors.negative,
              ),
              const SizedBox(width: 8),
              Text(
                '24H CHANGE ${Formatters.signedPercent(detail.priceChange24h)}',
                style: AppText.mono(
                  size: 9.5,
                  weight: FontWeight.w600,
                  color: positive ? AppColors.positive : AppColors.negative,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Text(
                detail.symbol.toUpperCase(),
                style: AppText.eyebrow(AppColors.faint),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartCard(BuildContext context, CoinDetailState state) {
    return Panel(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Flexible(child: SectionLabel(label: 'Price performance')),
              const SizedBox(width: 8),
              Flexible(child: SourceBadge(source: state.source)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                for (final entry in _windows.entries)
                  Expanded(
                    child: InkWell(
                      onTap: () =>
                          context.read<CoinDetailCubit>().changeDays(entry.key),
                      borderRadius: BorderRadius.circular(3),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: state.days == entry.key
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          entry.value,
                          style: AppText.mono(
                            size: 9.5,
                            weight: FontWeight.w700,
                            color: state.days == entry.key
                                ? AppColors.primary
                                : AppColors.faint,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _chartContent(context, state),
        ],
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
              style: AppText.sans(size: 11.5, color: AppColors.negative),
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
      MapEntry('MARKET CAP', Formatters.compactCurrency(detail.marketCap)),
      MapEntry('VOLUME / 24H', Formatters.compactCurrency(detail.totalVolume)),
      MapEntry(
        'CIRCULATING',
        Formatters.supply(detail.circulatingSupply, detail.symbol),
      ),
      MapEntry(
        'TOTAL SUPPLY',
        Formatters.supply(detail.totalSupply, detail.symbol),
      ),
      MapEntry(
        'MAX SUPPLY',
        Formatters.supply(detail.maxSupply, detail.symbol),
      ),
      MapEntry('ALL-TIME HIGH', Formatters.currency(detail.ath)),
      MapEntry('ALL-TIME LOW', Formatters.currency(detail.atl)),
      MapEntry(
        '24H HIGH / LOW',
        '${Formatters.currency(detail.high24h)} / ${Formatters.currency(detail.low24h)}',
      ),
      MapEntry('7D CHANGE', Formatters.signedPercent(detail.priceChange7d)),
      MapEntry('30D CHANGE', Formatters.signedPercent(detail.priceChange30d)),
    ];

    final rows = <Widget>[];
    for (var index = 0; index < stats.length; index += 2) {
      final left = stats[index];
      final right = index + 1 < stats.length ? stats[index + 1] : null;
      if (rows.isNotEmpty) rows.add(const Divider(height: 1));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _statCell(left, _statColor(left.key, detail)),
              ),
              const VerticalDivider(
                width: 1,
                thickness: 1,
                color: AppColors.border,
              ),
              Expanded(
                child: right == null
                    ? const SizedBox.shrink()
                    : _statCell(right, _statColor(right.key, detail)),
              ),
            ],
          ),
        ),
      );
    }

    return Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 11),
            child: Row(
              children: [
                const SectionLabel(label: 'Key statistics'),
                const Spacer(),
                Text(
                  '${stats.length} METRICS',
                  style: AppText.eyebrow(AppColors.faint),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...rows,
        ],
      ),
    );
  }

  Color? _statColor(String key, CoinDetail detail) {
    if (key == '7D CHANGE') {
      return detail.priceChange7d >= 0
          ? AppColors.positive
          : AppColors.negative;
    }
    if (key == '30D CHANGE') {
      return detail.priceChange30d >= 0
          ? AppColors.positive
          : AppColors.negative;
    }
    return null;
  }

  Widget _statCell(MapEntry<String, String> entry, Color? color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 11, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(entry.key, style: AppText.eyebrow(AppColors.faint)),
          const SizedBox(height: 5),
          Text(
            entry.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.mono(
              size: 11.5,
              weight: FontWeight.w600,
              color: color ?? AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutCard(CoinDetail detail) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ${detail.name}',
            style: AppText.display(size: 17, spacing: -0.4),
          ),
          const SizedBox(height: 10),
          Text(
            detail.description.isEmpty
                ? 'No description available.'
                : detail.description,
            style: AppText.sans(
              size: 12,
              color: AppColors.muted,
              height: 1.6,
            ),
          ),
          if (detail.categories.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final category in detail.categories.take(4))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: AppText.mono(
                        size: 8.5,
                        weight: FontWeight.w600,
                        color: AppColors.faint,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
