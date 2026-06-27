import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const List<NavItem> kBottomNavItems = [
  NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
  NavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Explore'),
  NavItem(icon: Icons.pie_chart_outline, activeIcon: Icons.pie_chart, label: 'Portfolio'),
  NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
];

/// Custom bottom navigation bar matching the Figma design: dark background,
/// thin top divider, outlined icons that switch to filled + green when
/// active, small label underneath.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(top: BorderSide(color: AppTheme.dividerColor, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(kBottomNavItems.length, (index) {
            final item = kBottomNavItems[index];
            final bool selected = index == currentIndex;
            final Color color =
                selected ? AppTheme.positiveColor : AppTheme.secondaryTextColor;

            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(selected ? item.activeIcon : item.icon, color: color, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: color,
                        fontSize: 11.5,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
