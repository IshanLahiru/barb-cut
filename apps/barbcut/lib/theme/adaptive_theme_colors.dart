import 'package:flutter/material.dart';
import 'ai_colors.dart';
import 'app_colors.dart';

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
  static Color backgroundDeep(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.background, darkColor: AiColors.backgroundDeep);

  static Color backgroundDark(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.backgroundSecondary, darkColor: AiColors.backgroundDark);

  static Color backgroundSecondary(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.surface, darkColor: AiColors.backgroundSecondary);

  static Color surface(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.surface, darkColor: AiColors.surface);

  // === Primary Colors ===
  static Color primary(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.primary, darkColor: AiColors.primary);

  static Color neonCyan(BuildContext context) => AiColors.neonCyan;

  static Color neonPurple(BuildContext context) => AiColors.neonPurple;

  static Color sunsetCoral(BuildContext context) => AiColors.sunsetCoral;

  // === Text Colors ===
  static Color textPrimary(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.textPrimary, darkColor: AiColors.textPrimary);

  static Color textSecondary(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.textSecondary, darkColor: AiColors.textSecondary);

  static Color textTertiary(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.textTertiary, darkColor: AiColors.textTertiary);

  static Color textDisabled(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.textDisabled, darkColor: AiColors.textDisabled);

  // === Border & Divider Colors ===
  static Color border(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.border, darkColor: AiColors.borderLight);

  static Color borderLight(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.borderLight, darkColor: AiColors.borderLight);

  static Color divider(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.divider, darkColor: AiColors.divider);

  // === Status Colors ===
  static Color success(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.success, darkColor: AiColors.success);

  static Color error(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.error, darkColor: AiColors.danger);

  static Color warning(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.warning, darkColor: AiColors.warning);

  static Color info(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.info, darkColor: AiColors.info);

  // === Special Colors ===
  static Color shadow(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.shadow, darkColor: AiColors.borderGlass);

  static Color overlay(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.overlay, darkColor: const Color(0x4C000000));

  static Color hover(BuildContext context) =>
      _adaptiveColor(context, lightColor: AppColors.hover, darkColor: const Color(0x1AFFFFFF));
}
