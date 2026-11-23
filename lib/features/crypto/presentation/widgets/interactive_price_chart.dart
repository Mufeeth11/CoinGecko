import 'package:coingecko_mini/core/theme/app_theme.dart';
import 'package:coingecko_mini/core/utils/formatters.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/market_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class InteractivePriceChart extends StatefulWidget {
  const InteractivePriceChart({
    super.key,
    required this.chart,
    this.height = 230,
  });

  final MarketChart chart;
  final double height;

  @override
  State<InteractivePriceChart> createState() => _InteractivePriceChartState();
}

class _InteractivePriceChartState extends State<InteractivePriceChart> {
  int? _touchedIndex;

  @override
  void didUpdateWidget(covariant InteractivePriceChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chart != widget.chart) _touchedIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.chart.prices;
    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i += 1)
        FlSpot(i.toDouble(), points[i].value),
    ];
    final positive = (widget.chart.periodChangePercent ?? 0) >= 0;
    final color = positive ? AppColors.positive : AppColors.negative;
    final activeIndex = _touchedIndex != null && _touchedIndex! < points.length
        ? _touchedIndex!
        : points.length - 1;
    final activePoint = activeIndex >= 0 ? points[activeIndex] : null;
    final labelInterval = (points.length / 4).round().clamp(1, points.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                Formatters.currency(activePoint?.value),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.mono(
                  size: 19,
                  weight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
            if (activePoint != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  Formatters.dateTime(activePoint.time),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: AppText.mono(size: 9.5, color: AppColors.faint),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: widget.height,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (points.length - 1).toDouble(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.border.withValues(alpha: 0.45),
                  strokeWidth: 1,
                  dashArray: [3, 5],
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 52,
                    interval: _yInterval(points),
                    getTitlesWidget: (value, meta) {
                      if (value == meta.min || value == meta.max) {
                        return Text(
                          Formatters.compactCurrency(value),
                          style: AppText.mono(size: 8.5, color: AppColors.faint),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    interval: labelInterval.toDouble(),
                    getTitlesWidget: (value, meta) {
                      final index = value.round();
                      if (index < 0 || index >= points.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          Formatters.shortDate(points[index].time),
                          style: AppText.mono(size: 8.5, color: AppColors.faint),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.18,
                  preventCurveOverShooting: true,
                  color: color,
                  barWidth: 1.8,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withValues(alpha: 0.18),
                        color.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchSpotThreshold: 18,
                touchCallback: (event, response) {
                  final spots = response?.lineBarSpots;
                  if (spots == null || spots.isEmpty) {
                    setState(() => _touchedIndex = null);
                    return;
                  }
                  setState(
                    () => _touchedIndex = spots.first.x.round().clamp(
                      0,
                      points.length - 1,
                    ),
                  );
                },
                touchTooltipData: LineTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  tooltipBorderRadius: BorderRadius.circular(3),
                  tooltipPadding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  getTooltipColor: (_) => AppColors.surfaceElevated,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final index = spot.x.round().clamp(0, points.length - 1);
                      return LineTooltipItem(
                        '${Formatters.currency(spot.y)}\n${Formatters.shortDate(points[index].time)}',
                        AppText.mono(
                          size: 10,
                          weight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _yInterval(List<MarketPoint> points) {
    if (points.isEmpty) return 1;
    var min = points.first.value;
    var max = points.first.value;
    for (final point in points) {
      if (point.value < min) min = point.value;
      if (point.value > max) max = point.value;
    }
    final span = max - min;
    return span > 0 ? span / 3 : 1;
  }
}
