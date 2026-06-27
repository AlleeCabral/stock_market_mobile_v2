import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_market_mobile/theme/app_theme.dart';

class PriceChart extends StatefulWidget {
  const PriceChart({super.key});

  @override
  State<PriceChart> createState() => _PriceChart();
}

class _PriceChart extends State<PriceChart> {
  // your dynamic state goes here
  // e.g. String title = '';
  //      List<Item> items = [];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12), // adjust value as needed
        ),
        margin: EdgeInsets.all(10),
        height: 200,
        child: Center(
          child: Text('Stock Chart'),
        ),
      ),
    );
  }
}