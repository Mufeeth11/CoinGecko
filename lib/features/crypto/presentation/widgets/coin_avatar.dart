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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.45)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        symbol.isEmpty ? '?' : symbol.substring(0, 1).toUpperCase(),
        style: TextStyle(
          color: AppColors.background,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.42,
        ),
      ),
    );

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: color.withValues(alpha: 0.15),
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
      ),
    );
  }

  Color _colorFor(String value) {
    final palette = <Color>[
      AppColors.primary,
      AppColors.secondary,
      AppColors.warning,
      Color(0xFF38BDF8),
      Color(0xFFF472B6),
      Color(0xFFFBBF24),
      Color(0xFF34D399),
    ];
    var hash = 0;
    for (final codeUnit in value.toUpperCase().codeUnits) {
      hash = (hash * 31 + codeUnit) & 0xffffffff;
    }
    return palette[hash % palette.length];
  }
}
