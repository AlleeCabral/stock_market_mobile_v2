/**
 * ============================================
 * API SERVICE
 * Fetches stock data from Marketstack API
 * ============================================
 */

class ApiService {
  constructor(apiKey) {
    this.apiKey = apiKey;
    this.baseUrl = 'https://api.marketstack.com/v1';
    this.cache = {};
    this.cacheTTL = 10 * 60 * 1000; // 10 minutes
    this.cacheTime = {};

    // Default stock symbols (matching mobile app)
    this.defaultSymbols = [
      'NVDA',
      'AAPL',
      'MSFT',
      'AMZN',
      'GOOGL',
      'META',
      'AVGO',
      'TSLA',
      'BRK.B',
      'JPM',
      'V',
      'MA',
      'LLY',
      'JNJ',
      'ABBV',
      'WMT',
      'COST',
      'DIS',
      'NFLX',
      'XOM',
    ];
  }

  /**
   * Check if cached data is still fresh
   */
  isFresh(key) {
    const cached = this.cacheTime[key];
    if (!cached) return false;
    return Date.now() - cached < this.cacheTTL;
  }

  /**
   * Fetch latest stock data
   */
  async getStocks(symbols = null) {
    const symbolList = symbols || this.defaultSymbols;
    const cacheKey = 'stocks_' + symbolList.join(',');

    // Return cached if fresh
    if (this.isFresh(cacheKey) && this.cache[cacheKey]) {
      return this.cache[cacheKey];
    }

    try {
      const params = new URLSearchParams({
        symbols: symbolList.join(','),
        access_key: this.apiKey,
      });

      const response = await fetch(`${this.baseUrl}/eod/latest?${params}`);

      if (!response.ok) {
        throw new Error(`API error: ${response.status}`);
      }

      const data = await response.json();

      if (!data.data || !Array.isArray(data.data)) {
        throw new Error('Invalid API response');
      }

      // Parse stocks
      const stocks = data.data.map((item) => ({
        symbol: item.symbol || '',
        name: this.getStockName(item.symbol) || item.symbol || '',
        close: parseFloat(item.close) || 0,
        open: parseFloat(item.open) || 0,
        high: parseFloat(item.high) || 0,
        low: parseFloat(item.low) || 0,
        change: parseFloat(item.change) || 0,
        change_pct: parseFloat(item.change_pct) || 0,
        price_currency: item.price_currency || 'USD',
        date: item.date || new Date().toISOString().split('T')[0],
      }));

      // Cache results
      this.cache[cacheKey] = stocks;
      this.cacheTime[cacheKey] = Date.now();

      return stocks;
    } catch (error) {
      console.error('Error fetching stocks:', error);
      // Return fixture data as fallback
      return this.getFixtureData();
    }
  }

  /**
   * Fetch data for a single stock
   */
  async getStockDetail(symbol) {
    const cacheKey = `stock_${symbol}`;

    if (this.isFresh(cacheKey) && this.cache[cacheKey]) {
      return this.cache[cacheKey];
    }

    try {
      const params = new URLSearchParams({
        symbols: symbol,
        access_key: this.apiKey,
      });

      const response = await fetch(`${this.baseUrl}/eod/latest?${params}`);

      if (!response.ok) {
        throw new Error(`API error: ${response.status}`);
      }

      const data = await response.json();
      const stock = data.data?.[0];

      if (!stock) {
        throw new Error('No data for symbol');
      }

      const result = {
        symbol: stock.symbol || symbol,
        name: this.getStockName(symbol) || symbol,
        close: parseFloat(stock.close) || 0,
        open: parseFloat(stock.open) || 0,
        high: parseFloat(stock.high) || 0,
        low: parseFloat(stock.low) || 0,
        change: parseFloat(stock.change) || 0,
        change_pct: parseFloat(stock.change_pct) || 0,
        price_currency: stock.price_currency || 'USD',
        date: stock.date || new Date().toISOString().split('T')[0],
      };

      this.cache[cacheKey] = result;
      this.cacheTime[cacheKey] = Date.now();

      return result;
    } catch (error) {
      console.error(`Error fetching stock ${symbol}:`, error);
      throw error;
    }
  }

  /**
   * Get stock display name
   */
  getStockName(symbol) {
    const names = {
      NVDA: 'NVIDIA Corp.',
      AAPL: 'Apple Inc.',
      MSFT: 'Microsoft Corp.',
      AMZN: 'Amazon.com Inc.',
      GOOGL: 'Alphabet Inc.',
      META: 'Meta Platforms Inc.',
      AVGO: 'Broadcom Inc.',
      TSLA: 'Tesla Inc.',
      'BRK.B': 'Berkshire Hathaway Inc.',
      JPM: 'JPMorgan Chase & Co.',
      V: 'Visa Inc.',
      MA: 'Mastercard Inc.',
      LLY: 'Eli Lilly and Co.',
      JNJ: 'Johnson & Johnson',
      ABBV: 'AbbVie Inc.',
      WMT: 'Walmart Inc.',
      COST: 'Costco Wholesale Corp.',
      DIS: 'The Walt Disney Company',
      NFLX: 'Netflix Inc.',
      XOM: 'Exxon Mobil Corp.',
    };
    return names[symbol] || symbol;
  }

  /**
   * Get fixture/demo data (fallback)
   */
  getFixtureData() {
    return this.defaultSymbols.map((symbol) => ({
      symbol,
      name: this.getStockName(symbol),
      close: Math.random() * 500 + 50,
      open: Math.random() * 500 + 50,
      high: Math.random() * 500 + 60,
      low: Math.random() * 500 + 40,
      change: (Math.random() - 0.5) * 20,
      change_pct: (Math.random() - 0.5) * 5,
      price_currency: 'USD',
      date: new Date().toISOString().split('T')[0],
    }));
  }

  /**
   * Clear cache
   */
  clearCache() {
    this.cache = {};
    this.cacheTime = {};
  }
}

// Export for use
if (typeof module !== 'undefined' && module.exports) {
  module.exports = ApiService;
}
