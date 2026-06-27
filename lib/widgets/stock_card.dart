import 'package:flutter/material.dart';

import '../helpers/stock_change_helper.dart';
import '../screens/stock_detail_screen.dart';
import '../services/stock_service.dart';
import '../theme/app_theme.dart';

/// A single row representing one stock: a colored "logo" circle with its
/// initial, the company name + ticker, and the price with a colored
/// up/down change pill — matching the list rows in the Figma designs.
class StockListTile extends StatelessWidget {
  final Map<String, dynamic> stock;

  const StockListTile({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final double changePercent = getStockChangePercent(stock);
    final bool isPositive = changePercent >= 0;
    final Color changeColor = AppTheme.changeColor(changePercent);
    final String symbol = (stock['symbol'] ?? '').toString();
    final String name = (stock['name'] ?? '').toString();

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.tileRadius),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StockDetailScreen(stock: stock)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: _colorForSymbol(symbol),
              child: Text(
                symbol.isNotEmpty ? symbol[0] : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(symbol, style: AppTheme.captionText),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${stock['price_currency'] ?? ''} ${getStockNumber(stock, 'close').toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.changeBg(changePercent),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${isPositive ? '↑' : '↓'} ${changePercent.abs().toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
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

  Color _colorForSymbol(String symbol) {
    const palette = [
      Color(0xFF4F8EF7),
      Color(0xFFF77F4F),
      Color(0xFF34C77B),
      Color(0xFFC74FE0),
      Color(0xFFF7C04F),
      Color(0xFF4FD3F7),
    ];
    final int index = symbol.isEmpty ? 0 : symbol.codeUnitAt(0) % palette.length;
    return palette[index];
  }
}

/// Renders the "Stocks to explore" list.
///
/// When [items] is provided (e.g. from a search-filtered list), those are
/// rendered directly — no async loading needed.
///
/// When [items] is null, fetches live data from [StockService] and falls back
/// to fixture data when the API is unavailable or in dev mode.
///
/// This widget is intentionally *not* wrapped in its own scroll view so it
/// can live inside an already-scrollable parent (SingleChildScrollView).
class StockCard extends StatefulWidget {
  final int? limit;
  final List<Map<String, dynamic>>? items;

  const StockCard({super.key, this.limit, this.items});

  @override
  State<StockCard> createState() => _StockCardState();
}

class _StockCardState extends State<StockCard> {
  final StockService _stockService = StockService();
  Future<List<Map<String, dynamic>>>? _stocksFuture;

  @override
  void initState() {
    super.initState();
    // Only set up the async fetch when no items are supplied externally.
    if (widget.items == null) {
      _stocksFuture = _fetchStocks();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchStocks({bool forceRefresh = false}) async {
    final stocks = await _stockService.fetchLatestStocks(forceRefresh: forceRefresh);
    return stocks.map((s) => s.toMap()).toList();
  }

  void _refresh() {
    setState(() {
      _stocksFuture = _fetchStocks(forceRefresh: true);
    });
  }

  Widget _buildList(List<Map<String, dynamic>> source) {
    final visible = widget.limit != null ? source.take(widget.limit!).toList() : source;

    if (visible.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('No stocks match your search.', style: AppTheme.captionText),
        ),
      );
    }

    return Column(
      children: [
        for (final stock in visible) StockListTile(stock: stock),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // If items are passed in (e.g. search-filtered), render them synchronously.
    if (widget.items != null) {
      return _buildList(widget.items!);
    }

    // Otherwise, load from StockService (live API with fixture fallback).
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _stocksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          final message = snapshot.error?.toString() ?? 'Unknown error';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Could not load stocks.',
                  style: TextStyle(color: AppTheme.textColor),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _refresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return _buildList(snapshot.data ?? []);
      },
    );
  }
}
