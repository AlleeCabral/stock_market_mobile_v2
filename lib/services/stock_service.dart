import '../data/stock_data.dart';
import '../models/stock.dart';
import 'api_service.dart';

class StockService {
	// Symbols to fetch and their display names.
	// Marketstack eod/latest does not return a name field, so we keep a
	// lightweight map here. Add or remove entries to change the tracked list.
	static const Map<String, String> _stockNames = {
		'NVDA': 'NVIDIA Corp.',
		'AAPL': 'Apple Inc.',
		'MSFT': 'Microsoft Corp.',
		'AMZN': 'Amazon.com Inc.',
		'GOOGL': 'Alphabet Inc.',
		'META': 'Meta Platforms Inc.',
		'AVGO': 'Broadcom Inc.',
		'TSLA': 'Tesla Inc.',
		'BRK.B': 'Berkshire Hathaway Inc.',
		'JPM': 'JPMorgan Chase & Co.',
		'V': 'Visa Inc.',
		'MA': 'Mastercard Inc.',
		'LLY': 'Eli Lilly and Co.',
		'JNJ': 'Johnson & Johnson',
		'ABBV': 'AbbVie Inc.',
		'WMT': 'Walmart Inc.',
		'COST': 'Costco Wholesale Corp.',
		'DIS': 'The Walt Disney Company',
		'NFLX': 'Netflix Inc.',
		'XOM': 'Exxon Mobil Corp.',
	};

	static List<String> get defaultSymbols => _stockNames.keys.toList();

	List<Stock> get fixtureStocks =>
			stocks.map((item) => Stock.fromFixtureMap(item)).toList();

	// Use StockService() without arguments to share cache/throttling globally.
	StockService._internal({
		ApiService? apiService,
		Duration? cacheTtl,
		Duration? listApiMinInterval,
		Duration? detailApiMinInterval,
		int? monthlyApiBudget,
	})	: _apiService = apiService ?? ApiService(),
		_cacheTtl = cacheTtl ?? const Duration(minutes: 10),
		_listApiMinInterval = listApiMinInterval ?? const Duration(hours: 6),
		_detailApiMinInterval = detailApiMinInterval ?? const Duration(minutes: 30),
		_monthlyApiBudget = monthlyApiBudget ?? 100;

	static final StockService instance = StockService._internal();

	factory StockService({
		ApiService? apiService,
		Duration? cacheTtl,
		Duration? listApiMinInterval,
		Duration? detailApiMinInterval,
		int? monthlyApiBudget,
	}) {
		final hasCustomConfig =
				apiService != null ||
				cacheTtl != null ||
				listApiMinInterval != null ||
				detailApiMinInterval != null ||
				monthlyApiBudget != null;

		if (!hasCustomConfig) return instance;

		return StockService._internal(
			apiService: apiService,
			cacheTtl: cacheTtl,
			listApiMinInterval: listApiMinInterval,
			detailApiMinInterval: detailApiMinInterval,
			monthlyApiBudget: monthlyApiBudget,
		);
	}

	final ApiService _apiService;
	final Duration _cacheTtl;
	final Duration _listApiMinInterval;
	final Duration _detailApiMinInterval;
	final int _monthlyApiBudget;

	List<Stock>? _cachedStocks;
	DateTime? _cachedStocksAt;
	DateTime? _lastListApiCallAt;
	int _usedApiCallsThisMonth = 0;
	DateTime _usageMonthMarker = DateTime.now();

	final Map<String, Stock> _cachedDetailsBySymbol = {};
	final Map<String, DateTime> _cachedDetailsAtBySymbol = {};
	final Map<String, DateTime> _lastDetailApiCallAtBySymbol = {};

	/// Fetches the latest end-of-day prices for all tracked symbols from
	/// Marketstack. Results are cached for [_cacheTtl] and API calls are
	/// throttled to [_listApiMinInterval] to stay within free-tier limits.
	Future<List<Stock>> fetchLatestStocks({
		List<String>? symbols,
		bool forceRefresh = false,
	}) async {
		if (!forceRefresh && _cachedStocks != null && _isFresh(_cachedStocksAt)) {
			return _cachedStocks!;
		}

		final symbolList = (symbols == null || symbols.isEmpty)
				? defaultSymbols
				: symbols;

		if (!_tryConsumeBudget(symbolList.length)) {
			final cached = _cachedStocks;
			if (cached != null && cached.isNotEmpty) return cached;
			throw Exception('Monthly Marketstack budget reached for stock list requests.');
		}

		final shouldThrottle =
				!forceRefresh && _isWithinMinInterval(_lastListApiCallAt, _listApiMinInterval);
		if (shouldThrottle) {
			final cached = _cachedStocks;
			if (cached != null && cached.isNotEmpty) return cached;
			throw Exception('Stock list refresh is temporarily throttled. Try again later.');
		}

		try {
			final response = await _apiService.get(
				'eod/latest',
				queryParameters: {'symbols': symbolList.join(',')},
			);

			final data = (response['data'] as List<dynamic>? ?? [])
					.whereType<Map<String, dynamic>>()
					.toList();

			if (data.isEmpty) {
				throw Exception('Marketstack returned no stock data for the requested symbols.');
			}

			final parsed = data.map((item) {
				final symbol = (item['symbol'] ?? '').toString();
				return Stock.fromMarketstackJson(item, name: _stockNames[symbol]);
			}).toList();

			_lastListApiCallAt = DateTime.now();
			_setStocksCache(parsed);
			return parsed;
		} on MarketstackApiException {
			final fallback = fixtureStocks;
			_setStocksCache(fallback);
			return fallback;
		} catch (error) {
			final fallback = fixtureStocks;
			_setStocksCache(fallback);
			return fallback;
		}
	}

