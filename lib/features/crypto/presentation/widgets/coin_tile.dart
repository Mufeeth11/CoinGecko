import 'package:coingecko_mini/core/theme/app_theme.dart';
import 'package:coingecko_mini/core/utils/formatters.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/coin.dart';
import 'package:coingecko_mini/features/crypto/presentation/widgets/change_chip.dart';
import 'package:coingecko_mini/features/crypto/presentation/widgets/coin_avatar.dart';
import 'package:coingecko_mini/features/crypto/presentation/widgets/sparkline.dart';
import 'package:flutter/material.dart';

class CoinTile extends StatelessWidget {
  const CoinTile({
    super.key,
    required this.coin,
    required this.isWatched,
    required this.onTap,
    required this.onToggleWatch,
  });

  final Coin coin;
  final bool isWatched;
  final VoidCallback onTap;
  final VoidCallback onToggleWatch;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          padding: const EdgeInsets.fromLTRB(4, 12, 2, 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.border.withValues(alpha: 0.85),
              ),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showSparkline =
                  constraints.maxWidth >= 380 && coin.sparkline.length > 1;
              return Row(
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(
                      '${coin.marketCapRank}',
                      style: AppText.mono(
                        size: 10,
                        weight: FontWeight.w500,
                        color: AppColors.faint,
                      ),
                    ),
                  ),
                  CoinAvatar(
                    imageUrl: coin.image,
                    symbol: coin.symbol,
                    size: 34,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coin.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.sans(
                            size: 13,
                            weight: FontWeight.w600,
                            color: AppColors.text,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          coin.category.isEmpty
                              ? coin.symbol.toUpperCase()
                              : '${coin.symbol.toUpperCase()} · ${coin.category}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.mono(
                            size: 9,
                            color: AppColors.faint,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showSparkline) ...[
                    const SizedBox(width: 8),
                    Sparkline(
                      points: coin.sparkline,
                      positive: coin.isPositive,
                      width: 48,
                      height: 24,
                    ),
                  ],
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.currency(coin.currentPrice),
                        style: AppText.mono(
                          size: 12,
                          weight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ChangeChip(value: coin.priceChange24h, compact: true),
                    ],
                  ),
                  const SizedBox(width: 2),
                  SizedBox(
                    width: 30,
                    child: IconButton(
                      onPressed: onToggleWatch,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isWatched
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: isWatched
                            ? AppColors.warning
                            : AppColors.faint,
                        size: 18,
                      ),
                      tooltip: isWatched
                          ? 'Remove from watchlist'
                          : 'Add to watchlist',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
