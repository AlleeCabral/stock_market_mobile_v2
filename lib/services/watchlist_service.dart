import 'package:flutter/material.dart';

/// Tracks which stock symbols the user has starred via "+ Add to Watchlist"
/// on the stock detail page. Kept in memory for the session, mirroring how
/// PortfolioService stores holdings — a real backend/local database can
/// replace this later without the UI needing to change.
class WatchlistService {
  static ValueNotifier<Set<String>> symbols = ValueNotifier<Set<String>>({});

  static bool isWatched(String symbol) => symbols.value.contains(symbol);

  static void toggle(String symbol) {
    final updated = Set<String>.from(symbols.value);
    if (updated.contains(symbol)) {
      updated.remove(symbol);
    } else {
      updated.add(symbol);
    }
    symbols.value = updated;
  }
}
