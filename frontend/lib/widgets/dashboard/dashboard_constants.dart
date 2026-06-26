import 'package:flutter/material.dart';

/// Tokens de espaciado del dashboard. Usar en lugar de SizedBox con
/// valores arbitrarios para mantener consistencia visual entre cards.
class DashboardSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class DashboardRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
}

/// Paleta semántica del dashboard. Aplicar color **solo donde comunique
/// estado** (variación positiva/negativa, alertas). Para decoración usar
/// los colores del ThemeData (primary, surface, etc).
class DashboardColors {
  static const Color positivoFg = Color(0xFF1B5E20);
  static const Color positivoBg = Color(0xFFE8F5E9);
  static const Color positivoBorder = Color(0xFFC8E6C9);

  static const Color negativoFg = Color(0xFFB71C1C);
  static const Color negativoBg = Color(0xFFFFEBEE);
  static const Color negativoBorder = Color(0xFFFFCDD2);

  static const Color neutroFg = Color(0xFF6B7280);
  static const Color neutroBg = Color(0xFFF3F4F6);

  static const Color advertenciaFg = Color(0xFFE65100);
  static const Color advertenciaBg = Color(0xFFFFF3E0);
  static const Color advertenciaBorder = Color(0xFFFFE0B2);
}

/// Estado de la variación vs ayer. Usado por VariacionBadge.
enum VariacionEstado { positivo, negativo, neutro }

VariacionEstado variacionEstadoDe(double pct) {
  if (pct > 0) return VariacionEstado.positivo;
  if (pct < 0) return VariacionEstado.negativo;
  return VariacionEstado.neutro;
}

/// Altura objetivo de cada tipo de card para mantener consistencia.
class DashboardSizes {
  static const double cardSecundariaHeight = 116;
  static const double cardPrincipalMinHeight = 140;
  static const double chartHeight = 160;
  static const double rowListHeight = 56;
}