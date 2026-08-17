import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/animations/app_animations.dart';
import '../../models/sugerencia.dart';
import 'dashboard_constants.dart';

class VentasChart extends StatefulWidget {
  final List<VentasDia> dias;

  const VentasChart({super.key, required this.dias});

  @override
  State<VentasChart> createState() => _VentasChartState();
}

class _VentasChartState extends State<VentasChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.compactCurrency(
      locale: 'es_MX',
      symbol: r'$',
      decimalDigits: 0,
    );

    final values = widget.dias.map((d) => d.totalVentas).toList();
    final labels = widget.dias.map((d) {
      try {
        final dt = DateTime.parse(d.fecha);
        const dias = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
        return dias[dt.weekday - 1];
      } catch (_) {
        return d.fecha;
      }
    }).toList();

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
              barColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
              maxHeight: 140,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              barWidth: 28,
              spacing: 8,
              tooltipBuilder: (value, label) {
                final index = labels.indexOf(label);
                if (index >= 0 && index < widget.dias.length) {
                  final dia = widget.dias[index];
                  return _TooltipWidget(
                    dia: dia,
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
            children: [
              for (var i = 0; i < widget.dias.length; i++)
                Expanded(
                  child: _DayLabel(
                    fecha: widget.dias[i].fecha,
                    onTap: () => setState(
                        () => _selectedIndex = i == _selectedIndex ? null : i),
                  ),
                ),
            ],
          ),
          if (_selectedIndex != null) ...[
            const SizedBox(height: DashboardSpacing.sm),
            _SelectedTooltip(
              dia: widget.dias[_selectedIndex!],
              formatter: formatter,
            ),
          ],
        ],
      ),
    );
  }
}

class _TooltipWidget extends StatelessWidget {
  final VentasDia dia;
  final NumberFormat formatter;
  final String label;

  const _TooltipWidget({
    required this.dia,
    required this.formatter,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String dayLabel = label;
    try {
      final dt = DateTime.parse(dia.fecha);
      const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      dayLabel = '${dias[dt.weekday - 1]} ${dt.day}';
    } catch (_) {
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today,
              size: 10, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            '$dayLabel: ${formatter.format(dia.totalVentas)}',
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String fecha;
  final VoidCallback onTap;
  const _DayLabel({required this.fecha, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String day = '';
    String num = '';
    try {
      final dt = DateTime.parse(fecha);
      const dias = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
      day = dias[dt.weekday - 1];
      num = '${dt.day}';
    } catch (_) {
      day = fecha;
    }
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(day,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              )),
          Text(num,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: theme.colorScheme.outline,
              )),
        ],
      ),
    );
  }
}

class _SelectedTooltip extends StatelessWidget {
  final VentasDia dia;
  final NumberFormat formatter;
  const _SelectedTooltip({required this.dia, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String label = dia.fecha;
    try {
      final dt = DateTime.parse(dia.fecha);
      const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      label = '${dias[dt.weekday - 1]} ${dt.day}';
    } catch (_) {
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DashboardSpacing.md,
        vertical: DashboardSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(DashboardRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today,
              size: 12, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: DashboardSpacing.xs + 2),
          Text(
            '$label: ${formatter.format(dia.totalVentas)}',
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}