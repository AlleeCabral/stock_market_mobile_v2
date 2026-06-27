class SearchEngine {
  constructor(stocks = []) {
    this.stocks = stocks;
  }

  search(query) {
    if (!query.trim()) return this.stocks;
    
    const lower = query.toLowerCase();
    return this.stocks.filter(stock =>
      stock.symbol.toLowerCase().includes(lower) ||
      stock.name.toLowerCase().includes(lower)
    );
  }
}
