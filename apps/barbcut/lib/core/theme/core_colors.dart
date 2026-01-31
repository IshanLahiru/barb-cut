import 'package:flutter/material.dart';

/// Core color palette - single source of truth for colors
class CoreColors {
  CoreColors._();

  // Primary palette
  static const Color primary = Color(0xFF90CAF9);
  static const Color primaryLight = Color(0xFFBBDEFB);
  static const Color primaryDark = Color(0xFF42A5F5);

  // Accent colors
  static const Color accent = Color(0xFFD7AC61);
  static const Color accentBlue = Color(0xFF4A90E2);
  static const Color accentOrange = Color(0xFFFF6B6B);

  // Neutral palette
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Semantic colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Light theme colors
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightShadow = Color(0x1F000000);
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF616161);
  static const Color lightTextTertiary = Color(0xFF9E9E9E);

  // Dark theme colors
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkBorder = Color(0xFF2C2C2C);
  static const Color darkShadow = Color(0x3F000000);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFBDBDBD);
  static const Color darkTextTertiary = Color(0xFF757575);
}

/// Get theme-aware colors based on brightness
class AdaptiveColors {
  final Brightness brightness;

  AdaptiveColors(this.brightness);

  Color get surface =>
      brightness == Brightness.light ? CoreColors.lightSurface : CoreColors.darkSurface;

  Color get background =>
      brightness == Brightness.light ? CoreColors.lightBackground : CoreColors.darkBackground;

  Color get border =>
      brightness == Brightness.light ? CoreColors.lightBorder : CoreColors.darkBorder;

  Color get shadow =>
      brightness == Brightness.light ? CoreColors.lightShadow : CoreColors.darkShadow;

  Color get textPrimary =>
      brightness == Brightness.light ? CoreColors.lightTextPrimary : CoreColors.darkTextPrimary;

  Color get textSecondary =>
      brightness == Brightness.light
          ? CoreColors.lightTextSecondary
          : CoreColors.darkTextSecondary;

  Color get textTertiary =>
      brightness == Brightness.light ? CoreColors.lightTextTertiary : CoreColors.darkTextTertiary;
}
