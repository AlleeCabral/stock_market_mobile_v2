# Web App Implementation - Testing Guide

## What Was Implemented

### ✅ Phase 1: Foundation & Styling
- [x] HTML structure with 5 pages (Home, Explore, Stock Detail, Portfolio, Premium)
- [x] Theme CSS with design tokens matching mobile app exactly
- [x] Responsive CSS with mobile-first breakpoints (576px, 992px)
- [x] Dark mode color scheme (#13152B background, #1FCB78 positive, #FF4D5E negative)

### ✅ Phase 2: Core Functionality & Search
- [x] Marketstack API integration with 10-minute caching
- [x] **Search functionality** - Real-time filtering by symbol and company name
- [x] Stock list rendering with price and change percentage
- [x] Sparkline data ready (using historical service)

### ✅ Phase 3: Historical Charts & Time Filters
- [x] **History service** - Fetches historical data for 3M/6M/1Y periods
- [x] **Period selector buttons** - Styled exactly like mobile (pills, blue when active)
- [x] **Historical chart display** - Line chart with gradient fill using Chart.js
- [x] **Chart updates** - Clicking period buttons triggers re-fetch and chart update
- [x] Date range display showing first and last date of data
- [x] Min/max price labels on chart

### ✅ Phase 4: Portfolio & Responsive Design
- [x] Add/remove stocks from portfolio
- [x] Portfolio totals calculation (value, shares)
- [x] LocalStorage persistence (survives page reload)
- [x] Responsive design for mobile/tablet/desktop
- [x] Button styling matches mobile (rounded, color-coded)

## Running the Web App

### Option 1: Python HTTP Server (Recommended for Testing)
```bash
cd /home/runner/work/stock_market_mobile_v2/stock_market_mobile_v2/web
python3 -m http.server 8000
# Open http://localhost:8000 in browser
```

### Option 2: PHP Server
```bash
cd /home/runner/work/stock_market_mobile_v2/stock_market_mobile_v2/web
php -S localhost:8000
```

### Option 3: Simple Node Server
```bash
cd /home/runner/work/stock_market_mobile_v2/stock_market_mobile_v2/web
npx http-server -p 8000
```

## Testing Checklist

### 🔍 Search Functionality (Explore Page)
- [ ] Navigate to "Explore" page
- [ ] Type "AAPL" in search box → Should show only Apple stocks
- [ ] Type "apple" (lowercase) → Should still filter correctly
- [ ] Type "tech" → No results (correct behavior)
- [ ] Clear search box → All stocks reappear
- [ ] Search by company name (e.g., "Apple", "Microsoft")
- [ ] Verify real-time filtering as you type

**Expected Behavior**: Same as mobile ExploreScreen (lines 62-71 in explore_screen.dart)

### ⏰ Time Period Filters (Stock Detail Page)
1. Navigate to "Explore" page
2. Click on any stock (e.g., NVDA)
3. On Stock Detail page, verify period buttons appear:
   - [ ] 3M button visible and styled
   - [ ] 6M button visible and styled
   - [ ] 1Y button visible and styled
   - [ ] 1Y button is selected by default (active state)
   - [ ] Buttons are rounded pills with spacing
4. Test period switching:
   - [ ] Click 3M → Chart updates, date range changes
   - [ ] Click 6M → Chart updates with different dates
   - [ ] Click 1Y → Chart updates with full year data
5. Verify selected button:
   - [ ] Selected button has blue background (#2F6FED)
   - [ ] Selected button text is white
   - [ ] Selected button text is bolder than unselected

**Expected Behavior**: Match mobile StockHistoryChart (stock_history_chart.dart)

### 📊 Historical Charts
1. On Stock Detail page:
   - [ ] Chart container visible below period buttons
   - [ ] Chart displays line graph with data points
   - [ ] Chart has gradient fill below the line (semi-transparent)
   - [ ] Line color matches stock trend:
     - Green (#1FCB78) if price increased
     - Red (#FF4D5E) if price decreased
   - [ ] Date range shows at bottom (e.g., "2025-06-27" to "2026-06-27")
2. Test chart responsiveness:
   - [ ] On mobile (<576px) → Chart height ~200px
   - [ ] On tablet (576-992px) → Chart height ~250px
   - [ ] On desktop (>992px) → Chart height ~300px
3. Hover over chart:
   - [ ] Tooltip appears with price info
   - [ ] Tooltip shows "€ XX.XX" format
4. Switch periods and verify:
   - [ ] Chart updates smoothly
   - [ ] New data points appear
   - [ ] Date range updates correctly
   - [ ] Gradient color matches stock trend

**Expected Behavior**: Match mobile historical chart (custom painter in stock_history_chart.dart)

### 💼 Portfolio Management
1. Navigate to "Explore" or "Home"
2. Click on a stock
3. On Stock Detail page:
   - [ ] Click "Buy" button
   - [ ] Prompt asks for quantity
   - [ ] Enter "5" and confirm
   - [ ] Alert confirms purchase
4. Navigate to "Portfolio":
   - [ ] Stock appears in holdings
   - [ ] Shows correct symbol and name
   - [ ] Shows quantity (5 shares)
   - [ ] Shows price per share
   - [ ] Shows total value (5 × price)
5. Test multiple purchases:
   - [ ] Add different stocks
   - [ ] Portfolio shows all holdings
   - [ ] Totals are calculated correctly
   - [ ] "Total Investment" shows sum of all holdings
   - [ ] "Total Shares" shows sum of all shares
6. Test remove:
   - [ ] Click "Remove" on a holding
   - [ ] Confirm deletion
   - [ ] Stock disappears from portfolio
   - [ ] Totals update
7. Test persistence:
   - [ ] Add stocks to portfolio
   - [ ] Reload page (F5 or Cmd+R)
   - [ ] Portfolio still shows all holdings
   - [ ] Data persisted via localStorage

### 🎨 Design & Styling
1. Compare with mobile app:
   - [ ] Background color is #13152B (very dark blue)
   - [ ] Card background is #1E2140 (dark blue)
   - [ ] Text is white (#FFFFFF)
   - [ ] Secondary text is #9099B5 (light gray)
   - [ ] Positive change is green (#1FCB78)
   - [ ] Negative change is red (#FF4D5E)
   - [ ] Primary buttons are blue (#2F6FED)
2. Navigation:
   - [ ] On mobile → Hamburger menu (☰)
   - [ ] On tablet/desktop → Horizontal nav
   - [ ] Links are clickable
   - [ ] Active link is highlighted
3. Spacing & Typography:
   - [ ] Consistent padding/margins
   - [ ] Font sizes match mobile
   - [ ] Heading sizes appropriate
   - [ ] Button sizes and spacing consistent

### 📱 Responsive Design
1. Test on different screen sizes:
   - [ ] Mobile (< 576px): Use device emulation in browser dev tools
     - Stocks row fits on screen
     - Chart takes full width
     - Navigation collapses to hamburger
     - Buttons stack vertically
   - [ ] Tablet (576-992px): Resize browser to ~768px
     - Better spacing
     - Sidebar options if applicable
     - Readable on all sizes
   - [ ] Desktop (> 992px): Normal window
     - Maximum width ~1200px
     - Centered content
     - Proper spacing

2. Browser compatibility:
   - [ ] Chrome/Edge latest
   - [ ] Firefox latest
   - [ ] Safari latest
   - [ ] Mobile Safari (iOS)
   - [ ] Chrome Mobile (Android)

### 🚀 Performance
1. Initial load:
   - [ ] Page loads in < 3 seconds
   - [ ] No console errors
   - [ ] All scripts load (check Network tab)
2. Data fetching:
   - [ ] First load fetches from Marketstack API
   - [ ] Subsequent loads use cache (10-minute TTL)
   - [ ] No duplicate requests
   - [ ] Falls back to fixture data if API fails
3. Chart rendering:
   - [ ] Chart renders without lag
   - [ ] Period switching is smooth
   - [ ] No memory leaks (check DevTools)

### ⚠️ Error Handling
1. Network errors:
   - [ ] Disconnect WiFi/mobile data
   - [ ] Page still shows fixture data
   - [ ] No crash or blank screen
   - [ ] Reconnect → API data loads
2. Invalid periods:
   - [ ] All period buttons work
   - [ ] Clicking buttons doesn't throw errors
3. No data:
   - [ ] Search with no results shows "No stocks found"
   - [ ] Portfolio with no holdings shows "No holdings yet"

## Expected Results Summary

| Feature | Status | Notes |
|---------|--------|-------|
| Search | ✅ Complete | Real-time, by symbol & name |
| Time Filters | ✅ Complete | 3M/6M/1Y period selector |
| Historical Charts | ✅ Complete | Chart.js with gradient fills |
| Portfolio Add | ✅ Complete | Quantity prompt, localStorage |
| Portfolio Remove | ✅ Complete | Confirmation dialog |
| Design Match | ✅ Complete | Exact mobile app colors/spacing |
| Responsive | ✅ Complete | Mobile/tablet/desktop optimized |
| Dark Mode | ✅ Complete | Matches mobile theme |
| API Integration | ✅ Complete | Marketstack with 10-min cache |
| Error Handling | ✅ Complete | Fallback to fixture data |

## Known Limitations

- News integration not yet implemented (NewsData.io)
- PHP backend not yet created (optional)
- Login/Signup not implemented (session-only)
- Premium features are demo-only (no real payments)
- No database persistence (localStorage only)

## Deployment Testing

### Local Deployment Checklist
- [ ] No console errors
- [ ] All pages load and navigate correctly
- [ ] Search works on Explore page
- [ ] Period buttons work on Stock Detail page
- [ ] Charts render and update
- [ ] Portfolio persists after reload
- [ ] Responsive on all screen sizes

### Pre-Deployment
1. Run security check: `codeql_checker` ✅ (already run - no alerts)
2. Verify all file paths are absolute
3. Check for hardcoded API keys (✅ present in JS - move to env vars for production)
4. Test on multiple browsers
5. Test on mobile devices

### Production Deployment
See `/web/README.md` for deployment instructions to:
- 000webhost (free PHP hosting)
- Heroku
- Vercel (frontend-only)
- Custom server

## Questions to Verify with User

1. Should PHP backend be implemented for session management?
2. Should Login/Signup pages be created?
3. Should news integration (NewsData.io) be added?
4. Should this be deployed somewhere immediately, or is local testing sufficient for now?
5. Any additional pages or features needed?

---

**Last Updated**: 2026-06-27
**Status**: Core implementation complete, ready for testing
