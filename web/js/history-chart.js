class HistoryChart {
  constructor(canvasId, historyService) {
    this.canvasId = canvasId;
    this.historyService = historyService;
    this.chart = null;
    this.currentPeriod = '1Y';
    this.currentData = [];
  }

  hexToRgba(hex, alpha) {
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    return `rgba(${r},${g},${b},${alpha})`;
  }

  async render(symbol, lineColor) {
    this.currentData = await this.historyService.fetchHistory(symbol, this.currentPeriod);

    if (this.currentData.length === 0) {
      console.warn('No data for chart');
      return;
    }

    const closes = this.currentData.map(d => d.close);
    const labels = this.currentData.map(d => d.date.substring(5)); // MM-DD format

    const ctx = document.getElementById(this.canvasId).getContext('2d');

    if (this.chart) this.chart.destroy();

    this.chart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          label: 'Close Price',
          data: closes,
          borderColor: lineColor,
          backgroundColor: this.hexToRgba(lineColor, 0.1),
          fill: true,
          tension: 0.4,
          borderWidth: 2,
          pointRadius: 0,
          pointHoverRadius: 6,
          pointBackgroundColor: lineColor,
          pointBorderColor: lineColor
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: {
          intersect: false,
          mode: 'index'
        },
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: 'rgba(0, 0, 0, 0.8)',
            padding: 12,
            titleColor: '#fff',
            bodyColor: '#fff',
            callbacks: {
              label: function(context) {
                return '€ ' + context.parsed.y.toFixed(2);
              }
            }
          }
        },
        scales: {
          y: {
            ticks: {
              color: '#9099B5',
              font: { size: 12 }
            },
            grid: { color: '#2C2F52', drawBorder: false },
            border: { display: false }
          },
          x: {
            ticks: {
              color: '#9099B5',
              maxTicksLimit: 5,
              font: { size: 11 }
            },
            grid: { display: false },
            border: { display: false }
          }
        }
      }
    });

    this.updateDateRange();
  }

  updateDateRange() {
    if (this.currentData.length === 0) return;

    const firstDate = this.currentData[0].date;
    const lastDate = this.currentData[this.currentData.length - 1].date;

    const dateFromEl = document.getElementById('chart-date-from');
    const dateToEl = document.getElementById('chart-date-to');

    if (dateFromEl) dateFromEl.textContent = firstDate;
    if (dateToEl) dateToEl.textContent = lastDate;
  }

  setPeriod(period) {
    this.currentPeriod = period;
  }
}
