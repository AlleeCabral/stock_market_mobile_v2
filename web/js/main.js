/**
 * ============================================
 * MAIN APPLICATION
 * App initialization, routing, and state
 * ============================================
 */

// Configuration
const CONFIG = {
  MARKETSTACK_API_KEY: '3ddb062d21ac3eb2da536681d7afc0ef', // From mobile app config
  NEWSDATA_API_KEY: 'pub_f63e015c14ae4c019531dddf1771fc23', // From mobile app config
};

// Global app state
const appState = {
  currentPage: 'home',
  user: null,
  stocks: [],
  selectedStock: null,
  portfolio: [],
};

// Services
let apiService = null;
let historyService = null;
let searchEngine = null;

/**
 * Initialize the application
 */
async function initApp() {
  console.log('Initializing Stock Market App...');

  // Initialize services
  apiService = new ApiService(CONFIG.MARKETSTACK_API_KEY);
  historyService = new HistoryService(CONFIG.MARKETSTACK_API_KEY);
  searchEngine = new SearchEngine();

  // Load portfolio from localStorage
  loadPortfolio();

  // Load stocks
  await loadStocks();

  // Setup navigation
  setupNavigation();

  // Show home page by default
  showPage('home');

  console.log('App initialized successfully');
}

/**
 * Load stocks data
 */
async function loadStocks() {
  try {
    console.log('Loading stocks...');
    appState.stocks = await apiService.getStocks();
    searchEngine.setStocks(appState.stocks);
    console.log(`Loaded ${appState.stocks.length} stocks`);
    return appState.stocks;
  } catch (error) {
    console.error('Error loading stocks:', error);
    return [];
  }
}

/**
 * Setup navigation handlers
 */
function setupNavigation() {
  // Desktop navigation
  const navLinks = document.querySelectorAll('.navbar-nav a');
  navLinks.forEach((link) => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      const page = link.getAttribute('data-page');
      if (page) {
        showPage(page);
        // Update active state
        navLinks.forEach((l) => l.classList.remove('active'));
        link.classList.add('active');
      }
    });
  });

  // Mobile navigation toggle
  const navToggle = document.querySelector('.navbar-toggle');
  const navMenu = document.querySelector('.navbar-nav');
  if (navToggle) {
    navToggle.addEventListener('click', () => {
      navMenu.style.display =
        navMenu.style.display === 'flex' ? 'none' : 'flex';
    });
  }
}

/**
 * Show a page
 */
function showPage(pageName) {
  // Hide all pages
  const pages = document.querySelectorAll('.page');
  pages.forEach((page) => page.classList.remove('active'));

  // Show requested page
  const page = document.getElementById(`page-${pageName}`);
  if (page) {
    page.classList.add('active');
    appState.currentPage = pageName;

    // Close mobile menu
    const navMenu = document.querySelector('.navbar-nav');
    if (navMenu) {
      navMenu.style.display = 'none';
    }

    // Initialize page-specific logic
    initPageLogic(pageName);
  }
}

/**
 * Page-specific initialization
 */
function initPageLogic(page) {
  switch (page) {
    case 'home':
      initHomePage();
      break;
    case 'explore':
      initExplorePage();
      break;
    case 'portfolio':
      initPortfolioPage();
      break;
    case 'premium':
      initPremiumPage();
      break;
  }
}

/**
 * Utility: Format price
 */
function formatPrice(value) {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2,
  }).format(value);
}

/**
 * Utility: Format percent change
 */
function formatPercent(value) {
  const formatted = Math.abs(value).toFixed(2);
  return `${value >= 0 ? '+' : ''}${value.toFixed(2)}%`;
}

/**
 * Utility: Get change color
 */
function getChangeColor(change) {
  return change >= 0 ? '#1FCB78' : '#FF4D5E';
}

/**
 * Utility: Get change class
 */
function getChangeClass(change) {
  return change >= 0 ? 'positive' : 'negative';
}

/**
 * Utility: Navigate to stock detail
 */
function viewStockDetail(symbol) {
  // Find stock in cache
  const stock = appState.stocks.find((s) => s.symbol === symbol);
  if (stock) {
    appState.selectedStock = stock;
    // Store in sessionStorage for detail page
    sessionStorage.setItem('selectedStock', JSON.stringify(stock));
    showPage('stock-detail');
  }
}

/**
 * Portfolio: Load from localStorage
 */
function loadPortfolio() {
  const saved = localStorage.getItem('portfolio');
  appState.portfolio = saved ? JSON.parse(saved) : [];
}

/**
 * Portfolio: Save to localStorage
 */
function savePortfolio() {
  localStorage.setItem('portfolio', JSON.stringify(appState.portfolio));
}

/**
 * Portfolio: Add stock
 */
