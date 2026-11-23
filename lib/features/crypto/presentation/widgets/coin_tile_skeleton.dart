import 'package:coingecko_mini/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CoinTileSkeleton extends StatelessWidget {
  const CoinTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 15, 4, 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          _box(18, 8),
          const SizedBox(width: 12),
          _box(34, 34, circle: true),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(96, 9),
                const SizedBox(height: 8),
                _box(58, 7),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _box(60, 9),
              const SizedBox(height: 8),
              _box(38, 7),
            ],
          ),
        ],
      ),
    );
  }

  Widget _box(double width, double height, {bool circle = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(circle ? 100 : 2),
      ),
    );
  }
}
