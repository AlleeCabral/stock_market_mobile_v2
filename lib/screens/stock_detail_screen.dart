import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/stock_change_helper.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';
import '../services/portfolio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/candlestick_chart.dart';
import '../widgets/sparkline_chart.dart';
import '../widgets/stock_history_chart.dart';

class StockDetailScreen extends StatefulWidget {
  final Map<String, dynamic> stock;

  const StockDetailScreen({
    super.key,
    required this.stock,
  });

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  late Future<List<NewsArticle>> _newsFuture;

  @override
  void initState() {
    super.initState();
    final String name = (widget.stock['name'] ?? '').toString();
    final String symbol = (widget.stock['symbol'] ?? '').toString();
    _newsFuture = NewsService().fetchCompanyNews(name, symbol);
  }

  @override
  Widget build(BuildContext context) {
    final stock = widget.stock;
    final String symbol = (stock['symbol'] ?? '').toString();
    final String name = (stock['name'] ?? '').toString();
    final String currency = (stock['price_currency'] ?? '').toString();
    final String date = (stock['date'] ?? '').toString();
    final double close = getStockNumber(stock, 'close');
    final double open = getStockNumber(stock, 'open');
    final double changePercent = getStockChangePercent(stock);
    final double changeAmount = getStockChangeAmount(stock);
    final bool isPositive = changePercent >= 0;
    final Color changeColor = AppTheme.changeColor(changePercent);

    final sparkline = generateDemoCandles(seed: symbol, range: '1M', base: close)
        .map((c) => c.close)
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.cardColor,
                      child: Text(
                        symbol.isNotEmpty ? symbol[0] : '?',
                        style: const TextStyle(fontSize: 22, color: AppTheme.textColor),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(name, style: AppTheme.screenTitle, textAlign: TextAlign.center),
                    const SizedBox(height: 2),
                    Text(symbol, style: AppTheme.captionText),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Price + sparkline card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$currency ${close.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                color: changeColor,
                              ),
                              Text(
                                '${isPositive ? '+' : ''}${changeAmount.toStringAsFixed(2)}  ${changePercent.toStringAsFixed(2)}%',
                                style: TextStyle(color: changeColor, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: SparklineChart(values: sparkline, color: changeColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Open / Close from JSON
              Row(
                children: [
                  Expanded(child: _StatColumn(label: 'Open', value: '$currency ${open.toStringAsFixed(2)}')),
                  Expanded(child: _StatColumn(label: 'Close', value: '$currency ${close.toStringAsFixed(2)}')),
                ],
              ),
              const SizedBox(height: 18),

              // Date from JSON
              _StatColumn(label: 'Date', value: date),
              const SizedBox(height: 22),

              // Historical price chart
              StockHistoryChart(symbol: symbol, lineColor: changeColor),
              const SizedBox(height: 18),

              Text(_marketCountdownText(), style: AppTheme.captionText),
              const SizedBox(height: 22),

              // Recent news section
              _StockNewsSection(companyName: name, newsFuture: _newsFuture),
              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    PortfolioService.buyStock(stock);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$symbol added to portfolio')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.positiveColor,
                    side: const BorderSide(color: AppTheme.positiveColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Buy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    final error = PortfolioService.sellStock(stock);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error ?? '$symbol sold from portfolio')),
                    );
                  },
                  child: const Text('Sell', style: TextStyle(color: AppTheme.negativeColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _marketCountdownText() {
    final now = DateTime.now().toUtc();
    DateTime nextOpen = DateTime.utc(now.year, now.month, now.day, 13, 30);
    if (now.isAfter(nextOpen)) {
      nextOpen = nextOpen.add(const Duration(days: 1));
    }
    final bool isOpenNow = now.hour >= 13 &&
        (now.hour > 13 || now.minute >= 30) &&
        now.hour < 20;

    if (isOpenNow) {
      return 'U.S. markets are open right now.';
    }

    final diff = nextOpen.difference(now);
    return 'U.S. markets open in ${diff.inHours} hours ${diff.inMinutes % 60} minutes';
  }
}

class _StockNewsSection extends StatelessWidget {
  final String companyName;
  final Future<List<NewsArticle>> newsFuture;

  const _StockNewsSection({
    required this.companyName,
    required this.newsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: FutureBuilder<List<NewsArticle>>(
        future: newsFuture,
        builder: (context, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent news for $companyName',
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (snapshot.connectionState == ConnectionState.waiting)
                const _NewsStatusText(message: 'Loading news...')
              else if (snapshot.hasError)
                const _NewsStatusText(message: 'Unable to load news right now.')
              else if (!snapshot.hasData || snapshot.data!.isEmpty)
                _NewsStatusText(message: 'No recent news found for $companyName.')
              else
                ...snapshot.data!.map((article) => _NewsHeadline(article: article)),
            ],
          );
        },
      ),
    );
  }
}

class _NewsHeadline extends StatelessWidget {
  final NewsArticle article;

  const _NewsHeadline({required this.article});

  Future<void> _open(BuildContext context) async {
    final Uri uri = Uri.parse(article.url);
    final bool opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open article')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardColorLighter,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                article.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
            if (article.imageUrl.isNotEmpty) ...[
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 52,
                  height: 52,
                  color: AppTheme.chipColor,
                  child: Image.network(
                    article.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported_outlined,
                      color: AppTheme.secondaryTextColor,
                    ),
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NewsStatusText extends StatelessWidget {
  final String message;

  const _NewsStatusText({required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
        color: AppTheme.textColor.withValues(alpha: 0.75),
        fontSize: 14,
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.captionText),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
