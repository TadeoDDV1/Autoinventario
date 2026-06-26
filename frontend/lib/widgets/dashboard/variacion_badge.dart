import 'package:flutter/material.dart';
import 'dashboard_constants.dart';

/// Pill compacto que muestra la variación de ventas vs ayer.
/// Reemplaza el bloque gigante de 65 líneas con icono+texto+ayer
/// por un solo ActionChip semánticamente coloreado.
class VariacionBadge extends StatelessWidget {
  final double variacionPct;
  final VoidCallback? onTap;

  const VariacionBadge({
    super.key,
    required this.variacionPct,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final estado = variacionEstadoDe(variacionPct);
    final colors = _colors(estado);
    final iconData = switch (estado) {
      VariacionEstado.positivo => Icons.trending_up,
      VariacionEstado.negativo => Icons.trending_down,
      VariacionEstado.neutro => Icons.trending_flat,
    };
    final label = variacionPct == 0
        ? 'Sin variación vs ayer'
        : '${variacionPct > 0 ? '+' : ''}${variacionPct.toStringAsFixed(1)}% vs ayer';

    final chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DashboardSpacing.md,
        vertical: DashboardSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(DashboardRadius.sm),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: colors.fg),
          const SizedBox(width: DashboardSpacing.xs + 2),
          Text(
            label,
            style: TextStyle(
              color: colors.fg,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return chip;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DashboardRadius.sm),
      child: chip,
    );
  }

  _BadgeColors _colors(VariacionEstado estado) {
    return switch (estado) {
      VariacionEstado.positivo => _BadgeColors(
          fg: DashboardColors.positivoFg,
          bg: DashboardColors.positivoBg,
          border: DashboardColors.positivoBorder,
        ),
      VariacionEstado.negativo => _BadgeColors(
          fg: DashboardColors.negativoFg,
          bg: DashboardColors.negativoBg,
          border: DashboardColors.negativoBorder,
        ),
      VariacionEstado.neutro => _BadgeColors(
          fg: DashboardColors.neutroFg,
          bg: DashboardColors.neutroBg,
          border: DashboardColors.neutroFg.withValues(alpha: 0.2),
        ),
    };
  }
}

class _BadgeColors {
  final Color fg;
  final Color bg;
  final Color border;
  const _BadgeColors({required this.fg, required this.bg, required this.border});
}