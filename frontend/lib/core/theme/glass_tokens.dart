import 'package:flutter/material.dart';

/// Tokens M3 para cards y paneles del sistema post-glassmorfismo.
class GlassTokens {
  static const double blurSmall = 0;
  static const double blurMedium = 0;
  static const double blurLarge = 0;

  static const double borderRadiusSmall = 12;
  static const double borderRadiusMedium = 16;
  static const double borderRadiusLarge = 24;

  static const double borderWidth = 0.5;
  static const double borderOpacity = 0.15;

  static const double shadowBlur = 12;

  /// Degradado legacy (mantenido para compatibilidad con `AtmosphericBackground`
  /// antes de la migración). Mantenemos `backgroundGradient` por si algo
  /// importaba los símbolos, aunque ya no se usan.
  static const List<Color> backgroundGradient = [
    Color(0xFF0F2027),
    Color(0xFF203A43),
    Color(0xFF2C5364),
  ];
  static const List<Color> altGradient = [
    Color(0xFF1A1B41),
    Color(0xFF2D2A54),
    Color(0xFF3D3A6A),
  ];

  static Color glassColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.35);
  }

  static Color glassBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.5);
  }
}
