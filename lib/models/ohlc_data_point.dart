class OhlcDataPoint {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;

  const OhlcDataPoint({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  factory OhlcDataPoint.fromJson(Map<String, dynamic> json) {
    return OhlcDataPoint(
      // Marketstack returns "2025-01-15T00:00:00+0000" — take only the date part.
      date: DateTime.parse(json['date'].toString().substring(0, 10)),
      open: (json['open'] as num?)?.toDouble() ?? 0,
      high: (json['high'] as num?)?.toDouble() ?? 0,
      low: (json['low'] as num?)?.toDouble() ?? 0,
      close: (json['close'] as num?)?.toDouble() ?? 0,
    );
  }
}
