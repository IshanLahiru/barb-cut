import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
export 'flex_theme.dart';

// ============================================================================
// COLORS - AI Design System
// ============================================================================

/// AI Color Palette - Dark Mode First Design System (2026)
/// Optimized for readability and visual hierarchy
class AiColors {
  AiColors._();

  // === Surface Backgrounds ===
  static const Color backgroundDeep = Color(0xFF121212); // Darkest surface
  static const Color backgroundDark = Color(0xFF1E1E1E); // Primary dark bg
  static const Color backgroundSecondary = Color(0xFF282828); // Secondary layer
  static const Color surface = Color(0xFF1F1F1F); // Cards & elevated surfaces

  // === Primary Colors ===
  static const Color primary = Color(0xFF90CAF9); // Primary blue
  static const Color primaryA10 = Color(0xFF9ED0FA); // Lighter variant

  // === Accent Colors ===
  static const Color warning = Color(0xFFD7AC61); // Orange accent
  static const Color info = Color(0xFF4077D1); // Secondary blue
  static const Color danger = Color(0xFFD94A4A); // Error red

  // === Text Colors ===
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure white
  static const Color textSecondary = Color(0xFFB0B8CC); // Muted blue-gray
  static const Color textTertiary = Color(0xFF7C8599); // Darker gray

  // === Neutral Colors ===
  static const Color borderLight = Color(0x1FFFFFFF); // 12% white overlay
  static const Color borderGlass = Color(0x1AFFFFFF); // 10% white overlay
  static const Color divider = Color(0x0A90CAF9); // Subtle blue divider

  // === Success State ===
  static const Color success = Color(0xFF47D5A6); // Green

  // === Accent Aliases (for legacy compatibility) ===
  static const Color neonCyan = primary;
  static const Color neonPurple = info;
  static const Color sunsetCoral = warning;

  // === Status Colors (Aliases) ===
  static const Color errorColor = danger;
  static const Color warningColor = warning;
  static const Color infoColor = info;
  static const Color successColor = success;
}

/// Light mode color palette (for light theme support)
class AppColors {
  AppColors._();

  // === Background Colors ===
  static const Color background = Color(0xFFF8F9FA);
  static const Color backgroundSecondary = Color(0xFFF2F2F2);
  static const Color surface = Color(0xFFFFFFFF);

  // === Text Colors ===
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textTertiary = Color(0xFF7D7D7D);
  static const Color textDisabled = Color(0xFFB3B3B3);

  // === Primary Colors ===
  static const Color primary = Color(0xFF2C3E50);

  // === Border Colors ===
  static const Color borderLight = Color(0xFFE8E8E8);
  static const Color border = Color(0xFFDCDCDC);
  static const Color divider = Color(0xFFEEEEEE);

  // === Status Colors ===
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // === Overlay & Shadow ===
  static const Color shadow = Color(0x0F000000);
  static const Color overlay = Color(0x66000000);
  static const Color hover = Color(0x0A000000);
}

// ============================================================================
// SPACING - 8pt Grid System
// ============================================================================

/// AI Spacing System - Consistent 8pt Grid
class AiSpacing {
  AiSpacing._();

  // === Base Unit ===
  static const double base = 8.0;

  // === Spacing Tokens ===
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

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

  // === Border Radius Objects ===
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

  // === Elevations ===
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

/// Adaptive colors that respond to light/dark theme
class AdaptiveThemeColors {
  AdaptiveThemeColors._();

  /// Get color based on current theme brightness
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

  // === Accent Colors ===
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
    darkColor: AiColors.textPrimary,
  );

  // === Border & Divider ===
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

/// Material Design 3 theme configuration
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.warning,
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
