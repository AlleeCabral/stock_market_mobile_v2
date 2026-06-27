import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/news_card.dart';
import '../widgets/stock_card.dart';
import '../widgets/total_ammount_card.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: const Text('Hi Hassan!', style: AppTheme.screenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.textColor, size: 26),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
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
            children: const [
              TotalAmommount(),
              NewsCard(),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Text('Stocks to explore', style: AppTheme.sectionTitle),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: StockCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
