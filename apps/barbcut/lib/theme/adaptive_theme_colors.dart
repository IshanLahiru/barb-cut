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
    lightColor: const Color(0xFFF8F9FA),
    darkColor: AiColors.backgroundDeep,
  );

  static Color backgroundDark(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFF2F2F2),
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
    lightColor: const Color(0xFF000000),
    darkColor: AiColors.textPrimary,
  );

  static Color textSecondary(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFF4A4A4A),
    darkColor: AiColors.textSecondary,
  );

  static Color textTertiary(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFF7D7D7D),
    darkColor: AiColors.textTertiary,
  );

  static Color textColor(BuildContext context) => textPrimary(context);
  static Color textDisabled(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFB3B3B3),
    darkColor: AiColors.textPrimary,
  );

  // Border & divider colors
  static Color border(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFDCDCDC),
    darkColor: AiColors.borderLight,
  );

  static Color borderLight(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFE8E8E8),
    darkColor: AiColors.borderLight,
  );

  static Color borderGlass(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFE8E8E8),
    darkColor: AiColors.borderGlass,
  );

  static Color divider(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFEEEEEE),
    darkColor: AiColors.divider,
  );

  // Accent colors
  static Color neonCyan(BuildContext context) => AiColors.neonCyan;
  static Color neonPurple(BuildContext context) => AiColors.neonPurple;
  static Color sunsetCoral(BuildContext context) => AiColors.sunsetCoral;
  static Color primary(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFF2C3E50),
    darkColor: AiColors.primary,
  );

  // Status colors
  static Color success(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFF27AE60),
    darkColor: AiColors.success,
  );

  static Color error(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFE74C3C),
    darkColor: AiColors.danger,
  );

  static Color warning(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFFF39C12),
    darkColor: AiColors.warning,
  );

  static Color info(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0xFF3498DB),
    darkColor: AiColors.info,
  );

  // Special colors
  static Color shadow(BuildContext context) => _adaptiveColor(
    context,
    lightColor: const Color(0x0F000000),
    darkColor: AiColors.borderGlass,
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
