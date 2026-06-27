import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A labelled horizontal range indicator (used for "Day's Range" and
/// "52WK Range" on the stock detail page). Shows a track with a small
/// marker positioned at [value]'s fraction between [low] and [high].
class RangeBar extends StatelessWidget {
  final String label;
  final double low;
  final double high;
  final double value;
  final String Function(double) formatter;

  const RangeBar({
    super.key,
    required this.label,
    required this.low,
    required this.high,
    required this.value,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final double range = (high - low) == 0 ? 1 : (high - low);
    final double fraction = ((value - low) / range).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.captionText),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final double markerX = fraction * constraints.maxWidth;
            return SizedBox(
              height: 16,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 5,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.negativeColor,
                            AppTheme.amberColor,
                            AppTheme.positiveColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (markerX - 6).clamp(0.0, constraints.maxWidth - 12),
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatter(low), style: AppTheme.captionText),
            Text(formatter(high), style: AppTheme.captionText),
          ],
        ),
      ],
    );
  }
}
