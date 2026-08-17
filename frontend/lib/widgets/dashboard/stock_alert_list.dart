import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/sugerencia.dart';
import 'dashboard_constants.dart';

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
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700)
                .animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.5, 0.5)),
            const SizedBox(width: DashboardSpacing.md),
            Expanded(
              child: Text(
                'Todo el stock está por encima del mínimo',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
            ),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _StockAlertRow(item: items[i])
                .animate()
                .fadeIn(duration: 350.ms, delay: (i * 80).ms)
                .slideX(begin: 0.15, curve: Curves.easeOutCubic),
            if (i < items.length - 1)
              Divider(
                height: 1,
                color: Colors.amber.withValues(alpha: 0.3),
                indent: DashboardSpacing.md,
                endIndent: DashboardSpacing.md,
              ),
          ],
          if (onVerTodas != null)
            Padding(
              padding: const EdgeInsets.all(DashboardSpacing.sm),
              child: TextButton.icon(
                onPressed: onVerTodas,
                icon: Icon(Icons.arrow_forward, size: 16, color: Colors.amber.shade800),
                label: Text(
                  'Ver todos en inventario',
                  style: TextStyle(
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
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
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: urgente
                  ? Colors.red.withValues(alpha: 0.12)
                  : Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              urgente ? Icons.error_outline : Icons.warning_amber_rounded,
              color: urgente ? Colors.red.shade700 : Colors.amber.shade800,
              size: 18,
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
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
                    color: urgente ? Colors.red.shade700 : Colors.amber.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 18,
            color: theme.colorScheme.outline,
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
        ],
      ),
    );
  }
}