	/// Fetches the latest data for a single [symbol] from Marketstack.
	Future<Stock> fetchStockBySymbol(
		String symbol, {
		bool forceRefresh = false,
	}) async {
		if (symbol.isEmpty) throw Exception('Cannot fetch stock details without a symbol.');

		if (!forceRefresh &&
				_cachedDetailsBySymbol.containsKey(symbol) &&
				_isFresh(_cachedDetailsAtBySymbol[symbol])) {
			return _cachedDetailsBySymbol[symbol]!;
		}

		if (!_tryConsumeBudget(1)) {
			final cached = _cachedDetailsBySymbol[symbol];
			if (cached != null) return cached;
			throw Exception('Monthly API budget reached for stock detail requests.');
		}

		final lastCall = _lastDetailApiCallAtBySymbol[symbol];
		final shouldThrottle =
				!forceRefresh && _isWithinMinInterval(lastCall, _detailApiMinInterval);
		if (shouldThrottle) {
			final cached = _cachedDetailsBySymbol[symbol];
			if (cached != null) return cached;
			throw Exception('Stock detail refresh is temporarily throttled. Try again later.');
		}

		try {
			final response = await _apiService.get(
				'eod/latest',
				queryParameters: {'symbols': symbol},
			);

			final data = (response['data'] as List<dynamic>? ?? [])
					.whereType<Map<String, dynamic>>()
					.toList();

			if (data.isEmpty) {
				throw Exception('No stock data returned for $symbol.');
			}

			final parsed = Stock.fromMarketstackJson(
				data.first,
				name: _stockNames[symbol],
			);
			_lastDetailApiCallAtBySymbol[symbol] = DateTime.now();
			_setDetailCache(parsed);
			return parsed;
		} on MarketstackApiException {
			final fallbackStock = fixtureStocks.where((s) => s.symbol == symbol).firstOrNull;
			if (fallbackStock != null) {
				_setDetailCache(fallbackStock);
				return fallbackStock;
			}
			throw Exception('API unavailable and no local data found for symbol: $symbol');
		} catch (error) {
			final fallbackStock = fixtureStocks.where((s) => s.symbol == symbol).firstOrNull;
			if (fallbackStock != null) {
				_setDetailCache(fallbackStock);
				return fallbackStock;
			}
			throw Exception('API unavailable and no local data found for symbol: $symbol');
		}
	}

	bool _isFresh(DateTime? timestamp) {
		if (timestamp == null) return false;
		return DateTime.now().difference(timestamp) < _cacheTtl;
	}

	bool _isWithinMinInterval(DateTime? timestamp, Duration minInterval) {
		if (timestamp == null) return false;
		return DateTime.now().difference(timestamp) < minInterval;
	}

	bool _tryConsumeBudget(int calls) {
		if (calls <= 0) return true;
		final now = DateTime.now();
		if (now.year != _usageMonthMarker.year || now.month != _usageMonthMarker.month) {
			_usedApiCallsThisMonth = 0;
			_usageMonthMarker = now;
		}
		if ((_usedApiCallsThisMonth + calls) > _monthlyApiBudget) return false;
		_usedApiCallsThisMonth += calls;
		return true;
	}

	void _setStocksCache(List<Stock> value) {
		_cachedStocks = value;
		_cachedStocksAt = DateTime.now();
		for (final stock in value) {
			_setDetailCache(stock);
		}
	}

	void _setDetailCache(Stock value) {
		_cachedDetailsBySymbol[value.symbol] = value;
		_cachedDetailsAtBySymbol[value.symbol] = DateTime.now();
	}
}

extension _FirstWhereOrNull<T> on Iterable<T> {
	T? get firstOrNull => isEmpty ? null : first;
}
