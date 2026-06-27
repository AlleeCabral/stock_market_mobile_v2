import 'package:flutter/material.dart';

/// Central design tokens for the app.
/// Keeping every color/spacing/text-style in one place is what gives the
/// app "a set of common colors for all its pages (continuity)" as required
/// by the assignment.
class AppTheme {
  // --- Surfaces ---
  static const Color backgroundColor = Color(0xFF13152B); // Page background
  static const Color cardColor = Color(0xFF1E2140); // Card / tile background
  static const Color cardColorLighter = Color(0xFF272B52); // Nested card background
  static const Color chipColor = Color(0xFF2A2E54); // Filter pill background

  // --- Text ---
  static const Color textColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFF9099B5); // Muted grey text
  static const Color dividerColor = Color(0xFF2C2F52);

  // --- Status / accent colors ---
  static const Color positiveColor = Color(0xFF1FCB78); // Stock up / gains
  static const Color negativeColor = Color(0xFFFF4D5E); // Stock down / losses
  static const Color premiumColor = Color(0xFF2F6FED); // Premium / brand blue
  static const Color amberColor = Color(0xFFF5B440);

  // --- Helpers ---
  static Color changeColor(num change) =>
      change >= 0 ? positiveColor : negativeColor;

  static Color changeBg(num change) =>
      (change >= 0 ? positiveColor : negativeColor).withValues(alpha: 0.16);

  // --- Reusable text styles ---
  static const TextStyle screenTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: textColor,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: textColor,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: textColor,
  );

  static const TextStyle captionText = TextStyle(
    fontSize: 12.5,
    color: secondaryTextColor,
  );

  static const double cardRadius = 16;
  static const double tileRadius = 12;
}
