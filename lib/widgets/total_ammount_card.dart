import 'package:flutter/material.dart';

import '../services/portfolio_service.dart';
import '../theme/app_theme.dart';
/// "Total portfolio value" card shown at the top of the Home screen, with a
/// Demo badge (this is a paper-trading portfolio, no real money moves),
/// the current value, and the change since open.
class TotalAmommount extends StatelessWidget {
  const TotalAmommount({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: PortfolioService.holdings,
      builder: (context, holdings, child) {
        final double total = PortfolioService.totalValue();
        final double changePercent = PortfolioService.totalChangePercent();
        final double changeAmount = PortfolioService.totalGain() - PortfolioService.totalLoss();
        final bool isPositive = changePercent >= 0;
        final Color changeColor = AppTheme.changeColor(changePercent);

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(10, 6, 10, 10),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('TOTAL AMOUNT', style: AppTheme.captionText),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.positiveColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Demo',
                      style: TextStyle(
                        color: AppTheme.positiveColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '€${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: changeColor,
                    size: 20,
                  ),
                  Text(
                    '${changePercent.toStringAsFixed(2)}% (${isPositive ? '+' : ''}€${changeAmount.toStringAsFixed(2)})',
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
