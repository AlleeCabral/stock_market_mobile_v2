/**
 * ============================================
 * SEARCH ENGINE
 * Filters stocks by company name or ticker
 * ============================================
 */

class SearchEngine {
  constructor(stocks = []) {
    this.stocks = stocks;
  }

  /**
   * Search stocks by query (name or symbol)
   */
  search(query) {
    if (!query || query.trim() === '') {
      return this.stocks;
    }

    const lower = query.toLowerCase();
    return this.stocks.filter(
      (stock) =>
        stock.name.toLowerCase().includes(lower) ||
        stock.symbol.toLowerCase().includes(lower)
    );
  }

  /**
   * Update stocks list
   */
  setStocks(stocks) {
    this.stocks = stocks;
  }
}

// Export for use
if (typeof module !== 'undefined' && module.exports) {
  module.exports = SearchEngine;
}
