// Configuration
const MARKETSTACK_API_KEY = '3ddb062d21ac3eb2da536681d7afc0ef';

// Global State
const appState = {
  stocks: [],
  portfolio: [],
  selectedStock: null,
  historyService: null,
  historyChart: null,
  apiService: null,
  currentPage: 'home'
};

// Initialize App
async function initApp() {
  appState.apiService = new ApiService(MARKETSTACK_API_KEY);
  appState.historyService = new HistoryService(MARKETSTACK_API_KEY);

  // Load initial data
  appState.stocks = await appState.apiService.getStocks();
  loadPortfolioFromStorage();

  // Setup navigation
  setupNavigation();

  // Show home page
  showPage('home');
}

function setupNavigation() {
  const navLinks = document.querySelectorAll('.navbar-nav a');
  const navToggle = document.querySelector('.navbar-toggle');

  navLinks.forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      const page = link.dataset.page;
      
      navLinks.forEach(l => l.classList.remove('active'));
      link.classList.add('active');

      // Close mobile nav
      const nav = document.querySelector('.navbar-nav');
      if (navToggle) navToggle.classList.remove('active');

      showPage(page);
    });
  });

  if (navToggle) {
    navToggle.addEventListener('click', () => {
      const nav = document.querySelector('.navbar-nav');
      nav.style.display = nav.style.display === 'flex' ? 'none' : 'flex';
      navToggle.classList.toggle('active');
    });
  }
}

function showPage(pageName) {
  appState.currentPage = pageName;

  // Hide all pages
  document.querySelectorAll('.page').forEach(page => {
    page.classList.remove('active');
  });

  // Show selected page
  const page = document.getElementById(`page-${pageName}`);
  if (page) {
    page.classList.add('active');
    initPageLogic(pageName);
  }
}

function initPageLogic(pageName) {
  switch(pageName) {
    case 'home':
      initHomePage();
      break;
    case 'explore':
      initExplorePage();
      break;
    case 'detail':
      initDetailPage();
      break;
    case 'portfolio':
      initPortfolioPage();
      break;
    case 'premium':
      initPremiumPage();
      break;
  }
}

// HOME PAGE
function initHomePage() {
  const recentStocks = appState.stocks.slice(0, 5);
  
  const recentContainer = document.getElementById('featured-stocks');
  if (!recentContainer) return;

  recentContainer.innerHTML = recentStocks.map(stock => `
    <div class="stock-row" onclick="selectStockAndNavigate('${stock.symbol}')">
      <div class="stock-symbol">${stock.symbol}</div>
      <div class="stock-name">${stock.name}</div>
      <div class="stock-price">€${stock.close}</div>
      <div class="stock-change ${stock.change >= 0 ? 'positive' : 'negative'}">
        ${stock.change >= 0 ? '+' : ''}${stock.change}%
      </div>
    </div>
  `).join('');
}

// EXPLORE PAGE
function initExplorePage() {
  const searchInput = document.getElementById('stock-search');
  const stocksList = document.getElementById('stocks-list');

  if (!searchInput || !stocksList) return;

  renderStocks(appState.stocks);

  searchInput.addEventListener('input', (e) => {
    const searchEngine = new SearchEngine(appState.stocks);
    const filtered = searchEngine.search(e.target.value);
    renderStocks(filtered);
  });
}

function renderStocks(stocks) {
  const stocksList = document.getElementById('stocks-list');
  if (!stocksList) return;

  if (stocks.length === 0) {
    stocksList.innerHTML = '<p class="text-center text-secondary" style="padding: 20px;">No stocks found</p>';
    return;
  }

  stocksList.innerHTML = stocks.map(stock => `
    <div class="stock-row" onclick="selectStockAndNavigate('${stock.symbol}')">
      <div class="stock-symbol">${stock.symbol}</div>
      <div class="stock-name">${stock.name}</div>
      <div class="stock-price">€${stock.close}</div>
      <div class="stock-change ${stock.change >= 0 ? 'positive' : 'negative'}">
        ${stock.change >= 0 ? '+' : ''}${stock.change}%
      </div>
    </div>
  `).join('');
}

