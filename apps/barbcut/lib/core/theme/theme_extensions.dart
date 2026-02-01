import 'package:flutter/material.dart';
import 'core_colors.dart';

/// Theme extensions for easy access throughout the app
/// Usage: context.colors.primary, context.textTheme.titleMedium
extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colors => theme.colorScheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get adaptive colors based on current theme
  AdaptiveColors get adaptiveColors => AdaptiveColors(theme.brightness);

  /// Screen size helpers
  bool get isMobile => mediaQuery.size.width < 600;

  bool get isTablet =>
      mediaQuery.size.width >= 600 && mediaQuery.size.width < 1000;

  bool get isDesktop => mediaQuery.size.width >= 1000;

  /// Padding helpers
  EdgeInsets get paddingAll => const EdgeInsets.all(16);

  EdgeInsets get paddingHorizontal =>
      EdgeInsets.symmetric(horizontal: 16);

  EdgeInsets get paddingVertical => EdgeInsets.symmetric(vertical: 16);

  EdgeInsets get paddingSmall => const EdgeInsets.all(8);

  EdgeInsets get paddingLarge => const EdgeInsets.all(24);
}

/// Extension for easy color access
extension ColorExtension on BuildContext {
  Color get primary => theme.colorScheme.primary;

  Color get secondary => theme.colorScheme.secondary;

  Color get error => theme.colorScheme.error;

  Color get surface => theme.colorScheme.surface;

  Color get onSurface => theme.colorScheme.onSurface;

  Color get background => theme.scaffoldBackgroundColor;
}
