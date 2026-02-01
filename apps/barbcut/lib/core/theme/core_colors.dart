import 'package:flutter/material.dart';

/// Core color palette - single source of truth for colors
class CoreColors {
  CoreColors._();

  // Primary palette - Dark gray
  static const Color primary = Color(0xFF2D2D2D);
  static const Color primaryLight = Color(0xFFE0E0E0);
  static const Color primaryDark = Color(0xFF1A1A1A);

  // Accent colors
  static const Color accent = Color(0xFF424242);
  static const Color accentBlue = Color(0xFF616161);
  static const Color accentOrange = Color(0xFF757575);
  static const Color accentPurple = Color(0xFF616161);

  // Neutral palette - Gray
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Semantic colors
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);

  // Light theme colors
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightShadow = Color(0x1F000000);
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF616161);
  static const Color lightTextTertiary = Color(0xFF9E9E9E);

  // Dark theme colors
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkBorder = Color(0xFF2D2D2D);
  static const Color darkShadow = Color(0x3F000000);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFBDBDBD);
  static const Color darkTextTertiary = Color(0xFF9E9E9E);
}

/// Get theme-aware colors based on brightness
class AdaptiveColors {
  final Brightness brightness;

  AdaptiveColors(this.brightness);

  Color get surface => brightness == Brightness.light
      ? CoreColors.lightSurface
      : CoreColors.darkSurface;

  Color get background => brightness == Brightness.light
      ? CoreColors.lightBackground
      : CoreColors.darkBackground;

  Color get border => brightness == Brightness.light
      ? CoreColors.lightBorder
      : CoreColors.darkBorder;

  Color get shadow => brightness == Brightness.light
      ? CoreColors.lightShadow
      : CoreColors.darkShadow;

  Color get textPrimary => brightness == Brightness.light
      ? CoreColors.lightTextPrimary
      : CoreColors.darkTextPrimary;

  Color get textSecondary => brightness == Brightness.light
      ? CoreColors.lightTextSecondary
      : CoreColors.darkTextSecondary;

  Color get textTertiary => brightness == Brightness.light
      ? CoreColors.lightTextTertiary
      : CoreColors.darkTextTertiary;
}
