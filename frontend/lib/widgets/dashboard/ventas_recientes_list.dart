import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/sugerencia.dart';
import 'dashboard_constants.dart';

class VentasRecientesList extends ConsumerWidget {
  final List<VentaReciente> ventas;

  const VentasRecientesList({super.key, required this.ventas});

  static const Map<String, IconData> _metodoIcon = {
    'efectivo': Icons.money,
    'tarjeta': Icons.credit_card,
    'transferencia': Icons.account_balance,
  };
  static final Map<String, Color Function(ColorScheme)> _metodoColor = {
    'efectivo': (s) => Colors.green.shade700,
    'tarjeta': (s) => Colors.purple.shade700,
    'transferencia': (s) => Colors.blue.shade700,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(
        locale: 'es_MX', symbol: r'$', decimalDigits: 2);
    final timeFormatter = DateFormat('HH:mm');

    if (ventas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: DashboardSpacing.xl),
        child: Center(
          child: Text('Sin ventas hoy',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline))
              .animate().fadeIn(duration: 400.ms),
        ),
      );
    }

    return Column(
      children: ventas.asMap().entries.map((entry) {
        final index = entry.key;
        final v = entry.value;
        final icon = _metodoIcon[v.metodoPago.toLowerCase()] ?? Icons.receipt;
        final colorFn = _metodoColor[v.metodoPago.toLowerCase()];
        final iconColor = colorFn != null ? colorFn(theme.colorScheme) : null;
        return InkWell(
          onTap: () => context.push('/caja/ticket', extra: v),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: DashboardSizes.rowListHeight,
            padding: const EdgeInsets.symmetric(horizontal: DashboardSpacing.sm),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (iconColor ?? theme.colorScheme.primary).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: iconColor ?? theme.colorScheme.primary),
                ).animate().scale(duration: 400.ms, delay: (index * 80).ms, curve: Curves.elasticOut),
                const SizedBox(width: DashboardSpacing.sm),
                Expanded(
                  flex: 3,
                  child: Text(
                    v.folio,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ).animate().fadeIn(duration: 300.ms, delay: (index * 80 + 50).ms),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    formatter.format(v.total),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: (index * 80 + 100).ms),
                ),
                const SizedBox(width: DashboardSpacing.sm),
                Text(
                  '${v.numProductos} prod.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (index * 80 + 150).ms),
                const SizedBox(width: DashboardSpacing.sm),
                Text(
                  timeFormatter.format(v.fecha),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontSize: 11,
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (index * 80 + 200).ms),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 350.ms, delay: (index * 80).ms)
          .slideX(begin: 0.1, curve: Curves.easeOutCubic);
      }).toList(),
    );
  }
}