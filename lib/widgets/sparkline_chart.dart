import 'package:flutter/material.dart';

/// A small line ("sparkline") chart used next to the price on the stock
/// detail page. Pure CustomPainter, no extra package dependency required.
class SparklineChart extends StatelessWidget {
  final List<double> values;
  final Color color;
  final double height;

  const SparklineChart({
    super.key,
    required this.values,
    required this.color,
    this.height = 46,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(values: values, color: color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;

  _SparklinePainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final double minV = values.reduce((a, b) => a < b ? a : b);
    final double maxV = values.reduce((a, b) => a > b ? a : b);
    final double range = (maxV - minV) == 0 ? 1 : (maxV - minV);
    final double stepX = size.width / (values.length - 1);

    Offset pointAt(int i) {
      final double x = stepX * i;
      final double t = (values[i] - minV) / range;
      final double y = size.height - (t * size.height);
      return Offset(x, y);
    }

    final linePath = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (int i = 1; i < values.length; i++) {
      final p = pointAt(i);
      linePath.lineTo(p.dx, p.dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}
