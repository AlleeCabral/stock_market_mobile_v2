import 'package:flutter/material.dart';

import '../services/stock_service.dart';
import '../theme/app_theme.dart';
import '../widgets/news_card.dart';
import '../widgets/stock_card.dart';
import 'profile_screen.dart';

/// The "Explore" tab: a snapshot of the latest market news plus the full,
/// searchable list of stocks. Stocks are loaded from [StockService] (live API
/// with fixture fallback), then filtered client-side by the search field.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StockService _stockService = StockService();

  String _query = '';
  List<Map<String, dynamic>> _allStocks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStocks({bool forceRefresh = false}) async {
    if (!forceRefresh) setState(() => _loading = true);
    setState(() => _error = null);

    try {
      final stocks = await _stockService.fetchLatestStocks(forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _allStocks = stocks.map((s) => s.toMap()).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredStocks {
    if (_query.isEmpty) return _allStocks;

    final query = _query.toLowerCase();
    return _allStocks
        .where((stock) =>
            stock['name'].toString().toLowerCase().contains(query) ||
            stock['symbol'].toString().toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: const Text('Stocks To Explore', style: AppTheme.screenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.textColor, size: 26),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Profile()),
                );
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/images/profile.png'),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  style: const TextStyle(color: AppTheme.textColor),
                  decoration: InputDecoration(
                    hintText: 'Search company or ticker',
                    hintStyle: const TextStyle(color: AppTheme.secondaryTextColor),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.secondaryTextColor),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const NewsCard(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('All stocks', style: AppTheme.sectionTitle),
                    ),
                    if (!_loading)
                      IconButton(
                        icon: const Icon(Icons.refresh, color: AppTheme.secondaryTextColor, size: 20),
                        onPressed: () => _loadStocks(forceRefresh: true),
                        tooltip: 'Refresh stocks',
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _loading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _error != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Could not load stocks.',
                                  style: TextStyle(color: AppTheme.textColor),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.secondaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => _loadStocks(forceRefresh: true),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : StockCard(items: _filteredStocks),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
