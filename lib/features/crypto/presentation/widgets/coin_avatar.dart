import 'package:coingecko_mini/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CoinAvatar extends StatelessWidget {
  const CoinAvatar({
    super.key,
    required this.imageUrl,
    required this.symbol,
    this.size = 38,
  });

  final String imageUrl;
  final String symbol;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(symbol);
    final fallback = Container(
      alignment: Alignment.center,
      color: color,
      child: Text(
        symbol.isEmpty ? '?' : symbol.substring(0, 1).toUpperCase(),
        style: AppText.sans(
          size: size * 0.4,
          weight: FontWeight.w800,
          color: AppColors.background,
        ),
      ),
    );

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.16),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
      ),
      child: imageUrl.trim().isEmpty
          ? fallback
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
              errorBuilder: (_, _, _) => fallback,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return fallback;
              },
            ),
    );
  }

  Color _colorFor(String value) {
    final palette = <Color>[
      AppColors.primary,
      AppColors.secondary,
      AppColors.warning,
      const Color(0xFF6FB7E8),
      const Color(0xFFE58FB5),
      const Color(0xFFE0B25C),
      const Color(0xFF63C7A8),
    ];
    var hash = 0;
    for (final codeUnit in value.toUpperCase().codeUnits) {
      hash = (hash * 31 + codeUnit) & 0xffffffff;
    }
    return palette[hash % palette.length];
  }
}
