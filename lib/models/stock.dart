class Stock {
	final String name;
	final String symbol;
	final double open;
	final double close;
	final String priceCurrency;
	final String date;
	final String? exchange;

	const Stock({
		required this.name,
		required this.symbol,
		required this.open,
		required this.close,
		required this.priceCurrency,
		required this.date,
		this.exchange,
	});

	factory Stock.fromFixtureMap(Map<String, dynamic> json) {
		// Fixture contract used by lib/data/stock_data.dart and fallback flows.
		return Stock(
			name: (json['name'] ?? '').toString(),
			symbol: (json['symbol'] ?? '').toString(),
			open: _asDouble(json['open']),
			close: _asDouble(json['close']),
			priceCurrency: (json['price_currency'] ?? '').toString(),
			date: (json['date'] ?? '').toString(),
			exchange: json['exchange']?.toString(),
		);
	}

	factory Stock.fromMarketstackJson(Map<String, dynamic> json, {String? name}) {
		// Marketstack eod/latest returns symbol, open, close, date, exchange.
		// Name is enriched from fixture data when available.
		final symbol = (json['symbol'] ?? '').toString();

		return Stock(
			name: (name != null && name.isNotEmpty) ? name : symbol,
			symbol: symbol,
			open: _asDouble(json['open']),
			close: _asDouble(json['close']),
			priceCurrency: _inferCurrencyFromSymbol(symbol),
			date: (json['date'] ?? '').toString(),
			exchange: json['exchange']?.toString(),
		);
	}

	Map<String, dynamic> toMap() {
		return {
			'name': name,
			'symbol': symbol,
			'open': open,
			'close': close,
			'price_currency': priceCurrency,
			'date': date,
			'exchange': exchange,
		};
	}

	static double _asDouble(dynamic value) {
		if (value is num) {
			return value.toDouble();
		}

		return double.tryParse(value?.toString() ?? '') ?? 0.0;
	}

	static String _inferCurrencyFromSymbol(String symbol) {
		// Free Marketstack responses do not include explicit currency per symbol.
		// We infer a display currency from common exchange suffixes.
		if (symbol.endsWith('.T')) return 'JPY';
		if (symbol.endsWith('.PA')) return 'EUR';
		if (symbol.endsWith('.KS')) return 'KRW';
		if (symbol.endsWith('.SW')) return 'CHF';
		if (symbol.endsWith('.L')) return 'GBP';
		if (symbol.endsWith('.HK')) return 'HKD';
		return 'USD';
	}
}
