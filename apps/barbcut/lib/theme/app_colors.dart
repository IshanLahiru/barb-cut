import 'package:flutter/material.dart';

/// Sophisticated color palette for masculine light-mode design
class AppColors {
  AppColors._();

  // === Background Colors ===
  /// Primary background - Subtle off-white for reduced eye strain
  static const Color background = Color(0xFFF8F9FA);

  /// Secondary background - Slightly darker for layered surfaces
  static const Color backgroundSecondary = Color(0xFFF2F2F2);

  /// Surface color for cards and elevated elements
  static const Color surface = Color(0xFFFFFFFF);

  // === Primary Brand Colors ===
  /// Deep charcoal - Primary brand color
  static const Color primary = Color(0xFF2C3E50);

  /// Darker variant for pressed states
  static const Color primaryDark = Color(0xFF1A252F);

  /// Lighter variant for disabled states
  static const Color primaryLight = Color(0xFF34495E);

  // === Accent Colors ===
  /// Muted metallic gold - Premium accent
  static const Color accent = Color(0xFFB8860B);

  /// Burnt orange - Secondary accent for highlights
  static const Color accentOrange = Color(0xFFD35400);

  /// Slate blue - Tertiary accent
  static const Color accentBlue = Color(0xFF5D6D7E);

  // === Text Colors ===
  /// Jet black for primary headings
  static const Color textPrimary = Color(0xFF000000);

  /// Dark grey for body text
  static const Color textSecondary = Color(0xFF4A4A4A);

  /// Medium grey for supporting text
  static const Color textTertiary = Color(0xFF7D7D7D);

  /// Light grey for disabled text
  static const Color textDisabled = Color(0xFFB3B3B3);

  // === Border & Divider Colors ===
  /// Strong border for emphasis
  static const Color border = Color(0xFFDCDCDC);

  /// Subtle border for cards
  static const Color borderLight = Color(0xFFE8E8E8);

  /// Divider color
  static const Color divider = Color(0xFFEEEEEE);

  // === Status Colors ===
  /// Success - Muted forest green
  static const Color success = Color(0xFF27AE60);

  /// Error - Sophisticated red
  static const Color error = Color(0xFFE74C3C);

  /// Warning - Amber
  static const Color warning = Color(0xFFF39C12);

  /// Info - Steel blue
  static const Color info = Color(0xFF3498DB);

  // === Shadow & Overlay ===
  /// Shadow color with opacity
  static const Color shadow = Color(0x0F000000);

  /// Overlay for modals
  static const Color overlay = Color(0x66000000);

  /// Subtle hover state
  static const Color hover = Color(0x0A000000);
}
