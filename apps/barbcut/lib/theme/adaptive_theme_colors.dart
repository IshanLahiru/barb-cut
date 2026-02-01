/// Compatibility wrapper for context-aware colors
import 'package:flutter/material.dart';
import 'ai_colors.dart';

class AdaptiveThemeColors {
  static Color _adaptiveColor(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkColor : lightColor;
  }

  // Background colors
  static Color backgroundDeep(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFFAFAFA),
    darkColor: AiColors.backgroundDeep,
  );

  static Color backgroundDark(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFF5F5F5),
    darkColor: AiColors.backgroundDark,
  );

  static Color backgroundSecondary(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFFFFFFF),
    darkColor: AiColors.backgroundSecondary,
  );

  static Color surface(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFFFFFFF),
    darkColor: AiColors.surface,
  );

  // Text colors
  static Color textPrimary(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFF212121),
    darkColor: const Color(0xFFE0E0E0),
  );

  static Color textSecondary(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFF616161),
    darkColor: const Color(0xFFBDBDBD),
  );

  static Color textTertiary(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFF9E9E9E),
    darkColor: const Color(0xFF9E9E9E),
  );

  static Color textColor(BuildContext context) => textPrimary(context);
  static Color textDisabled(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFBDBDBD),
    darkColor: const Color(0xFF616161),
  );

  // Border & divider colors
  static Color border(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFE0E0E0),
    darkColor: const Color(0xFF424242),
  );

  static Color borderLight(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFF5F5F5),
    darkColor: const Color(0xFF2D2D2D),
  );

  static Color borderGlass(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFE0E0E0),
    darkColor: AiColors.borderGlass,
  );

  static Color divider(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFF5F5F5),
    darkColor: AiColors.divider,
  );

  // Accent colors
  static Color neonCyan(BuildContext context) => AiColors.neonCyan;
  static Color neonPurple(BuildContext context) => AiColors.neonPurple;
  static Color sunsetCoral(BuildContext context) => AiColors.sunsetCoral;
  static Color primary(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFF2D2D2D),
    darkColor: const Color(0xFFE0E0E0),
  );

  // Status colors
  static Color success(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFF388E3C),
    darkColor: const Color(0xFF66BB6A),
  );

  static Color error(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFD32F2F),
    darkColor: const Color(0xFFEF5350),
  );

  static Color warning(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFF57C00),
    darkColor: const Color(0xFFFFB74D),
  );

  static Color info(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFF1976D2),
    darkColor: const Color(0xFF42A5F5),
  );

  // Special colors
  static Color shadow(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0x0F000000),
    darkColor: const Color(0x33000000),
  );

  static Color overlay(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0x66000000),
    darkColor: const Color(0x4C000000),
  );

  static Color hover(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0x0A000000),
    darkColor: const Color(0x1AFFFFFF),
  );
}