// DETAIL PAGE
function initDetailPage() {
  const selectedStock = appState.selectedStock || appState.stocks[0];
  if (!selectedStock) return;

  // Populate header
  document.getElementById('stock-name').textContent = selectedStock.name;
  document.getElementById('stock-symbol').textContent = selectedStock.symbol;
  document.getElementById('stock-price').textContent = `€${selectedStock.close}`;
  document.getElementById('stock-price').className = `price-display ${selectedStock.change >= 0 ? 'text-positive' : 'text-negative'}`;

  // Populate metrics
  document.getElementById('metric-open').textContent = `€${selectedStock.open}`;
  document.getElementById('metric-close').textContent = `€${selectedStock.close}`;
  document.getElementById('metric-high').textContent = `€${selectedStock.high}`;
  document.getElementById('metric-low').textContent = `€${selectedStock.low}`;

  // Chart
  const lineColor = selectedStock.change >= 0 ? '#1FCB78' : '#FF4D5E';
  
  appState.historyChart = new HistoryChart('history-chart', appState.historyService);
  appState.historyChart.render(selectedStock.symbol, lineColor);

  // Period buttons
  const periodButtons = document.querySelectorAll('.period-btn');
  periodButtons.forEach(btn => {
    btn.classList.remove('active');
    btn.addEventListener('click', async (e) => {
      const period = e.target.dataset.period;
      
      periodButtons.forEach(b => b.classList.remove('active'));
      e.target.classList.add('active');

      appState.historyChart.setPeriod(period);
      await appState.historyChart.render(selectedStock.symbol, lineColor);
    });
  });

  if (periodButtons.length > 0) {
    periodButtons[2].classList.add('active'); // Default to 1Y
  }

  // Buy button
  const buyBtn = document.getElementById('buy-btn');
  if (buyBtn) {
    buyBtn.onclick = () => addToPortfolio(selectedStock);
  }
}

// PORTFOLIO PAGE
function initPortfolioPage() {
  const holdingsList = document.getElementById('portfolio-holdings');
  const totalsContainer = document.getElementById('portfolio-totals');

  if (!holdingsList) return;

  if (appState.portfolio.length === 0) {
    holdingsList.innerHTML = '<p class="text-center text-secondary" style="padding: 20px;">No holdings yet</p>';
    totalsContainer.innerHTML = '';
    return;
  }

  holdingsList.innerHTML = appState.portfolio.map((holding, idx) => `
    <div class="portfolio-holding">
      <div class="holding-info">
        <h3>${holding.symbol}</h3>
        <div class="holding-details">
          ${holding.quantity} shares @ €${holding.price}
        </div>
      </div>
      <div style="display: flex; gap: 10px; align-items: center;">
        <div style="text-align: right;">
          <div class="stock-price">€${(holding.quantity * holding.price).toFixed(2)}</div>
          <div class="text-secondary" style="font-size: 12px;">€${holding.price}/share</div>
        </div>
        <button class="btn btn-sm btn-negative" onclick="removeFromPortfolio(${idx})">Remove</button>
      </div>
    </div>
  `).join('');

  const totals = calculatePortfolioTotals();
  totalsContainer.innerHTML = `
    <div class="summary-card">
      <div class="summary-label">Total Investment</div>
      <div class="summary-value text-positive">€${totals.total.toFixed(2)}</div>
    </div>
    <div class="summary-card">
      <div class="summary-label">Total Shares</div>
      <div class="summary-value">${totals.shares}</div>
    </div>
  `;
}

// PREMIUM PAGE
function initPremiumPage() {
  const upgradeButtons = document.querySelectorAll('[data-plan]');
  upgradeButtons.forEach(btn => {
    btn.addEventListener('click', (e) => {
      alert(`Upgrade to ${e.target.dataset.plan} (Demo - not functional)`);
    });
  });
}

// Portfolio Management
function addToPortfolio(stock) {
  const quantity = prompt(`How many ${stock.symbol} shares?`, '1');
  if (!quantity || isNaN(quantity) || quantity <= 0) return;

  const holding = {
    symbol: stock.symbol,
    name: stock.name,
    price: parseFloat(stock.close),
    quantity: parseInt(quantity)
  };

  appState.portfolio.push(holding);
  savePortfolioToStorage();
  alert(`Added ${quantity} ${stock.symbol} to portfolio!`);
}

function removeFromPortfolio(idx) {
  if (confirm('Remove this holding?')) {
    appState.portfolio.splice(idx, 1);
    savePortfolioToStorage();
    initPortfolioPage();
  }
}

function calculatePortfolioTotals() {
  const total = appState.portfolio.reduce((sum, h) => sum + (h.quantity * h.price), 0);
  const shares = appState.portfolio.reduce((sum, h) => sum + h.quantity, 0);
  return { total, shares };
}

function savePortfolioToStorage() {
  localStorage.setItem('portfolio', JSON.stringify(appState.portfolio));
}

function loadPortfolioFromStorage() {
  const saved = localStorage.getItem('portfolio');
  if (saved) {
    appState.portfolio = JSON.parse(saved);
  }
}

// Navigation Helper
function selectStockAndNavigate(symbol) {
  appState.selectedStock = appState.stocks.find(s => s.symbol === symbol);
  showPage('detail');
  
  // Update nav
  document.querySelectorAll('.navbar-nav a').forEach(link => {
    link.classList.remove('active');
    if (link.dataset.page === 'detail') {
      link.classList.add('active');
    }
  });
}

// Initialize when page loads
document.addEventListener('DOMContentLoaded', initApp);
