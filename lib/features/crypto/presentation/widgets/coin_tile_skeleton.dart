import 'package:coingecko_mini/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CoinTileSkeleton extends StatelessWidget {
  const CoinTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            _box(24, 10),
            const SizedBox(width: 12),
            _box(36, 36, circle: true),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(90, 10),
                  const SizedBox(height: 8),
                  _box(60, 8),
                ],
              ),
            ),
            _box(68, 10),
          ],
        ),
      ),
    );
  }

  Widget _box(double width, double height, {bool circle = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(circle ? 100 : 5),
      ),
    );
  }
}
