import 'package:flutter/material.dart';

import '../models/portfolio_holding.dart';
import '../services/portfolio_service.dart';
import '../theme/app_theme.dart';
import 'stock_detail_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  static const List<String> _categories = ['All', 'Stock', 'Crypto', 'Bonds'];
  int _selectedCategory = 0;

  void _onSelectCategory(int index) {
    if (index <= 1) {
      setState(() => _selectedCategory = index);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_categories[index]} support is coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: const Text('Portfolio', style: AppTheme.screenTitle),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<PortfolioHolding>>(
          valueListenable: PortfolioService.holdings,
          builder: (context, holdings, child) {
            final total = PortfolioService.totalValue();
            final gain = PortfolioService.totalGain();
            final loss = PortfolioService.totalLoss();

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Portfolio value', style: AppTheme.captionText),
                        const SizedBox(height: 6),
                        Text(
                          '€${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.arrow_upward,
                            iconColor: AppTheme.positiveColor,
                            label: 'Gain',
                            value: '€${gain.toStringAsFixed(2)}',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.arrow_downward,
                            iconColor: AppTheme.negativeColor,
                            label: 'Loss',
                            value: '€${loss.toStringAsFixed(2)}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final bool selected = index == _selectedCategory;
                        final bool enabled = index <= 1;
                        return GestureDetector(
                          onTap: () => _onSelectCategory(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? AppTheme.premiumColor : AppTheme.chipColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _categories[index],
                              style: TextStyle(
                                color: enabled ? AppTheme.textColor : AppTheme.secondaryTextColor,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('All', style: AppTheme.sectionTitle),
                  ),
                  const SizedBox(height: 6),
                  if (holdings.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                      child: Center(
                        child: Text(
                          'Your portfolio is empty.\nBuy a stock to add it here.',
                          textAlign: TextAlign.center,
                          style: AppTheme.captionText,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        children: [
                          for (final holding in holdings) PortfolioStockTile(holding: holding),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.tileRadius),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: iconColor.withValues(alpha: 0.18),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.captionText),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PortfolioStockTile extends StatelessWidget {
  const PortfolioStockTile({
    super.key,
    required this.holding,
  });

  final PortfolioHolding holding;

  Map<String, dynamic> _toStockMap() {
    // Back-calculate open from close and change percent:
    // change% = ((close - open) / open) * 100  →  open = close / (1 + change/100)
    final double close = holding.price;
    final double open = holding.change == -100
        ? 0
        : close / (1 + holding.change / 100);
    return {
      'symbol': holding.symbol,
      'name': holding.name,
      'price_currency': holding.currency,
      'close': close,
      'open': open,
      'date': '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final Color changeColor = AppTheme.changeColor(holding.change);
    final bool isPositive = holding.change >= 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StockDetailScreen(stock: _toStockMap()),
        ),
      ),
      child: Container(
      margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.tileRadius),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.chipColor,
            child: Text(
              holding.symbol.isNotEmpty ? holding.symbol[0] : '?',
              style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holding.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${holding.symbol} · ${holding.quantity} shares',
                  style: AppTheme.captionText,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${holding.currency} ${holding.totalValue.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.changeBg(holding.change),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${isPositive ? '↑' : '↓'} ${holding.change.abs().toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: changeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
