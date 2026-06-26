import 'package:flutter/material.dart';
import 'dashboard_constants.dart';

/// Header reutilizable para secciones del dashboard (Top productos,
/// Alertas, Ventas 7 días, etc). Mantiene tipografía y espaciado
/// consistentes entre todas las secciones.
class SeccionHeader extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final Color? color;
  final Widget? trailing;
  final int? badgeCount;

  const SeccionHeader({
    super.key,
    required this.titulo,
    required this.icon,
    this.color,
    this.trailing,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: DashboardSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: c, size: 20),
          const SizedBox(width: DashboardSpacing.sm),
          Expanded(
            child: Text(
              titulo,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (badgeCount != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DashboardSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(DashboardRadius.sm),
              ),
              child: Text(
                '$badgeCount',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: c,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: DashboardSpacing.sm),
          ],
          ?trailing,
        ],
      ),
    );
  }
}