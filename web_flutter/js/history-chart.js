/**
 * ============================================
 * HISTORY CHART
 * Renders historical charts using Chart.js
 * ============================================
 */

class HistoryChart {
  constructor(canvasId, historyService) {
    this.canvasId = canvasId;
    this.historyService = historyService;
    this.chart = null;
    this.currentPeriod = '1Y';
  }

  /**
   * Render chart with data
   */
  async render(symbol, lineColor) {
    try {
      const data = await this.historyService.fetchHistory(
        symbol,
        this.currentPeriod
      );

      if (!data || data.length === 0) {
        this.showError('No data available');
        return;
      }

      const closes = data.map((d) => d.close);
      const labels = data.map((d) => {
        // Format date as MM-DD for labels
        const date = new Date(d.date);
        return `${date.getMonth() + 1}/${date.getDate()}`;
      });

      const ctx = document.getElementById(this.canvasId);
      if (!ctx) {
        console.error('Canvas not found:', this.canvasId);
        return;
      }

      // Destroy existing chart if any
      if (this.chart) {
        this.chart.destroy();
      }

      // Create gradient
      const gradient = ctx.getContext('2d').createLinearGradient(0, 0, 0, 200);
      gradient.addColorStop(0, this.hexToRgba(lineColor, 0.2));
      gradient.addColorStop(1, this.hexToRgba(lineColor, 0));

      // Create new chart
      this.chart = new Chart(ctx, {
        type: 'line',
        data: {
          labels: labels,
          datasets: [
            {
              label: 'Close Price',
              data: closes,
              borderColor: lineColor,
              backgroundColor: gradient,
              fill: true,
              tension: 0.4,
              borderWidth: 2,
              pointRadius: 0,
              pointHoverRadius: 6,
              pointBackgroundColor: lineColor,
              pointBorderColor: lineColor,
              segment: {
                borderColor: (ctx) => {
                  if (
                    ctx.p1DataIndex !== undefined &&
                    ctx.p2DataIndex !== undefined
                  ) {
                    return closes[ctx.p1DataIndex] <=
                      closes[ctx.p2DataIndex]
                      ? lineColor
                      : lineColor;
                  }
                  return lineColor;
                },
              },
            },
          ],
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          interaction: {
            intersect: false,
            mode: 'index',
          },
          plugins: {
            legend: {
              display: false,
            },
            tooltip: {
              backgroundColor: '#1E2140',
              titleColor: '#FFFFFF',
              bodyColor: '#FFFFFF',
              borderColor: '#2C2F52',
              borderWidth: 1,
              padding: 8,
              titleFont: { weight: 'bold' },
              bodyFont: { size: 12 },
              callbacks: {
                label: (context) => {
                  return `$${context.parsed.y.toFixed(2)}`;
                },
              },
            },
          },
          scales: {
            y: {
              display: true,
              position: 'right',
              ticks: {
                color: '#9099B5',
                font: { size: 10 },
                maxTicksLimit: 5,
                callback: (value) => `$${value.toFixed(0)}`,
              },
              grid: {
                color: '#2C2F52',
                drawBorder: false,
              },
            },
            x: {
              display: true,
              ticks: {
                color: '#9099B5',
                font: { size: 10 },
                maxTicksLimit: 5,
              },
              grid: {
                display: false,
                drawBorder: false,
              },
            },
          },
        },
      });

      // Update date range display
      this.updateDateRange(data);
    } catch (error) {
      console.error('Error rendering chart:', error);
      this.showError('Failed to load chart data');
    }
  }

  /**
   * Update the date range display
   */
  updateDateRange(data) {
    const dateFromEl = document.getElementById('chart-date-from');
    const dateToEl = document.getElementById('chart-date-to');

    if (data && data.length > 0) {
      const first = new Date(data[0].date);
      const last = new Date(data[data.length - 1].date);

      const formatter = new Intl.DateTimeFormat('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
      });

      if (dateFromEl) dateFromEl.textContent = formatter.format(first);
      if (dateToEl) dateToEl.textContent = formatter.format(last);
    }
  }

  /**
   * Set the period and trigger re-render
   */
  setPeriod(period) {
    if (period === this.currentPeriod) return;
    this.currentPeriod = period;
  }

  /**
   * Convert hex color to rgba
   */
  hexToRgba(hex, alpha) {
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    return `rgba(${r},${g},${b},${alpha})`;
  }

  /**
   * Show error message
   */
  showError(message) {
    const container = document.getElementById(this.canvasId);
    if (container) {
      container.innerHTML = `<div style="display: flex; align-items: center; justify-content: center; height: 100%; color: #FF4D5E;">${message}</div>`;
    }
  }
}

// Export for use
if (typeof module !== 'undefined' && module.exports) {
  module.exports = HistoryChart;
}
