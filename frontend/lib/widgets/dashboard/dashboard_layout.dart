import 'package:flutter/material.dart';
import '../../core/layout/breakpoints.dart';

/// Variante del layout según ancho disponible.
enum DashboardLayoutVariant { mobile, tablet, desktop }

DashboardLayoutVariant dashboardVariantDe(double width) {
  if (Breakpoints.isDesktop(width)) return DashboardLayoutVariant.desktop;
  if (Breakpoints.isTablet(width)) return DashboardLayoutVariant.tablet;
  return DashboardLayoutVariant.mobile;
}

/// Sección del dashboard: ocupa una fracción del ancho en desktop,
/// full-width en mobile/tablet.
class DashboardSection extends StatelessWidget {
  final Widget child;
  final int flexDesktop;

  const DashboardSection({
    super.key,
    required this.child,
    this.flexDesktop = 1,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}