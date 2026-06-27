# Stock Market Web App

A responsive web application for real-time stock tracking with portfolio management, built with vanilla HTML5, CSS3, and JavaScript.

## Features

✅ **Real-time Stock Data** - Powered by Marketstack API
✅ **Search by Company/Ticker** - Real-time filtering on Explore page
✅ **Historical Charts** - Line charts with 3M/6M/1Y period selectors
✅ **Portfolio Management** - Add/remove stocks and track holdings
✅ **Responsive Design** - Mobile, tablet, and desktop optimized
✅ **Dark Mode Theme** - Matches mobile app design exactly
✅ **LocalStorage Persistence** - Portfolio saves across sessions

## Pages

1. **Home** - Dashboard with featured stocks and quick actions
2. **Explore** - Stock list with real-time search (by symbol or company name)
3. **Stock Detail** - Historical price charts with period filters (3M/6M/1Y)
4. **Portfolio** - Track your holdings and portfolio value
5. **Premium** - Upgrade options (demo only)

## Architecture

### JavaScript Modules

- **api-service.js** - Marketstack API client with 10-minute caching
- **search-engine.js** - Real-time search filter (symbol + name)
- **history-service.js** - Historical data fetcher for 3M/6M/1Y periods
- **history-chart.js** - Chart.js wrapper with gradient fills
- **main.js** - App initialization, SPA routing, portfolio management

### Styling

- **theme.css** - Design tokens and component styles (matches mobile app)
- **responsive.css** - Mobile-first responsive breakpoints (576px, 992px)

## Getting Started

### Local Development

```bash
cd web_browser/
python3 -m http.server 8000
# or: php -S localhost:8000
```

Visit `http://localhost:8000` in your browser.

### API Keys

The app uses these keys from the mobile app config:
- **Marketstack**: `3ddb062d21ac3eb2da536681d7afc0ef`
- **NewsData.io**: `pub_f63e015c14ae4c019531dddf1771fc23`

### Default Stocks

20 default stocks are tracked: NVDA, AAPL, MSFT, AMZN, GOOGL, META, AVGO, TSLA, BRK.B, JPM, V, MA, LLY, JNJ, ABBV, WMT, COST, DIS, NFLX, XOM

## Testing Checklist

- [ ] Search filters stocks by symbol (case-insensitive)
- [ ] Search filters stocks by company name (case-insensitive)
- [ ] Period buttons on detail page (3M/6M/1Y visible)
- [ ] Clicking period button updates chart with new data
- [ ] Chart displays historical prices with gradient fill
- [ ] Date range updates with period selection
- [ ] Buy button adds stock to portfolio
- [ ] Portfolio shows all holdings with total value
- [ ] Remove button deletes from portfolio
- [ ] Portfolio persists after page reload
- [ ] Design matches mobile app (colors, spacing, typography)
- [ ] Responsive on mobile (<576px), tablet (576-992px), desktop (>992px)

## Styling Notes

All colors and spacing follow the mobile app exactly:

```css
--bg-primary: #13152B;      /* Main background */
--bg-card: #1E2140;         /* Card background */
--text-primary: #FFFFFF;    /* Main text */
--text-secondary: #9099B5;  /* Secondary text */
--color-positive: #1FCB78;  /* Green for gains */
--color-negative: #FF4D5E;  /* Red for losses */
--color-premium: #2F6FED;   /* Blue for premium/buttons */
```

## Future Enhancements

- [ ] PHP backend for session management
- [ ] Login/Signup authentication
- [ ] Database persistence for portfolios
- [ ] Real payment processing for premium
- [ ] News integration (NewsData.io API)
- [ ] Email alerts for price changes
- [ ] Advanced portfolio analytics
- [ ] Export portfolio to CSV

## Deployment

### Option 1: Free Hosting (000webhost)
1. Upload entire `web_browser/` folder to hosting
2. Set `index.html` as default file
3. API calls use CORS (should work cross-origin)

### Option 2: Heroku + PHP
```bash
echo "<?php include 'index.html'; ?>" > index.php
git add .
git commit -m "Add index.php for Heroku"
git push heroku main
```

### Option 3: Vercel (Frontend-only)
```bash
vercel deploy
```

## Browser Compatibility

- Chrome/Edge (latest 2 versions)
- Firefox (latest 2 versions)
- Safari 14+
- Mobile browsers (iOS Safari, Chrome Mobile)

## Performance

- API responses cached for 10 minutes
- Chart.js renders efficiently with Chart.js library
- localStorage used for portfolio (no network required)
- Lazy loading of historical data (only on detail page)

## Known Limitations

- API fallback data is randomly generated (not real)
- News service not yet implemented
- Premium features are demo-only (no real payments)
- Authentication is session-only (not persistent)

---

**Last Updated**: 2026-06-27
**Maintainer**: AlleeCabral
