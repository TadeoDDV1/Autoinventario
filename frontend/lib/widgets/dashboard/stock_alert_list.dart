import 'package:flutter/material.dart';
import '../../models/sugerencia.dart';
import 'dashboard_constants.dart';

/// Lista compacta de productos con stock bajo. Cada fila:
///   - Icono de advertencia naranja.
///   - Nombre + razón ("Stock: 3 / Mínimo: 10").
///   - Chevron a la derecha (tap → navegar a inventario).
class StockAlertList extends StatelessWidget {
  final List<StockBajoItem> items;
  final VoidCallback? onVerTodas;

  const StockAlertList({
    super.key,
    required this.items,
    this.onVerTodas,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(DashboardSpacing.xl),
        decoration: BoxDecoration(
          color: DashboardColors.positivoBg,
          borderRadius: BorderRadius.circular(DashboardRadius.md),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: DashboardColors.positivoFg),
            const SizedBox(width: DashboardSpacing.md),
            Expanded(
              child: Text(
                'Todo el stock está por encima del mínimo',
                style: TextStyle(
                  color: DashboardColors.positivoFg,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: DashboardColors.advertenciaBg,
        borderRadius: BorderRadius.circular(DashboardRadius.md),
        border: Border.all(color: DashboardColors.advertenciaBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _StockAlertRow(item: items[i]),
            if (i < items.length - 1)
              Divider(
                height: 1,
                color: DashboardColors.advertenciaBorder.withValues(alpha: 0.5),
                indent: DashboardSpacing.md,
                endIndent: DashboardSpacing.md,
              ),
          ],
          if (onVerTodas != null)
            Padding(
              padding: const EdgeInsets.all(DashboardSpacing.sm),
              child: TextButton.icon(
                onPressed: onVerTodas,
                icon: Icon(Icons.arrow_forward, size: 16,
                    color: DashboardColors.advertenciaFg),
                label: Text(
                  'Ver todos en inventario',
                  style: TextStyle(
                    color: DashboardColors.advertenciaFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StockAlertRow extends StatelessWidget {
  final StockBajoItem item;
  const _StockAlertRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urgente = item.stockActual <= item.stockMin / 2;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DashboardSpacing.md,
        vertical: DashboardSpacing.md,
      ),
      child: Row(
        children: [
          Icon(
            urgente ? Icons.error_outline : Icons.warning_amber_rounded,
            color: DashboardColors.advertenciaFg,
            size: 20,
          ),
          const SizedBox(width: DashboardSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombre,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Stock: ${item.stockActual} / Mínimo: ${item.stockMin}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: DashboardColors.advertenciaFg,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 18,
            color: theme.colorScheme.outline,
          ),
        ],
      ),
    );
  }
}