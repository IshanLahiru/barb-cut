import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// Black and White theme using FlexColorScheme
/// Minimalist design system for barb-cut application
class BarbCutTheme {
  BarbCutTheme._();

  /// Light theme (White background)
  static ThemeData get lightTheme {
    return FlexThemeData.light(
      scheme: FlexScheme.material,
      useMaterial3: true,
      // Primary colors - Pure black for light theme
      primary: const Color(0xFF000000),
      primaryContainer: const Color(0xFF1A1A1A),
      secondary: const Color(0xFF333333),
      secondaryContainer: const Color(0xFFE8E8E8),
      tertiary: const Color(0xFF666666),
      tertiaryContainer: const Color(0xFFF2F2F2),
      // Neutral colors - Grayscale
      surfaceMode: FlexSurfaceMode.level,
      surface: const Color(0xFFFFFFFF),
      // Status colors - Keep for clarity
      error: const Color(0xFFD94A4A),
      errorContainer: const Color(0xFFFFEBEE),
      // Apply surface blend
      appBarStyle: FlexAppBarStyle.primary,
      appBarOpacity: 1.0,
      appBarElevation: 0,
      bottomAppBarElevation: 0,
      tabBarStyle: FlexTabBarStyle.forBackground,
      // Text theme adjustments
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFF000000),
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: Color(0xFF000000),
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: Color(0xFF000000),
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: Color(0xFF000000),
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF000000),
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: Color(0xFF000000),
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF000000),
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF000000),
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: Color(0xFF000000),
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: Color(0xFF333333)),
        bodyMedium: TextStyle(color: Color(0xFF333333)),
        bodySmall: TextStyle(color: Color(0xFF666666)),
        labelLarge: TextStyle(
          color: Color(0xFF000000),
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          color: Color(0xFF333333),
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: Color(0xFF666666),
          fontWeight: FontWeight.w500,
        ),
      ),
      // Rounded corners configuration handled by app default
    );
  }

  /// Dark theme (Black background)
  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      scheme: FlexScheme.material,
      useMaterial3: true,
      // Primary colors - Pure white for dark theme
      primary: const Color(0xFFFFFFFF),
      primaryContainer: const Color(0xFFE8E8E8),
      secondary: const Color(0xFFCCCCCC),
      secondaryContainer: const Color(0xFF333333),
      tertiary: const Color(0xFF999999),
      tertiaryContainer: const Color(0xFF1A1A1A),
      // Neutral colors - Grayscale
      surfaceMode: FlexSurfaceMode.level,
      surface: const Color(0xFF1A1A1A),
      // Status colors
      error: const Color(0xFFFF6B6B),
      errorContainer: const Color(0xFF5A1A1A),
      // App bar styling
      appBarStyle: FlexAppBarStyle.background,
      appBarOpacity: 1.0,
      appBarElevation: 0,
      bottomAppBarElevation: 0,
      tabBarStyle: FlexTabBarStyle.forBackground,
      // Text theme adjustments
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: Color(0xFFCCCCCC),
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: Color(0xFFCCCCCC)),
        bodyMedium: TextStyle(color: Color(0xFFCCCCCC)),
        bodySmall: TextStyle(color: Color(0xFF999999)),
        labelLarge: TextStyle(
          color: Color(0xFF000000),
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          color: Color(0xFF1A1A1A),
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: Color(0xFF333333),
          fontWeight: FontWeight.w500,
        ),
      ),
      // Rounded corners configuration handled by app default
    );
  }
}
