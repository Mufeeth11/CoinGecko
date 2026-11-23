import 'package:coingecko_mini/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.points,
    required this.positive,
    this.width = 64,
    this.height = 30,
  });

  final List<double> points;
  final bool positive;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          points,
          positive ? AppColors.positive : AppColors.negative,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.points, this.color);

  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    var min = points.reduce((a, b) => a < b ? a : b);
    var max = points.reduce((a, b) => a > b ? a : b);
    if (max - min < 1e-9) {
      max += 1;
      min -= 1;
    }
    final span = max - min;
    final stepX = size.width / (points.length - 1);
    Offset positionAt(int index) => Offset(
      index * stepX,
      size.height - 3 - ((points[index] - min) / span) * (size.height - 6),
    );

    final path = Path()..moveTo(0, positionAt(0).dy);
    for (var i = 1; i < points.length; i += 1) {
      final current = positionAt(i);
      final previous = positionAt(i - 1);
      final midX = (previous.dx + current.dx) / 2;
      path.cubicTo(midX, previous.dy, midX, current.dy, current.dx, current.dy);
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      color != oldDelegate.color || !listEquals(points, oldDelegate.points);
}
