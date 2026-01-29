import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ai_colors.dart';
import 'ai_spacing.dart';

/// Complete 2026 AI App Theme - Material Design 3 Inspired
class AiTheme {
  AiTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // === Color Scheme (Material Design 3) ===
      colorScheme: const ColorScheme.dark(
        primary: AiColors.primary,
        primaryContainer: AiColors.primaryA10,
        secondary: AiColors.warning,
        secondaryContainer: AiColors.warningDark,
        tertiary: AiColors.info,
        tertiaryContainer: AiColors.infoDark,
        surface: AiColors.surface,
        background: AiColors.backgroundDeep,
        error: AiColors.danger,
        onPrimary: AiColors.backgroundDeep,
        onSecondary: AiColors.backgroundDeep,
        onSurface: AiColors.textPrimary,
        onBackground: AiColors.textPrimary,
        onError: AiColors.textPrimary,
        outline: AiColors.borderLight,
        shadow: AiColors.backgroundSecondary,
      ),

      // === Scaffold ===
      scaffoldBackgroundColor: AiColors.backgroundDeep,

      // === App Bar (Glassmorphic) ===
      appBarTheme: AppBarTheme(
        backgroundColor: AiColors.surface.withOpacity(0.7),
        foregroundColor: AiColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          color: AiColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: AiColors.textPrimary, size: 24.0),
      ),

      // === Card Theme ===
      cardTheme: CardThemeData(
        color: AiColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          side: const BorderSide(color: AiColors.borderLight, width: 1.5),
        ),
        margin: EdgeInsets.zero,
      ),

      // === Text Theme ===
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AiColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          height: AiSpacing.lineHeightTight,
        ),
        displayMedium: TextStyle(
          color: AiColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: AiSpacing.lineHeightTight,
        ),
        displaySmall: TextStyle(
          color: AiColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: AiSpacing.lineHeightTight,
        ),
        headlineLarge: TextStyle(
          color: AiColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          height: AiSpacing.lineHeightTight,
        ),
        headlineMedium: TextStyle(
          color: AiColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          height: AiSpacing.lineHeightTight,
        ),
        headlineSmall: TextStyle(
          color: AiColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: AiSpacing.lineHeightTight,
        ),
        titleLarge: TextStyle(
          color: AiColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          height: AiSpacing.lineHeightNormal,
        ),
        titleMedium: TextStyle(
          color: AiColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          height: AiSpacing.lineHeightNormal,
        ),
        titleSmall: TextStyle(
          color: AiColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          height: AiSpacing.lineHeightNormal,
        ),
        bodyLarge: TextStyle(
          color: AiColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          height: AiSpacing.lineHeightNormal,
        ),
        bodyMedium: TextStyle(
          color: AiColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          height: AiSpacing.lineHeightNormal,
        ),
        bodySmall: TextStyle(
          color: AiColors.textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3,
          height: AiSpacing.lineHeightRelaxed,
        ),
        labelLarge: TextStyle(
          color: AiColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          height: 1.0,
        ),
        labelMedium: TextStyle(
          color: AiColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.0,
        ),
        labelSmall: TextStyle(
          color: AiColors.textTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.0,
        ),
      ),

      // === Input Decoration Theme (Prompt field, etc.) ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AiColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          borderSide: const BorderSide(color: AiColors.borderLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          borderSide: const BorderSide(color: AiColors.borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          borderSide: const BorderSide(color: AiColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          borderSide: const BorderSide(color: AiColors.danger, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AiSpacing.md,
          vertical: AiSpacing.md,
        ),
        hintStyle: const TextStyle(
          color: AiColors.textTertiary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: AiColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        prefixIconColor: AiColors.textTertiary,
        suffixIconColor: AiColors.textTertiary,
      ),

      // === Elevated Button Theme ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AiColors.primary,
          foregroundColor: AiColors.backgroundDeep,
          disabledBackgroundColor: AiColors.textDisabled,
          disabledForegroundColor: AiColors.textTertiary,
          elevation: 8,
          padding: const EdgeInsets.symmetric(
            horizontal: AiSpacing.lg,
            vertical: AiSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // === Outlined Button Theme ===
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AiColors.primary,
          side: const BorderSide(color: AiColors.primary, width: 2.0),
          padding: const EdgeInsets.symmetric(
            horizontal: AiSpacing.lg,
            vertical: AiSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // === Text Button Theme ===
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AiColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AiSpacing.md,
            vertical: AiSpacing.sm,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // === Bottom Navigation Bar (Glassmorphic) ===
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0x0DFFFFFF), // 5% white overlay (glass)
        selectedItemColor: AiColors.primary,
        unselectedItemColor: AiColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),

      // === Icon Theme ===
      iconTheme: const IconThemeData(
        color: AiColors.textPrimary,
        size: AiSpacing.iconMedium,
      ),

      // === Divider Theme ===
      dividerTheme: const DividerThemeData(
        color: AiColors.borderLight,
        thickness: 0.5,
        space: AiSpacing.md,
      ),

      // === Checkbox & Radio Theme ===
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AiColors.primary;
          }
          return AiColors.surface;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AiColors.primary;
          }
          return AiColors.surface;
        }),
      ),

      // === Slider Theme ===
      sliderTheme: const SliderThemeData(
        activeTrackColor: AiColors.primary,
        inactiveTrackColor: AiColors.borderLight,
        thumbColor: AiColors.primary,
        overlayColor: Color(0x2D90CAF9),
      ),

      // === Snackbar Theme ===
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AiColors.surface,
        contentTextStyle: const TextStyle(
          color: AiColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
          side: const BorderSide(color: AiColors.borderLight, width: 1.0),
        ),
        elevation: 8,
      ),

      // === Dialog Theme ===
      dialogTheme: DialogThemeData(
        backgroundColor: AiColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          side: const BorderSide(color: AiColors.borderLight, width: 1.5),
        ),
        elevation: 8,
        titleTextStyle: const TextStyle(
          color: AiColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: AiColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // === Floating Action Button Theme ===
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AiColors.primary,
        foregroundColor: AiColors.backgroundDeep,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AiSpacing.radiusXL),
        ),
      ),

      // === Progress Indicator Theme ===
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AiColors.primary,
        linearTrackColor: AiColors.borderLight,
        linearMinHeight: 4,
      ),
    );
  }
}
