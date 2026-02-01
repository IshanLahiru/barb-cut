/// Compatibility wrapper for old AiColors
/// Maps to new theme system using ThemeAdapter
import 'package:flutter/material.dart';

class AiColors {
  // Primary text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color borderLight = Color(0xFFE0E0E0);

  // Vibrant accent colors for better visibility
  static const Color neonCyan = Color(0xFF00E5FF); // Bright cyan for selected states
  static const Color accentColor = Color(0xFF00B8D4); // Secondary cyan
  static const Color neonPurple = Color(0xFFAA00FF); // Vibrant purple
  static const Color sunsetCoral = Color(0xFFFF6E40); // Coral orange accent

  // Light theme colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFFFFFF);

  // Dark theme colors - Deep black
  static const Color surfaceDark = Color(0xFF121212);
  static const Color backgroundDeep = Color(0xFF000000);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color backgroundSecondary = Color(0xFF1E1E1E);
  static const Color surface = Color(0xFF1A1A1A);

  // Status colors
  static const Color error = Color(0xFFD32F2F);
  static const Color danger = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Other colors
  static const Color borderGlass = Color(0xFF424242);
  static const Color shimmerLight = Color(0xFFE0E0E0);
  static const Color divider = Color(0x1A9E9E9E);
  static const Color primary = Color(0xFF2D2D2D);
  static const Color primaryA10 = Color(0xFFE5E5E5);
}
