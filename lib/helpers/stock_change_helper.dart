import 'package:flutter/material.dart';
double getStockNumber(Map<String, dynamic> stock, String key) {
  final value = stock[key];

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString()) ?? 0;
}

double getStockChangeAmount(Map<String, dynamic> stock) {
  final open = getStockNumber(stock, 'open');
  final close = getStockNumber(stock, 'close');

  return close - open;
}

double getStockChangePercent(Map<String, dynamic> stock) {
  final open = getStockNumber(stock, 'open');
  final close = getStockNumber(stock, 'close');

  if (open == 0) {
    return 0;
  }

  return ((close - open) / open) * 100;
}

bool isStockPositive(Map<String, dynamic> stock) {
  return getStockChangeAmount(stock) >= 0;
}

Color getStockChangeColor(Map<String, dynamic> stock) {
  return isStockPositive(stock) ? Colors.green : Colors.red;
}