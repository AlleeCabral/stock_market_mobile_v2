/**
 * ============================================
 * HISTORY SERVICE
 * Fetches historical price data for charts
 * ============================================
 */

class HistoryService {
  constructor(apiKey) {
    this.apiKey = apiKey;
    this.baseUrl = 'https://api.marketstack.com/v1';
    this.cache = {};
  }

  /**
   * Calculate date range based on period
   */
  getDateRange(period) {
    const now = new Date();
    const from = new Date();

    switch (period) {
      case '3M':
        from.setMonth(now.getMonth() - 3);
        break;
      case '6M':
        from.setMonth(now.getMonth() - 6);
        break;
      case '1Y':
        from.setFullYear(now.getFullYear() - 1);
        break;
      default:
        from.setFullYear(now.getFullYear() - 1);
    }

    return { from, to: now };
  }

  /**
   * Format date as YYYY-MM-DD
   */
  formatDate(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  /**
   * Fetch historical data for a symbol and period
   */
  async fetchHistory(symbol, period = '1Y') {
    const cacheKey = `${symbol}_${period}`;

    // Return cached if available
    if (this.cache[cacheKey]) {
      return this.cache[cacheKey];
    }

    try {
      const { from, to } = this.getDateRange(period);

      const params = new URLSearchParams({
        symbols: symbol,
        date_from: this.formatDate(from),
        date_to: this.formatDate(to),
        limit: '1000',
        access_key: this.apiKey,
      });

      const response = await fetch(`${this.baseUrl}/eod?${params}`);

      if (!response.ok) {
        throw new Error(`API error: ${response.status}`);
      }

      const data = await response.json();

      if (!data.data || !Array.isArray(data.data)) {
        throw new Error('Invalid API response');
      }

      // Parse historical data
      const points = data.data
        .map((item) => ({
          date: item.date,
          open: parseFloat(item.open) || 0,
          high: parseFloat(item.high) || 0,
          low: parseFloat(item.low) || 0,
          close: parseFloat(item.close) || 0,
          volume: parseInt(item.volume) || 0,
        }))
        .sort((a, b) => new Date(a.date) - new Date(b.date)); // oldest to newest

      // Cache results
      this.cache[cacheKey] = points;

      return points;
    } catch (error) {
      console.error(
        `Error fetching history for ${symbol} (${period}):`,
        error
      );
      // Return generated fixture data
      return this.generateFixtureData(period);
    }
  }

  /**
   * Generate fixture data for fallback
   */
  generateFixtureData(period) {
    const { from, to } = this.getDateRange(period);
    const points = [];
    const basePrice = 150;
    const variance = 0.02; // 2% daily variance

    let currentDate = new Date(from);
    let currentPrice = basePrice;

    while (currentDate < to) {
      // Skip weekends
      if (currentDate.getDay() !== 0 && currentDate.getDay() !== 6) {
        const change = (Math.random() - 0.5) * variance * currentPrice;
        currentPrice += change;

        points.push({
          date: this.formatDate(currentDate),
          open: currentPrice * (1 - Math.random() * 0.01),
          high: currentPrice * (1 + Math.random() * 0.02),
          low: currentPrice * (1 - Math.random() * 0.02),
          close: currentPrice,
          volume: Math.floor(Math.random() * 50000000 + 10000000),
        });
      }

      currentDate.setDate(currentDate.getDate() + 1);
    }

    return points;
  }

  /**
   * Clear cache
   */
  clearCache() {
    this.cache = {};
  }
}

// Export for use
if (typeof module !== 'undefined' && module.exports) {
  module.exports = HistoryService;
}
