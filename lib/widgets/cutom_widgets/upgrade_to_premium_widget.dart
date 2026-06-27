import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class UpgradeToPremiumWidget extends StatelessWidget {
  const UpgradeToPremiumWidget({super.key});

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text(
              'Premium',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Unlock everything with Premium:',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 12),
            _PremiumFeature(Icons.show_chart, 'Real-time stock data'),
            _PremiumFeature(Icons.notifications_active, 'Price alerts'),
            _PremiumFeature(Icons.bar_chart, 'Advanced analytics'),
            _PremiumFeature(Icons.article, 'Full news access'),
            _PremiumFeature(Icons.block, 'No ads'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe later', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Upgrade Now', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPremiumDialog(context),
      child: Container(
        color: AppTheme.cardColor,
        margin: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              child: const Icon(Icons.receipt, size: 50, color: Colors.white),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: const Text(
                'Upgrade to premium',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumFeature extends StatelessWidget {
  const _PremiumFeature(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
