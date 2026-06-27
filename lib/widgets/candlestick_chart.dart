import 'dart:math';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A single OHLC data point for the demo candlestick chart.
class CandleData {
  final double open;
  final double close;
  final double high;
  final double low;

  const CandleData({
    required this.open,
    required this.close,
    required this.high,
    required this.low,
  });

  bool get isUp => close >= open;
}

/// The available time ranges shown as tabs above the chart, matching the
/// Figma designs (24H / 1W / 1M / 1Y / All).
const List<String> chartRanges = ['24H', '1W', '1M', '1Y', 'All'];

/// Deterministically generates demo OHLC candles for a given seed + range.
///
/// There is no historical-price API wired up yet (that piece of the app is
/// still a stub on the data/services side), so this produces stable, fake
/// "Demo" data purely so the chart UI has something believable to render.
/// Swap this out for real historical data once the API layer is ready.
List<CandleData> generateDemoCandles({
  required Object seed,
  required String range,
  double base = 100,
}) {
  final int count = switch (range) {
    '24H' => 8,
    '1W' => 10,
    '1M' => 14,
    '1Y' => 18,
    _ => 24,
  };

  final random = Random(Object.hash(seed, range));
  final List<CandleData> candles = [];
  double last = base;

  for (int i = 0; i < count; i++) {
    final double drift = (random.nextDouble() - 0.45) * base * 0.05;
    final double open = last;
    final double close = (open + drift).clamp(base * 0.5, base * 1.5);
    final double high = max(open, close) + random.nextDouble() * base * 0.015;
    final double low = min(open, close) - random.nextDouble() * base * 0.015;

    candles.add(CandleData(open: open, close: close, high: high, low: low));
    last = close;
  }

  return candles;
}

/// Candlestick chart with a row of selectable time-range tabs above it,
/// used on the Home dashboard and the Portfolio overview.
class MarketChart extends StatefulWidget {
  final Object seed;
  final double base;
  final double height;

  const MarketChart({
    super.key,
    required this.seed,
    this.base = 100,
    this.height = 150,
  });

  @override
  State<MarketChart> createState() => _MarketChartState();
}

class _MarketChartState extends State<MarketChart> {
  String _selectedRange = 'All';

  @override
  Widget build(BuildContext context) {
    final candles = generateDemoCandles(
      seed: widget.seed,
      range: _selectedRange,
      base: widget.base,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widget.height,
          width: double.infinity,
          child: CustomPaint(
            painter: _CandlestickPainter(candles: candles),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: chartRanges
              .map(
                (range) => _RangeTab(
                  label: range,
                  selected: range == _selectedRange,
                  onTap: () => setState(() => _selectedRange = range),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _RangeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RangeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.chipColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppTheme.textColor : AppTheme.secondaryTextColor,
          ),
        ),
      ),
    );
  }
}

class _CandlestickPainter extends CustomPainter {
  final List<CandleData> candles;

  _CandlestickPainter({required this.candles});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final double minLow = candles.map((c) => c.low).reduce(min);
    final double maxHigh = candles.map((c) => c.high).reduce(max);
    final double range = (maxHigh - minLow) == 0 ? 1 : (maxHigh - minLow);

    final double slotWidth = size.width / candles.length;
    final double bodyWidth = (slotWidth * 0.5).clamp(3, 18);

    // Faint horizontal gridlines for a bit of depth.
    final gridPaint = Paint()
      ..color = AppTheme.dividerColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (int i = 0; i <= 3; i++) {
      final double y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    double yFor(double value) {
      final double t = (value - minLow) / range;
      return size.height - (t * size.height);
    }

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final double cx = slotWidth * i + slotWidth / 2;
      final Color color =
          candle.isUp ? AppTheme.positiveColor : AppTheme.negativeColor;

      final wickPaint = Paint()
        ..color = color
        ..strokeWidth = 1.6;
      canvas.drawLine(
        Offset(cx, yFor(candle.high)),
        Offset(cx, yFor(candle.low)),
        wickPaint,
      );

      final double openY = yFor(candle.open);
      final double closeY = yFor(candle.close);
      final double top = min(openY, closeY);
      final double bottom = max(openY, closeY);
      final double bodyHeight = max(bottom - top, 2.5);

      final bodyPaint = Paint()..color = color;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - bodyWidth / 2, top, bodyWidth, bodyHeight),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, bodyPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) {
    return oldDelegate.candles != candles;
  }
}
