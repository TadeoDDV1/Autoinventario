/// Breakpoints para diseño responsivo.
/// Usar estas constantes en lugar de literales mágicos (800, 900, 600, etc.)
/// para mantener consistencia entre pantallas.
class Breakpoints {
  Breakpoints._();

  /// Teléfonos (móvil vertical): < 600
  static const double mobile = 600;

  /// Tablets (móvil horizontal / 2 columnas): 600-900
  static const double tablet = 900;

  /// Desktop (sidebar rail + contenido amplio): >= 900
  static const double desktop = 900;

  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < tablet;
  static bool isDesktop(double width) => width >= desktop;
}
