import 'package:flutter/material.dart';

import '../helpers/stock_change_helper.dart';
import '../models/portfolio_holding.dart';

class PortfolioService {
  static ValueNotifier<List<PortfolioHolding>> holdings = ValueNotifier([]);

  static void buyStock(Map<String, dynamic> stock) {
    final symbol = stock['symbol'];

    final index = holdings.value.indexWhere(
          (holding) => holding.symbol == symbol,
    );

    if (index != -1) {
      holdings.value[index].quantity++;
      holdings.value = List.from(holdings.value);
      return;
    }

    final newHolding = PortfolioHolding(
      name: stock['name'],
      symbol: stock['symbol'],
      currency: stock['price_currency'],
      price: getStockNumber(stock, 'close'),
      change: getStockChangePercent(stock),
      quantity: 1,
    );

    holdings.value = [
      ...holdings.value,
      newHolding,
    ];
  }

  static String? sellStock(Map<String, dynamic> stock) {
    final symbol = stock['symbol'];

    final index = holdings.value.indexWhere(
          (holding) => holding.symbol == symbol,
    );

    if (index == -1) {
      return 'You do not own this stock.';
    }

    holdings.value[index].quantity--;

    if (holdings.value[index].quantity <= 0) {
      holdings.value.removeAt(index);
    }

    holdings.value = List.from(holdings.value);
    return null;
  }

  static double totalValue() {
    double total = 0;

    for (final holding in holdings.value) {
      total += holding.totalValue;
    }

    return total;
  }

  /// Sum of the (positive) value contribution of every holding that is
  /// currently up, in the holding's own currency-less double value.
  static double totalGain() {
    double gain = 0;

    for (final holding in holdings.value) {
      if (holding.change > 0) {
        gain += holding.totalValue * (holding.change / 100);
      }
    }

    return gain;
  }

  /// Sum of the (absolute) value lost across every holding that is
  /// currently down.
  static double totalLoss() {
    double loss = 0;

    for (final holding in holdings.value) {
      if (holding.change < 0) {
        loss += holding.totalValue * (holding.change.abs() / 100);
      }
    }

    return loss;
  }

  /// Value-weighted average percent change across the whole portfolio.
  /// Returns 0 when the portfolio is empty.
  static double totalChangePercent() {
    final double total = totalValue();
    if (total == 0) return 0;

    double weighted = 0;
    for (final holding in holdings.value) {
      weighted += holding.totalValue * holding.change;
    }

    return weighted / total;
  }
}