import 'package:flutter/material.dart';

class AppColors {
  // Primary Blue Palette
  static const Color primaryBlue = Color(0xFF0077B6);
  static const Color primaryBlue900 = Color(0xFF003B5C);
  static const Color primaryBlue800 = Color(0xFF004D77);
  static const Color primaryBlue700 = Color(0xFF005F93);
  static const Color primaryBlue600 = Color(0xFF006CA7);
  static const Color primaryBlue500 = Color(0xFF0077B6); // Main Primary
  static const Color primaryBlue400 = Color(0xFF1A8AC2);
  static const Color primaryBlue300 = Color(0xFF339DCE);
  static const Color primaryBlue200 = Color(0xFF66B8DC);
  static const Color primaryBlue100 = Color(0xFF99D3E9);
  static const Color primaryBlue50 = Color(0xFFCCE9F4);

  // Secondary Blue Palette
  static const Color secondaryBlue = Color(0xFF0096C7);
  static const Color secondaryBlue900 = Color(0xFF004B64);
  static const Color secondaryBlue800 = Color(0xFF006380);
  static const Color secondaryBlue700 = Color(0xFF007A9C);
  static const Color secondaryBlue600 = Color(0xFF0088B3);
  static const Color secondaryBlue500 = Color(0xFF0096C7); // Main Secondary
  static const Color secondaryBlue400 = Color(0xFF1AA6D1);
  static const Color secondaryBlue300 = Color(0xFF33B5D8);
  static const Color secondaryBlue200 = Color(0xFF66CBE3);
  static const Color secondaryBlue100 = Color(0xFF99DFEE);
  static const Color secondaryBlue50 = Color(0xFFCCEFF6);

  // Neutral Colors
  static const Color neutral900 = Color(0xFF1A1A1A);
  static const Color neutral800 = Color(0xFF333333);
  static const Color neutral700 = Color(0xFF4D4D4D);
  static const Color neutral600 = Color(0xFF666666);
  static const Color neutral500 = Color(0xFF808080);
  static const Color neutral400 = Color(0xFF999999);
  static const Color neutral300 = Color(0xFFB3B3B3);
  static const Color neutral200 = Color(0xFFCCCCCC);
  static const Color neutral100 = Color(0xFFE6E6E6);
  static const Color neutral50 = Color(0xFFF2F2F2);

  // Semantic Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFACC15);
  static const Color error = Color(0xFFEF4444);
  static const Color info = primaryBlue;

  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);
  
  // Text Colors
  static const Color textPrimary = neutral900;
  static const Color textSecondary = neutral700;
  static const Color textTertiary = neutral500;
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Opacity values for various use cases
  static const double emphasisHigh = 1.0;
  static const double emphasisMedium = 0.74;
  static const double emphasisLow = 0.38;

  // Make constructor private to prevent instantiation
  AppColors._();

  // Helper method to get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Get a lighter shade of any color
  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // Get a darker shade of any color
  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
