import 'dart:ui';

import 'package:flutter/material.dart';

class GlassTokens {
  GlassTokens._();

  static const double blurSmall = 10;
  static const double blurMedium = 20;
  static const double blurLarge = 30;

  static const double borderRadiusSmall = 12;
  static const double borderRadiusMedium = 16;
  static const double borderRadiusLarge = 24;

  static const double borderWidth = 0.5;
  static const double borderOpacity = 0.15;

  static const double shadowBlur = 12;

  static List<Color> get backgroundGradient => const [
    Color(0xFF0F2027),
    Color(0xFF203A43),
    Color(0xFF2C5364),
  ];

  static List<Color> get altGradient => const [
    Color(0xFF1A1B41),
    Color(0xFF2D2A54),
    Color(0xFF3D3A6A),
  ];

  static Color glassColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return Colors.white.withValues(alpha: 0.08);
    }
    return Colors.white.withValues(alpha: 0.35);
  }

  static Color glassBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return Colors.white.withValues(alpha: 0.12);
    }
    return Colors.white.withValues(alpha: 0.5);
  }
}
