import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ============================================================================
// COLORS - AI Design System
// ============================================================================

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
  AiGradients._();

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

/// Light mode color palette
class AppColors {
  AppColors._();

  // === Background Colors ===
  static const Color background = Color(0xFFF8F9FA);
  static const Color backgroundSecondary = Color(0xFFF2F2F2);
  static const Color surface = Color(0xFFFFFFFF);

  // === Primary Brand Colors ===
  static const Color primary = Color(0xFF2C3E50);
  static const Color primaryDark = Color(0xFF1A252F);
  static const Color primaryLight = Color(0xFF34495E);

  // === Accent Colors ===
  static const Color accent = Color(0xFFB8860B);
  static const Color accentOrange = Color(0xFFD35400);
  static const Color accentBlue = Color(0xFF5D6D7E);

  // === Text Colors ===
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textTertiary = Color(0xFF7D7D7D);
  static const Color textDisabled = Color(0xFFB3B3B3);

  // === Border & Divider Colors ===
  static const Color border = Color(0xFFDCDCDC);
  static const Color borderLight = Color(0xFFE8E8E8);
  static const Color divider = Color(0xFFEEEEEE);

  // === Status Colors ===
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // === Shadow & Overlay ===
  static const Color shadow = Color(0x0F000000);
  static const Color overlay = Color(0x66000000);
  static const Color hover = Color(0x0A000000);
}

// ============================================================================
// SPACING - 8pt Grid System
// ============================================================================

/// AI Spacing System - Strict 8pt Grid for 2026 Standards
/// All spacing values are multiples of 8 for consistency
class AiSpacing {
  AiSpacing._();

  // === Base Unit ===
  static const double base = 8.0;

  // === Spacing Tokens ===
  static const double none = 0.0;
  static const double xs = 4.0; // Half unit for tight spacing
  static const double sm = 8.0; // 1x unit
  static const double md = 16.0; // 2x units
  static const double lg = 24.0; // 3x units
  static const double xl = 32.0; // 4x units
  static const double xxl = 48.0; // 6x units
  static const double xxxl = 64.0; // 8x units

  // === Padding Presets ===
  static const EdgeInsets p0 = EdgeInsets.all(none);
  static const EdgeInsets p1 = EdgeInsets.all(sm);
  static const EdgeInsets p2 = EdgeInsets.all(md);
  static const EdgeInsets p3 = EdgeInsets.all(lg);
  static const EdgeInsets p4 = EdgeInsets.all(xl);

  // === Horizontal Padding ===
  static const EdgeInsets ph1 = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets ph2 = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets ph3 = EdgeInsets.symmetric(horizontal: lg);

  // === Vertical Padding ===
  static const EdgeInsets pv1 = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets pv2 = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets pv3 = EdgeInsets.symmetric(vertical: lg);

  // === Content Padding ===
  static const EdgeInsets content1 = EdgeInsets.all(sm);
  static const EdgeInsets content2 = EdgeInsets.all(md);
  static const EdgeInsets content3 = EdgeInsets.all(lg);

  // === Border Radius ===
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircle = 999.0;

  // === Borders ===
  static const BorderRadius borderSmall = BorderRadius.all(
    Radius.circular(radiusSmall),
  );
  static const BorderRadius borderMedium = BorderRadius.all(
    Radius.circular(radiusMedium),
  );
  static const BorderRadius borderLarge = BorderRadius.all(
    Radius.circular(radiusLarge),
  );
  static const BorderRadius borderXL = BorderRadius.all(
    Radius.circular(radiusXL),
  );

  // === Elevations / Shadow ===
  static const double elevationNone = 0.0;
  static const double elevationLow = 4.0;
  static const double elevationMedium = 8.0;
  static const double elevationHigh = 16.0;

  // === Gap Sizes ===
  static const SizedBox gap0 = SizedBox.shrink();
  static const SizedBox gapXs = SizedBox(height: xs, width: xs);
  static const SizedBox gapSm = SizedBox(height: sm, width: sm);
  static const SizedBox gapMd = SizedBox(height: md, width: md);
  static const SizedBox gapLg = SizedBox(height: lg, width: lg);
  static const SizedBox gapXl = SizedBox(height: xl, width: xl);

