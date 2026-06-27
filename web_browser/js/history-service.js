class HistoryService {
  constructor(apiKey) {
    this.apiKey = apiKey;
    this.baseUrl = 'https://api.marketstack.com/v1';
    this.cache = {};
  }

  getDateRange(period) {
    const now = new Date();
    const from = new Date();

    switch(period) {
      case '3M': from.setMonth(now.getMonth() - 3); break;
      case '6M': from.setMonth(now.getMonth() - 6); break;
      case '1Y': from.setFullYear(now.getFullYear() - 1); break;
    }

    return { from, to: now };
  }

  formatDate(date) {
    return date.toISOString().split('T')[0];
  }

  async fetchHistory(symbol, period = '1Y') {
    const cacheKey = `${symbol}_${period}`;
    if (this.cache[cacheKey]) return this.cache[cacheKey];

    try {
      const { from, to } = this.getDateRange(period);
      const params = new URLSearchParams({
        symbols: symbol,
        date_from: this.formatDate(from),
        date_to: this.formatDate(to),
        limit: '1000',
        access_key: this.apiKey
      });

      const response = await fetch(`${this.baseUrl}/eod?${params}`);
      const data = await response.json();

      if (data.data && Array.isArray(data.data)) {
        const points = data.data
          .map(item => ({
            date: item.date,
            close: parseFloat(item.close),
            open: parseFloat(item.open),
            high: parseFloat(item.high),
            low: parseFloat(item.low)
          }))
          .sort((a, b) => new Date(a.date) - new Date(b.date));

        this.cache[cacheKey] = points;
        return points;
      }
    } catch (error) {
      console.error('Error fetching history:', error);
    }

    return this.generateFixtureData(symbol, period);
  }

  generateFixtureData(symbol, period) {
    const points = [];
    const { from, to } = this.getDateRange(period);
    
    let current = new Date(from);
    let basePrice = 50 + Math.random() * 300;

    while (current <= to) {
      if (current.getDay() !== 0 && current.getDay() !== 6) { // Skip weekends
        const variation = (Math.random() - 0.5) * 5;
        const close = basePrice + variation;

        points.push({
          date: this.formatDate(current),
          close: parseFloat(close.toFixed(2)),
          open: parseFloat((close - (Math.random() - 0.5) * 2).toFixed(2)),
          high: parseFloat((close + Math.random() * 2).toFixed(2)),
          low: parseFloat((close - Math.random() * 2).toFixed(2))
        });

        basePrice = close;
      }

      current.setDate(current.getDate() + 1);
    }

    return points;
  }
}
