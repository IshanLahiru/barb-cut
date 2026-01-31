import 'package:flutter/material.dart';

/// AI Image Generation Color Palette - 2026 Material Design 3 Inspired
/// Updated with softer blues and improved contrast
/// Dark Mode First with Refined Aesthetics

class AiColors {
  AiColors._();

  // === Surface Backgrounds (Material Design 3) ===
  static const Color backgroundDeep = Color(0xFF121212); // Darkest surface
  static const Color backgroundDark = Color(0xFF1E1E1E); // Primary dark bg
  static const Color backgroundSecondary = Color(0xFF282828); // Secondary layer
  static const Color surface = Color(0xFF1F1F1F); // Cards & elevated surfaces
  static const Color surfaceLight = Color(0xFF3F3F3F); // Hover state surface

  // === Surface Tonal Colors ===
  static const Color surfaceTonal = Color(0xFF1E2225);
  static const Color surfaceTonaL10 = Color(0xFF333739);
  static const Color surfaceTonalL20 = Color(0xFF494C4F);

  // === Primary Blue (Softer, Material Design 3) ===
  static const Color primary = Color(0xFF90CAF9); // Primary blue
  static const Color primaryA10 = Color(0xFF9ED0FA); // Lighter variant
  static const Color primaryA20 = Color(0xFFABD6FB); // Even lighter variant

  // === Success Green ===
  static const Color successDark = Color(0xFF22946E); // Dark variant
  static const Color success = Color(0xFF47D5A6); // Primary success
  static const Color successLight = Color(0xFF9AE8CE); // Light variant

  // === Warning/Accent Orange ===
  static const Color warningDark = Color(0xFFA87A2A); // Dark variant
  static const Color warning = Color(0xFFD7AC61); // Primary warning
  static const Color warningLight = Color(0xFFECD7B2); // Light variant

  // === Danger/Error Red ===
  static const Color dangerDark = Color(0xFF9C2121); // Dark variant
  static const Color danger = Color(0xFFD94A4A); // Primary danger
  static const Color dangerLight = Color(0xFFEB9E9E); // Light variant

  // === Info/Secondary Blue ===
  static const Color infoDark = Color(0xFF21498A); // Dark variant
  static const Color info = Color(0xFF4077D1); // Primary info
  static const Color infoLight = Color(0xFF92B2E5); // Light variant

  // === Neutral Whites (Text) ===
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure white
  static const Color textSecondary = Color(0xFFB0B8CC); // Muted blue-gray
  static const Color textTertiary = Color(0xFF7C8599); // Darker gray
  static const Color textDisabled = Color(0xFF4A5568); // Disabled gray

  // === Border & Divider ===
  static const Color borderLight = Color(0x1FFFFFFF); // 12% white
  static const Color borderGlass = Color(0x1AFFFFFF); // 10% white
  static const Color divider = Color(0x0A90CAF9); // Subtle blue divider

  // === Status Colors (Aliases for consistency) ===
  static const Color successColor = success;
  static const Color errorColor = danger;
  static const Color warningColor = warning;
  static const Color infoColor = info;

  // === Legacy Neon Colors (for backwards compatibility) ===
  static const Color neonCyan = primary; // Maps to new primary blue
  static const Color neonPurple = info; // Maps to new info blue
  static const Color sunsetCoral = warning; // Maps to new warning

  // === Gradient Colors ===
  static const LinearGradient gradientPrimaryWarning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, warning],
  );

  static const LinearGradient gradientPrimaryInfo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, info],
  );

  static const LinearGradient gradientInfoToBlack = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [info, backgroundDeep],
  );

  // === Glass Morphism Colors ===
  static const Color glassLight = Color(0x1EFFFFFF); // 12% white overlay
  static const Color glassMedium = Color(0x2DFFFFFF); // 18% white overlay
  static const Color glassDark = Color(0x3DFFFFFF); // 24% white overlay

  // === Shimmer Colors (Loading State) ===
  static const Color shimmerLight = Color(0x1A90CAF9); // Blue shimmer
  static const Color shimmerDark = Color(0x0A90CAF9); // Subtle blue shimmer
}

/// Gradient utilities for AI components
class AiGradients {
  static const LinearGradient buttonPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AiColors.primary, AiColors.warning],
  );

  static const LinearGradient buttonSecondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AiColors.info, AiColors.primary],
  );

  static const RadialGradient cardGlow = RadialGradient(
    center: Alignment.topRight,
    radius: 1.5,
    colors: [
      Color(0x2D90CAF9), // Blue glow
      Color(0x90caf900), // Transparent
    ],
  );

  static LinearGradient backgroundGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: const [
        AiColors.backgroundDeep,
        AiColors.backgroundSecondary,
        AiColors.backgroundDark,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }
}
