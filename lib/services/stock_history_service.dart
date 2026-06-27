import '../models/ohlc_data_point.dart';
import 'api_service.dart';

/// Fetches historical end-of-day price data for a single stock symbol
/// using the Marketstack v2 EOD endpoint.
///
/// Keeps its own simple in-memory cache so switching between the
/// 3M / 6M / 1Y tabs doesn't hammer the API.
class StockHistoryService {
  StockHistoryService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  // Cache: "AAPL_1Y" → list of data points
  final Map<String, List<OhlcDataPoint>> _cache = {};

  static String _formatDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime _dateFrom(HistoryRange range) {
    final now = DateTime.now();
    return switch (range) {
      HistoryRange.threeMonths => DateTime(now.year, now.month - 3, now.day),
      HistoryRange.sixMonths   => DateTime(now.year, now.month - 6, now.day),
      HistoryRange.oneYear     => DateTime(now.year - 1, now.month, now.day),
    };
  }

  Future<List<OhlcDataPoint>> fetchHistory(
    String symbol,
    HistoryRange range,
  ) async {
    final cacheKey = '${symbol}_${range.name}';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    final now = DateTime.now();
    final from = _dateFrom(range);

    final response = await _apiService.getV2(
      'eod',
      queryParameters: {
        'symbols': symbol,
        'date_from': _formatDate(from),
        'date_to': _formatDate(now),
        'limit': '1000',
      },
    );

    final List raw = (response['data'] as List?) ?? [];
    final points = raw
        .whereType<Map<String, dynamic>>()
        .map(OhlcDataPoint.fromJson)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // oldest → newest

    _cache[cacheKey] = points;
    return points;
  }
}

enum HistoryRange { threeMonths, sixMonths, oneYear }

extension HistoryRangeLabel on HistoryRange {
  String get label => switch (this) {
    HistoryRange.threeMonths => '3M',
    HistoryRange.sixMonths   => '6M',
    HistoryRange.oneYear     => '1Y',
  };
}
