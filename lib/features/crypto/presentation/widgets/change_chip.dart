import 'package:coingecko_mini/core/theme/app_theme.dart';
import 'package:coingecko_mini/core/utils/formatters.dart';
import 'package:flutter/material.dart';

class ChangeChip extends StatelessWidget {
  const ChangeChip({super.key, required this.value, this.compact = false});

  final double value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final positive = value >= 0;
    final color = positive ? AppColors.positive : AppColors.negative;
    final icon = Icon(
      positive ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
      size: compact ? 14 : 16,
      color: color,
    );
    final label = Text(
      Formatters.percent(value.abs()),
      style: AppText.mono(
        size: compact ? 10 : 11,
        weight: FontWeight.w700,
        color: color,
        letterSpacing: 0.1,
      ),
    );

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [icon, const SizedBox(width: 1), label],
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 8, 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [icon, const SizedBox(width: 2), label],
      ),
    );
  }
}
