import 'package:flutter/material.dart';

import '../models/ohlc_data_point.dart';
import '../services/stock_history_service.dart';
import '../theme/app_theme.dart';

/// Line chart that shows historical close prices for a [symbol].
/// Includes 3M / 6M / 1Y toggle tabs and fetches live data via
/// [StockHistoryService].
class StockHistoryChart extends StatefulWidget {
  final String symbol;
  final Color lineColor;

  const StockHistoryChart({
    super.key,
    required this.symbol,
    required this.lineColor,
  });

  @override
  State<StockHistoryChart> createState() => _StockHistoryChartState();
}

class _StockHistoryChartState extends State<StockHistoryChart> {
  final _service = StockHistoryService();
  HistoryRange _range = HistoryRange.oneYear;
  late Future<List<OhlcDataPoint>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _service.fetchHistory(widget.symbol, _range);
  }

  void _setRange(HistoryRange range) {
    if (range == _range) return;
    setState(() {
      _range = range;
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Range toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: HistoryRange.values.map((r) {
              final selected = r == _range;
              return GestureDetector(
                onTap: () => _setRange(r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.premiumColor : AppTheme.chipColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    r.label,
                    style: TextStyle(
                      color: selected ? Colors.white : AppTheme.secondaryTextColor,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Chart area
          SizedBox(
            height: 160,
            child: FutureBuilder<List<OhlcDataPoint>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.premiumColor),
                    ),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No chart data available.', style: AppTheme.captionText),
                  );
                }
                return _ChartPainterWidget(
                  points: snapshot.data!,
                  lineColor: widget.lineColor,
                );
              },
            ),
          ),

          const SizedBox(height: 6),
          // Date range labels
          FutureBuilder<List<OhlcDataPoint>>(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
              final points = snapshot.data!;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDate(points.first.date), style: AppTheme.captionText),
                  Text(_formatDate(points.last.date), style: AppTheme.captionText),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _ChartPainterWidget extends StatelessWidget {
  final List<OhlcDataPoint> points;
  final Color lineColor;

  const _ChartPainterWidget({required this.points, required this.lineColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LinePainter(points: points, lineColor: lineColor),
      child: const SizedBox.expand(),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<OhlcDataPoint> points;
  final Color lineColor;

  _LinePainter({required this.points, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final closes = points.map((p) => p.close).toList();
    final minY = closes.reduce((a, b) => a < b ? a : b);
    final maxY = closes.reduce((a, b) => a > b ? a : b);
    final rangeY = (maxY - minY) == 0 ? 1.0 : (maxY - minY);
    final stepX = size.width / (points.length - 1);

    Offset pointAt(int i) {
      final x = stepX * i;
      final t = (closes[i] - minY) / rangeY;
      final y = size.height - (t * size.height * 0.9) - size.height * 0.05;
      return Offset(x, y);
    }

    // Build the line path
    final linePath = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(pointAt(i).dx, pointAt(i).dy);
    }

    // Gradient fill below the line
    final fillPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [lineColor.withValues(alpha: 0.25), lineColor.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Draw the line
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Draw min/max Y labels on the right side
    final labelStyle = const TextStyle(
      color: AppTheme.secondaryTextColor,
      fontSize: 10,
    );
    _drawText(canvas, '${maxY.toStringAsFixed(2)}', Offset(size.width - 52, 2), labelStyle);
    _drawText(canvas, '${minY.toStringAsFixed(2)}', Offset(size.width - 52, size.height - 14), labelStyle);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.points != points || old.lineColor != lineColor;
}
