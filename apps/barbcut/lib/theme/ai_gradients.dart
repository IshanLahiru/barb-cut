/// Compatibility wrapper for gradients used in loading states
import 'package:flutter/material.dart';

class AiGradients {
  static LinearGradient backgroundGradient() {
    return const LinearGradient(
      colors: [
        Color(0xFF121212),
        Color(0xFF1E1E1E),
        Color(0xFF1A1A1A),
      ],
      stops: [0.0, 0.5, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0xFFE0E0E0),
      Color(0xFFF5F5F5),
      Color(0xFFE0E0E0),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient loadingGradient = LinearGradient(
    colors: [
      Color(0xFF00BCD4),
      Color(0xFF4DD0E1),
      Color(0xFF00BCD4),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonPrimary = LinearGradient(
    colors: [
      Color(0xFF00BCD4),
      Color(0xFF00ACC1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
