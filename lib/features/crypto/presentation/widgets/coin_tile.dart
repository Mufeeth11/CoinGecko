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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showSparkline =
                  constraints.maxWidth >= 350 && coin.sparkline.length > 1;
              return Row(
                children: [
                  SizedBox(
                    width: 23,
                    child: Text(
                      '${coin.marketCapRank}',
                      style: const TextStyle(
                        color: AppColors.faint,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  CoinAvatar(
                    imageUrl: coin.image,
                    symbol: coin.symbol,
                    size: 36,
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
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${coin.symbol} · ${coin.category}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.faint,
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
                      width: 52,
                      height: 28,
                    ),
                  ],
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.currency(coin.currentPrice),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ChangeChip(value: coin.priceChange24h, compact: true),
                    ],
                  ),
                  const SizedBox(width: 2),
                  SizedBox(
                    width: 32,
                    child: IconButton(
                      onPressed: onToggleWatch,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isWatched
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: isWatched ? AppColors.warning : AppColors.faint,
                        size: 20,
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
