import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/animations/app_animations.dart';
import '../../models/sugerencia.dart';
import 'dashboard_constants.dart';

class VentasHorasChart extends StatefulWidget {
  final List<VentaHora> horas;

  const VentasHorasChart({super.key, required this.horas});

  @override
  State<VentasHorasChart> createState() => _VentasHorasChartState();
}

class _VentasHorasChartState extends State<VentasHorasChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.compactCurrency(
      locale: 'es_MX',
      symbol: r'$',
      decimalDigits: 0,
    );

    final values = widget.horas.map((h) => h.totalVentas).toList();
    final labels = widget.horas.map((h) => '${h.hora.toString().padLeft(2, '0')}:00').toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(
        DashboardSpacing.md,
        DashboardSpacing.md,
        DashboardSpacing.md,
        DashboardSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 160,
            child: AnimatedBarChart(
              values: values,
              labels: labels,
              barColor: theme.colorScheme.secondary,
              backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
              maxHeight: 140,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              barWidth: 20,
              spacing: 4,
              tooltipBuilder: (value, label) {
                final index = labels.indexOf(label);
                if (index >= 0 && index < widget.horas.length) {
                  final hora = widget.horas[index];
                  return _TooltipWidget(
                    hora: hora,
                    formatter: formatter,
                    label: label,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          const SizedBox(height: DashboardSpacing.sm),
          Row(
            children: [0, 6, 12, 18].map((h) {
              final idx = widget.horas.indexWhere((vh) => vh.hora == h);
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIndex =
                      idx == _selectedIndex ? null : idx),
                  child: Text(
                    '${h.toString().padLeft(2, '0')}:00',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedIndex != null) ...[
            const SizedBox(height: DashboardSpacing.sm),
            _SelectedHourTooltip(
              hora: widget.horas[_selectedIndex!],
              formatter: formatter,
            ),
          ],
        ],
      ),
    );
  }
}

class _TooltipWidget extends StatelessWidget {
  final VentaHora hora;
  final NumberFormat formatter;
  final String label;

  const _TooltipWidget({
    required this.hora,
    required this.formatter,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time,
              size: 10, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: 4),
          Text(
            '$label: ${formatter.format(hora.totalVentas)} (${hora.transacciones} ventas)',
            style: TextStyle(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedHourTooltip extends StatelessWidget {
  final VentaHora hora;
  final NumberFormat formatter;
  const _SelectedHourTooltip({required this.hora, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label =
        '${hora.hora.toString().padLeft(2, '0')}:00 - ${hora.transacciones} ventas';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DashboardSpacing.md,
        vertical: DashboardSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(DashboardRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time,
              size: 12, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: DashboardSpacing.xs + 2),
          Text(
            '$label: ${formatter.format(hora.totalVentas)}',
            style: TextStyle(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}