function addToPortfolio(stock, shares = 1) {
  const existing = appState.portfolio.find((h) => h.symbol === stock.symbol);
  if (existing) {
    existing.shares += shares;
  } else {
    appState.portfolio.push({
      symbol: stock.symbol,
      name: stock.name,
      shares: shares,
      purchasePrice: stock.close,
      purchaseDate: new Date().toISOString(),
    });
  }
  savePortfolio();
  console.log(`Added ${shares} shares of ${stock.symbol} to portfolio`);
}

/**
 * Portfolio: Remove stock
 */
function removeFromPortfolio(symbol) {
  appState.portfolio = appState.portfolio.filter((h) => h.symbol !== symbol);
  savePortfolio();
  console.log(`Removed ${symbol} from portfolio`);
}

/**
 * Calculate portfolio totals
 */
function calculatePortfolioTotals(currentPrices = {}) {
  let totalValue = 0;
  let totalCost = 0;

  appState.portfolio.forEach((holding) => {
    const currentPrice = currentPrices[holding.symbol] || holding.purchasePrice;
    totalValue += holding.shares * currentPrice;
    totalCost += holding.shares * holding.purchasePrice;
  });

  return {
    totalValue,
    totalCost,
    totalGain: totalValue - totalCost,
    totalGainPercent:
      totalCost > 0 ? ((totalValue - totalCost) / totalCost) * 100 : 0,
  };
}

// PAGE-SPECIFIC LOGIC

/**
 * Initialize home page
 */
function initHomePage() {
  console.log('Initializing home page...');
  // TODO: Load news, display portfolio summary
}

/**
 * Initialize explore page
 */
function initExplorePage() {
  console.log('Initializing explore page...');
  renderStocksList(appState.stocks);

  // Setup search
  const searchInput = document.getElementById('stock-search');
  if (searchInput) {
    searchInput.addEventListener('input', (e) => {
      const filtered = searchEngine.search(e.target.value);
      renderStocksList(filtered);
    });
  }
}

/**
 * Render stocks list
 */
function renderStocksList(stocks) {
  const container = document.getElementById('stocks-list');
  if (!container) return;

  if (stocks.length === 0) {
    container.innerHTML =
      '<div class="text-secondary text-center" style="padding: 20px;">No stocks found</div>';
    return;
  }

  container.innerHTML = stocks
    .map(
      (stock) => `
    <div class="stock-row" onclick="viewStockDetail('${stock.symbol}')">
      <div class="stock-symbol">${stock.symbol}</div>
      <div class="stock-name">${stock.name}</div>
      <div class="stock-price">${formatPrice(stock.close)}</div>
      <div class="stock-change ${getChangeClass(stock.change_pct)}">
        ${stock.change_pct >= 0 ? '▲' : '▼'} ${formatPercent(stock.change_pct)}
      </div>
    </div>
  `
    )
    .join('');
}

/**
 * Initialize portfolio page
 */
function initPortfolioPage() {
  console.log('Initializing portfolio page...');
  renderPortfolio();
}

/**
 * Render portfolio
 */
function renderPortfolio() {
  const container = document.getElementById('portfolio-holdings');
  if (!container) return;

  if (appState.portfolio.length === 0) {
    container.innerHTML =
      '<div class="text-secondary text-center" style="padding: 20px;">No holdings in portfolio</div>';
    return;
  }

  container.innerHTML = appState.portfolio
    .map(
      (holding) => `
    <div class="portfolio-holding">
      <div class="holding-info">
        <h3>${holding.symbol}</h3>
        <div class="holding-details">
          ${holding.shares} shares @ ${formatPrice(holding.purchasePrice)}
        </div>
      </div>
      <div class="holding-actions">
        <button class="btn btn-secondary btn-sm" onclick="removeFromPortfolio('${holding.symbol}')">
          Remove
        </button>
      </div>
    </div>
  `
    )
    .join('');
}

/**
 * Initialize premium page
 */
function initPremiumPage() {
  console.log('Initializing premium page...');
  setupPremiumButtons();
}

/**
 * Setup premium plan buttons
 */
function setupPremiumButtons() {
  const planButtons = document.querySelectorAll('.plan-select-btn');
  planButtons.forEach((btn) => {
    btn.addEventListener('click', (e) => {
      const plan = e.target.getAttribute('data-plan');
      handlePremiumCheckout(plan);
    });
  });
}

/**
 * Handle premium checkout (demo)
 */
function handlePremiumCheckout(plan) {
  alert(
    `Demo checkout for ${plan} plan. No real payment will be processed.`
  );
  localStorage.setItem('premium', 'true');
  console.log(`Premium activated for plan: ${plan}`);
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initApp);
} else {
  initApp();
}
