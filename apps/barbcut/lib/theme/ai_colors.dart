import 'package:flutter/material.dart';

/// AI Image Generation Color Palette - 2026 Industry Standard
/// Inspired by Leonardo AI, Midjourney, and modern design trends
/// Dark Mode First with Cyberpunk Gradients & Neon Accents

class AiColors {
  AiColors._();

  // === Deep Charcoal Backgrounds (Cyberpunk) ===
  static const Color backgroundDeep = Color(
    0xFF0A0E27,
  ); // Almost black with blue tint
  static const Color backgroundDark = Color(0xFF0F1419); // Primary dark bg
  static const Color backgroundSecondary = Color(0xFF1A1F3A); // Secondary layer
  static const Color surface = Color(0xFF151B2F); // Cards & elevated surfaces
  static const Color surfaceLight = Color(0xFF1E2541); // Hover state surface

  // === Neon Cyan (Primary Accent) ===
  static const Color neonCyan = Color(0xFF00D9FF); // Vibrant cyan
  static const Color neonCyanDim = Color(
    0xFF00B8D4,
  ); // Dimmer cyan for inactive
  static const Color cyanGlow = Color(0x4D00D9FF); // 30% opacity glow

  // === Sunset Coral (Secondary Accent) ===
  static const Color sunsetCoral = Color(0xFFFF6B35); // Vibrant coral
  static const Color coralDim = Color(0xFFDD5128); // Dimmer coral
  static const Color coralGlow = Color(0x4DFF6B35); // 30% opacity glow

  // === Neon Purple (Tertiary Accent) ===
  static const Color neonPurple = Color(0xFFB933FF); // Vibrant purple
  static const Color purpleDim = Color(0xFF9420D8); // Dimmer purple
  static const Color purpleGlow = Color(0x4DB933FF); // 30% opacity glow

  // === Neutral Whites (Text) ===
  static const Color textPrimary = Color(
    0xFFE8ECFF,
  ); // Slightly blue-tinted white
  static const Color textSecondary = Color(0xFFB0B8CC); // Muted blue-gray
  static const Color textTertiary = Color(0xFF7C8599); // Darker gray
  static const Color textDisabled = Color(0xFF4A5568); // Disabled gray

  // === Border & Divider (Glass effect) ===
  static const Color borderGlass = Color(0x1AFFFFFF); // 10% white
  static const Color borderLight = Color(0x0DFFFFFF); // 5% white
  static const Color divider = Color(0x0A00D9FF); // Subtle cyan divider

  // === Status Colors ===
  static const Color success = Color(0xFF00D977); // Neon green
  static const Color error = Color(0xFFFF4654); // Vibrant red
  static const Color warning = Color(0xFFFFB700); // Bright amber
  static const Color info = Color(0xFF00D9FF); // Cyan

  // === Gradient Colors ===
  static const LinearGradient gradientCyanCoral = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonCyan, sunsetCoral],
  );

  static const LinearGradient gradientCyanPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonCyan, neonPurple],
  );

  static const LinearGradient gradientPurpleToBlack = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [neonPurple, backgroundDeep],
  );

  // === Glass Morphism Colors ===
  static const Color glassLight = Color(0x1EFFFFFF); // 12% white overlay
  static const Color glassMedium = Color(0x2DFFFFFF); // 18% white overlay
  static const Color glassDark = Color(0x3DFFFFFF); // 24% white overlay

  // === Shimmer Colors (Loading State) ===
  static const Color shimmerLight = Color(0x1AB933FF); // Purple shimmer
  static const Color shimmerDark = Color(0x0A00D9FF); // Cyan shimmer
}

/// Gradient utilities for AI components
class AiGradients {
  static const LinearGradient buttonPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AiColors.neonCyan, AiColors.sunsetCoral],
  );

  static const LinearGradient buttonSecondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AiColors.neonPurple, AiColors.neonCyan],
  );

  static const RadialGradient cardGlow = RadialGradient(
    center: Alignment.topRight,
    radius: 1.5,
    colors: [
      Color(0x2D00D9FF), // Cyan glow
      Color(0x00D9FF00), // Transparent
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
