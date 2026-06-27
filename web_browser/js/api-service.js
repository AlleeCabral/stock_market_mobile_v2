class ApiService {
  constructor(apiKey) {
    this.apiKey = apiKey;
    this.baseUrl = 'https://api.marketstack.com/v1';
    this.cache = {};
    this.cacheTTL = 10 * 60 * 1000; // 10 minutes
    this.symbols = [
      'NVDA', 'AAPL', 'MSFT', 'AMZN', 'GOOGL', 'META', 'AVGO', 'TSLA', 
      'BRK.B', 'JPM', 'V', 'MA', 'LLY', 'JNJ', 'ABBV', 'WMT', 
      'COST', 'DIS', 'NFLX', 'XOM'
    ];
  }

  isFresh(key) {
    if (!this.cache[key]) return false;
    return Date.now() - this.cache[key].timestamp < this.cacheTTL;
  }

  async getStocks() {
    if (this.isFresh('stocks')) {
      return this.cache['stocks'].data;
    }

    try {
      const symbolsStr = this.symbols.join(',');
      const params = new URLSearchParams({
        symbols: symbolsStr,
        access_key: this.apiKey,
        limit: this.symbols.length
      });

      const response = await fetch(`${this.baseUrl}/eod/latest?${params}`);
      const json = await response.json();

      if (json.data && Array.isArray(json.data)) {
        const stocks = json.data.map(item => ({
          symbol: item.symbol,
          name: item.name || item.symbol,
          close: parseFloat(item.close).toFixed(2),
          open: parseFloat(item.open).toFixed(2),
          high: parseFloat(item.high).toFixed(2),
          low: parseFloat(item.low).toFixed(2),
          change: parseFloat((item.close - item.open).toFixed(2)),
          change_pct: parseFloat(item.change_pct).toFixed(2)
        }));

        this.cache['stocks'] = { data: stocks, timestamp: Date.now() };
        return stocks;
      }
    } catch (error) {
      console.error('Error fetching stocks:', error);
    }

    return this.getFixtureStocks();
  }

  getFixtureStocks() {
    return this.symbols.map(symbol => {
      const basePrice = 50 + Math.random() * 300;
      const change = (Math.random() - 0.5) * 20;
      return {
        symbol: symbol,
        name: symbol,
        close: basePrice.toFixed(2),
        open: (basePrice - change).toFixed(2),
        high: (basePrice + Math.random() * 10).toFixed(2),
        low: (basePrice - Math.random() * 10).toFixed(2),
        change: change.toFixed(2),
        change_pct: ((change / basePrice) * 100).toFixed(2)
      };
    });
  }

  async getStockDetail(symbol) {
    const stocks = await this.getStocks();
    return stocks.find(s => s.symbol === symbol) || stocks[0];
  }
}
