import 'package:flutter/material.dart';

import '../services/premium_service.dart';
import '../theme/app_theme.dart';

/// The required "page where users can buy the pro version of the app".
///
/// This intentionally does not process any real payment — per the course's
/// own scope (and good practice generally) it only simulates a checkout and
/// flips a local flag, which is exactly enough to demonstrate the
/// navigation + functionality the assignment asks for.
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int _selectedPlan = 1; // 0 = monthly, 1 = yearly

  static const List<_Plan> _plans = [
    _Plan(title: 'Monthly', price: '€4.99 / month', badge: null),
    _Plan(title: 'Yearly', price: '€39.99 / year', badge: 'Save 33%'),
  ];

  Future<void> _checkout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm subscription', style: TextStyle(color: AppTheme.textColor)),
        content: Text(
          'This is a demo checkout for the ${_plans[_selectedPlan].title} plan '
          '(${_plans[_selectedPlan].price}). No real payment will be charged.',
          style: const TextStyle(color: AppTheme.secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.secondaryTextColor)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.premiumColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      PremiumService.isPremium.value = true;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You're Premium now (demo) 🎉")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
        title: const Text('Premium', style: AppTheme.screenTitle),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: PremiumService.isPremium,
          builder: (context, isPremium, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.premiumColor,
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.workspace_premium, color: Colors.white, size: 32),
                        const SizedBox(height: 10),
                        Text(
                          isPremium ? "You're a Premium member" : 'Unlock the full power of your investments',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Real-time data and advanced tools, all in one place.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text('What you get', style: AppTheme.sectionTitle),
                  const SizedBox(height: 10),
                  const _Feature(icon: Icons.bolt, label: 'Real-time stock prices & alerts'),
                  const _Feature(icon: Icons.bar_chart, label: 'Advanced charts & analytics'),
                  const _Feature(icon: Icons.star, label: 'Unlimited watchlist'),
                  const _Feature(icon: Icons.auto_awesome, label: 'AI portfolio insights'),
                  const SizedBox(height: 26),
                  if (!isPremium) ...[
                    const Text('Choose your plan', style: AppTheme.sectionTitle),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(_plans.length, (index) {
                        final plan = _plans[index];
                        final bool selected = index == _selectedPlan;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPlan = index),
                            child: Container(
                              margin: EdgeInsets.only(right: index == 0 ? 10 : 0),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: selected ? AppTheme.premiumColor.withValues(alpha: 0.18) : AppTheme.cardColor,
                                borderRadius: BorderRadius.circular(AppTheme.tileRadius),
                                border: Border.all(
                                  color: selected ? AppTheme.premiumColor : AppTheme.dividerColor,
                                  width: 1.4,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(plan.title, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(plan.price, style: AppTheme.captionText),
                                  if (plan.badge != null) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.positiveColor.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        plan.badge!,
                                        style: const TextStyle(color: AppTheme.positiveColor, fontSize: 11, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _checkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.premiumColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Upgrade now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ] else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          PremiumService.isPremium.value = false;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Premium cancelled (demo)')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.negativeColor,
                          side: const BorderSide(color: AppTheme.negativeColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel Premium'),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Plan {
  final String title;
  final String price;
  final String? badge;

  const _Plan({required this.title, required this.price, this.badge});
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Feature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.premiumColor, size: 20),
          const SizedBox(width: 10),
          Text(label, style: AppTheme.bodyText),
        ],
      ),
    );
  }
}
