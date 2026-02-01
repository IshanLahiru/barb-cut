import 'package:flutter/material.dart';

/// Adapter to map old AiColors constants to Theme.of(context)
/// This allows gradual migration without breaking existing code
class ThemeAdapter {
  /// Get the surface color from theme (replaces AiColors.surface)
  static Color getSurface(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Get background dark from theme (replaces AiColors.backgroundDark)
  static Color getBackgroundDark(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? const Color(0xFF0A0E27)
        : const Color(0xFF0F1419);
  }

  /// Get text primary color from theme (replaces AiColors.textPrimary)
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Get text secondary from theme (replaces AiColors.textSecondary)
  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
  }

  /// Get text tertiary from theme (replaces AiColors.textTertiary)
  static Color getTextTertiary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  /// Get border light from theme (replaces AiColors.borderLight)
  static Color getBorderLight(BuildContext context) {
    return Theme.of(context).colorScheme.outlineVariant;
  }

  /// Get neon cyan primary accent (FlexColorScheme primary in light mode)
  static Color getNeonCyan(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  /// Get accent color from theme
  static Color getAccent(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  /// Get error color from theme (replaces AiColors.error)
  static Color getError(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  /// Get background secondary (slightly lighter surface)
  static Color getBackgroundSecondary(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.surface.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.9 : 0.95,
    );
  }

  /// Get outline/border color
  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }
}
