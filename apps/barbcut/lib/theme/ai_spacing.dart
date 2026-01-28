import 'package:flutter/material.dart';

/// AI Spacing System - Strict 8pt Grid for 2026 Standards
/// All spacing values are multiples of 8 for consistency
/// Formula: base = 8, multiplier = size value
/// Examples: 0 = 0, 1 = 8, 2 = 16, 3 = 24, 4 = 32, 5 = 40, 6 = 48, 7 = 56, 8 = 64

class AiSpacing {
  AiSpacing._();

  // === Base Unit ===
  static const double base = 8.0;

  // === Spacing Tokens ===
  static const double none = 0.0; // 0
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
  static const EdgeInsets ph1 = EdgeInsets.symmetric(
    horizontal: sm,
  ); // 8pt sides
  static const EdgeInsets ph2 = EdgeInsets.symmetric(
    horizontal: md,
  ); // 16pt sides
  static const EdgeInsets ph3 = EdgeInsets.symmetric(
    horizontal: lg,
  ); // 24pt sides

  // === Vertical Padding ===
  static const EdgeInsets pv1 = EdgeInsets.symmetric(
    vertical: sm,
  ); // 8pt top/bottom
  static const EdgeInsets pv2 = EdgeInsets.symmetric(
    vertical: md,
  ); // 16pt top/bottom
  static const EdgeInsets pv3 = EdgeInsets.symmetric(
    vertical: lg,
  ); // 24pt top/bottom

  // === Content Padding (Horizontal + Vertical) ===
  static const EdgeInsets content1 = EdgeInsets.all(sm); // 8pt all
  static const EdgeInsets content2 = EdgeInsets.all(md); // 16pt all
  static const EdgeInsets content3 = EdgeInsets.all(lg); // 24pt all

  // === Border Radius (16dp for 2026 standards) ===
  static const double radiusSmall = 8.0; // Subtle elements
  static const double radiusMedium = 12.0; // Cards, inputs
  static const double radiusLarge = 16.0; // Primary CTA buttons, modals
  static const double radiusXL = 24.0; // Full pill buttons
  static const double radiusCircle = 999.0; // Circular elements

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

  // === Typography Line Heights (based on 8pt grid) ===
  static const double lineHeightTight = 1.2; // For headings
  static const double lineHeightNormal = 1.5; // For body text
  static const double lineHeightRelaxed = 1.75; // For long-form text

  // === Button Heights ===
  static const double buttonHeightSmall = 32.0; // sm
  static const double buttonHeightMedium = 40.0; // md (5x base)
  static const double buttonHeightLarge = 48.0; // lg (6x base)
  static const double buttonHeightXL = 56.0; // xl (7x base)

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

/// Responsive spacing scale - adjusts based on device width
class ResponsiveAiSpacing {
  static double scale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 0.9;
    if (width < 480) return 0.95;
    if (width > 1080) return 1.1;
    return 1.0;
  }

  static EdgeInsets scaledPadding(BuildContext context, EdgeInsets padding) {
    final s = scale(context);
    return EdgeInsets.only(
      left: padding.left * s,
      top: padding.top * s,
      right: padding.right * s,
      bottom: padding.bottom * s,
    );
  }

  static double scaledValue(BuildContext context, double value) {
    return value * scale(context);
  }
}
