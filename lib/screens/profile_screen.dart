import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/premium_service.dart';
import '../theme/app_theme.dart';
import 'premium_screen.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String displayName = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : 'Hassan Mroue';
    final String email = user?.email ?? 'hassan123@mail.com';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: const Text('Profile', style: AppTheme.screenTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage('assets/images/profile.png'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(email, style: AppTheme.captionText),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              ValueListenableBuilder<bool>(
                valueListenable: PremiumService.isPremium,
                builder: (context, isPremium, child) {
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PremiumScreen()),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.premiumColor,
                        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isPremium ? "You're a Premium member" : 'Update to Premium',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.white),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Unlock the full power of your investments with real-time data and advanced tools',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          if (!isPremium) ...[
                            const SizedBox(height: 12),
                            const _PremiumBullet('Real time stock prices & alerts'),
                            const _PremiumBullet('Advanced charts & analytics'),
                            const _PremiumBullet('Unlimited watchlist'),
                            const _PremiumBullet('AI portfolio Insights'),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Upgrade now',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              _MenuItem(icon: Icons.account_box_rounded, label: 'Account'),
              _MenuItem(icon: Icons.fingerprint, label: 'Security'),
              _MenuItem(icon: Icons.payment_rounded, label: 'Billing / Payments'),
              _MenuItemWithTrailing(icon: Icons.translate, label: 'Language', trailing: 'English'),
              _MenuItem(icon: Icons.settings, label: 'Settings'),
              _MenuItem(icon: Icons.question_answer, label: 'FAQ'),

              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumBullet extends StatelessWidget {
  final String text;

  const _PremiumBullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5, right: 8),
            child: Icon(Icons.circle, color: Colors.white, size: 5),
          ),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(AppTheme.tileRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.chipColor,
              child: Icon(icon, color: AppTheme.textColor, size: 17),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: const TextStyle(color: AppTheme.textColor, fontSize: 15.5)),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.secondaryTextColor, size: 22),
          ],
        ),
      ),
    );
  }
}

class _MenuItemWithTrailing extends StatelessWidget {
  const _MenuItemWithTrailing({required this.icon, required this.label, required this.trailing});
  final IconData icon;
  final String label;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(AppTheme.tileRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.chipColor,
              child: Icon(icon, color: AppTheme.textColor, size: 17),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: const TextStyle(color: AppTheme.textColor, fontSize: 15.5)),
            ),
            Text(trailing, style: AppTheme.captionText),
            const Icon(Icons.chevron_right, color: AppTheme.secondaryTextColor, size: 22),
          ],
        ),
      ),
    );
  }
}
