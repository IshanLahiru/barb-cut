import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// Professional dark theme using FlexColorScheme
/// Sleek gray and black design system for barb-cut application
class BarbCutTheme {
  BarbCutTheme._();

  /// Light theme with gray tones
  static ThemeData get lightTheme {
    return FlexThemeData.light(
      scheme: FlexScheme.greyLaw,
      useMaterial3: true,
      // Primary colors - Dark gray
      primary: const Color(0xFF2D2D2D),
      primaryContainer: const Color(0xFFE5E5E5),
      secondary: const Color(0xFF424242),
      secondaryContainer: const Color(0xFFF5F5F5),
      tertiary: const Color(0xFF616161),
      tertiaryContainer: const Color(0xFFEEEEEE),
      // Neutral colors
      surfaceMode: FlexSurfaceMode.level,
      surface: const Color(0xFFFFFFFF),
      // Status colors
      error: const Color(0xFFD32F2F),
      errorContainer: const Color(0xFFFFEBEE),
      // App bar styling
      appBarStyle: FlexAppBarStyle.primary,
      appBarOpacity: 1.0,
      appBarElevation: 0,
      bottomAppBarElevation: 0,
      tabBarStyle: FlexTabBarStyle.forBackground,
      // Minimal surface tint
      surfaceTint: const Color(0xFF2D2D2D),
      blendLevel: 8,
    ).copyWith(
      // Override button themes to have white text
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color(0xFFFFFFFF),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(foregroundColor: const Color(0xFFFFFFFF)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2D2D2D),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF2D2D2D)),
      ),
      // Dialog theme for light mode
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFFFAFAFA),
        surfaceTintColor: const Color(0xFF2D2D2D),
        titleTextStyle: const TextStyle(
          color: Color(0xFF212121),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: Color(0xFF616161),
          fontSize: 14,
        ),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Dark theme with deep black and gray
  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      scheme: FlexScheme.greyLaw,
      useMaterial3: true,
      // Primary colors - Light gray on dark
      primary: const Color(0xFFE0E0E0),
      primaryContainer: const Color(0xFF424242),
      // Light mode reference colors for "fixed" colors
      primaryLightRef: const Color(0xFF2D2D2D),
      secondary: const Color(0xFFBDBDBD),
      secondaryContainer: const Color(0xFF2D2D2D),
      secondaryLightRef: const Color(0xFF424242),
      tertiary: const Color(0xFF9E9E9E),
      tertiaryContainer: const Color(0xFF1A1A1A),
      tertiaryLightRef: const Color(0xFF616161),
      // Neutral colors - Deep black
      surfaceMode: FlexSurfaceMode.level,
      surface: const Color(0xFF121212),
      // Status colors
      error: const Color(0xFFEF5350),
      errorContainer: const Color(0xFF5D1F1F),
      // App bar styling
      appBarStyle: FlexAppBarStyle.background,
      appBarOpacity: 1.0,
      appBarElevation: 0,
      bottomAppBarElevation: 0,
      tabBarStyle: FlexTabBarStyle.forBackground,
      // Minimal surface tint
      surfaceTint: const Color(0xFFE0E0E0),
      blendLevel: 8,
    ).copyWith(
      // Dialog theme for dark mode
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1A1A1A),
        surfaceTintColor: const Color(0xFFE0E0E0),
        titleTextStyle: const TextStyle(
          color: Color(0xFFE0E0E0),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: Color(0xFFBDBDBD),
          fontSize: 14,
        ),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
