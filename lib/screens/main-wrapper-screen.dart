import 'package:flutter/material.dart';
import 'package:stock_market_mobile/screens/portfolio_screen.dart';
import 'package:stock_market_mobile/screens/profile_screen.dart';

import '../widgets/bottom_nav_bar.dart';
import 'explore_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  //this is for refactoring for later, so once can
  //access the route seperately
  //static const String  id = '';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentPageIndex = 0;

  // Your existing screens go here
  final List<Widget> _pages = [
    const HomeScreen(),
    const ExploreScreen(),
    const PortfolioScreen(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentPageIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentPageIndex,
        onTap: (index) => setState(() => currentPageIndex = index),
      ),
    );
  }
}