  // === Horizontal Gaps ===
  static const SizedBox gapHSm = SizedBox(width: sm);
  static const SizedBox gapHMd = SizedBox(width: md);
  static const SizedBox gapHLg = SizedBox(width: lg);
  static const SizedBox gapHXl = SizedBox(width: xl);

  // === Vertical Gaps ===
  static const SizedBox gapVSm = SizedBox(height: sm);
  static const SizedBox gapVMd = SizedBox(height: md);
  static const SizedBox gapVLg = SizedBox(height: lg);
  static const SizedBox gapVXl = SizedBox(height: xl);

  // === Typography Line Heights ===
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // === Button Heights ===
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 40.0;
  static const double buttonHeightLarge = 48.0;
  static const double buttonHeightXL = 56.0;

  // === Input Heights ===
  static const double inputHeightSmall = 32.0;
  static const double inputHeightMedium = 40.0;
  static const double inputHeightLarge = 48.0;

  // === Icon Sizes ===
  static const double iconExtraSmall = 16.0;
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXL = 48.0;
}

// ============================================================================
// ADAPTIVE COLORS - Context-aware Color Selection
// ============================================================================

/// Adaptive color palette that responds to the current theme mode
class AdaptiveThemeColors {
  AdaptiveThemeColors._();

  /// Get color based on current brightness
  static Color _adaptiveColor(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkColor : lightColor;
  }

  // === Background Colors ===
  static Color backgroundDeep(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.background,
    darkColor: AiColors.backgroundDeep,
  );

  static Color backgroundDark(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.backgroundSecondary,
    darkColor: AiColors.backgroundDark,
  );

  static Color backgroundSecondary(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.surface,
    darkColor: AiColors.backgroundSecondary,
  );

  static Color surface(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.surface,
    darkColor: AiColors.surface,
  );

  // === Primary Colors ===
  static Color primary(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.primary,
    darkColor: AiColors.primary,
  );

  static Color neonCyan(BuildContext context) => AiColors.neonCyan;
  static Color neonPurple(BuildContext context) => AiColors.neonPurple;
  static Color sunsetCoral(BuildContext context) => AiColors.sunsetCoral;

  // === Text Colors ===
  static Color textPrimary(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.textPrimary,
    darkColor: AiColors.textPrimary,
  );

  static Color textSecondary(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.textSecondary,
    darkColor: AiColors.textSecondary,
  );

  static Color textTertiary(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.textTertiary,
    darkColor: AiColors.textTertiary,
  );

  static Color textDisabled(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.textDisabled,
    darkColor: AiColors.textDisabled,
  );

  // === Border & Divider Colors ===
  static Color border(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.border,
    darkColor: AiColors.borderLight,
  );

  static Color borderLight(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.borderLight,
    darkColor: AiColors.borderLight,
  );

  static Color divider(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.divider,
    darkColor: AiColors.divider,
  );

  // === Status Colors ===
  static Color success(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.success,
    darkColor: AiColors.success,
  );

  static Color error(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.error,
    darkColor: AiColors.danger,
  );

  static Color warning(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.warning,
    darkColor: AiColors.warning,
  );

  static Color info(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.info,
    darkColor: AiColors.info,
  );

  // === Special Colors ===
  static Color shadow(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.shadow,
    darkColor: AiColors.borderGlass,
  );

  static Color overlay(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.overlay,
    darkColor: const Color(0x4C000000),
  );

  static Color hover(BuildContext context) => _adaptiveColor(
    context,
    lightColor: AppColors.hover,
    darkColor: const Color(0x1AFFFFFF),
  );
}

// ============================================================================
// THEME CONFIGURATION - Material Design 3
// ============================================================================

/// Comprehensive theme configuration
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.borderLight, width: 1.0),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AiColors.primary,
        primaryContainer: AiColors.primaryA10,
        secondary: AiColors.warning,
        surface: AiColors.surface,
        error: AiColors.danger,
      ),
      scaffoldBackgroundColor: AiColors.backgroundDeep,
      appBarTheme: AppBarTheme(
        backgroundColor: AiColors.surface.withValues(alpha: 0.7),
        foregroundColor: AiColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: AiColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          side: const BorderSide(color: AiColors.borderLight, width: 1.5),
        ),
      ),
    );
  }
}
