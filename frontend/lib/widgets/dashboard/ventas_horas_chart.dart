import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final maxVenta = widget.horas.fold<double>(
      0,
      (m, h) => h.totalVentas > m ? h.totalVentas : m,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(
        DashboardSpacing.md,
        DashboardSpacing.md,
        DashboardSpacing.md,
        DashboardSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(DashboardRadius.md),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: DashboardSizes.chartHeight,
                child: CustomPaint(
                  painter: _HoursChartPainter(
                    horas: widget.horas,
                    maxVenta: maxVenta,
                    primary: theme.colorScheme.primary,
                    gridLine: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.3),
                    axisLabel: theme.colorScheme.outline,
                    selectedIndex: _selectedIndex,
                  ),
                  size: Size(
                      constraints.maxWidth, DashboardSizes.chartHeight),
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
          );
        },
      ),
    );
  }
}

class _HoursChartPainter extends CustomPainter {
  final List<VentaHora> horas;
  final double maxVenta;
  final Color primary;
  final Color gridLine;
  final Color axisLabel;
  final int? selectedIndex;

  _HoursChartPainter({
    required this.horas,
    required this.maxVenta,
    required this.primary,
    required this.gridLine,
    required this.axisLabel,
    required this.selectedIndex,
  });

  static const double _labelAreaHeight = 14;
  static const double _leftAxisWidth = 32;

  @override
  void paint(Canvas canvas, Size size) {
    if (horas.isEmpty) return;
    final paintGrid = Paint()
      ..color = gridLine
      ..strokeWidth = 1;

    final chartTop = 0.0;
    final chartBottom = size.height - _labelAreaHeight;
    final chartHeight = chartBottom - chartTop;
    final chartLeft = _leftAxisWidth;
    final chartWidth = size.width - chartLeft;

    for (var i = 0; i <= 2; i++) {
      final y = chartBottom - (chartHeight * i / 2);
      canvas.drawLine(
        Offset(chartLeft, y),
        Offset(size.width, y),
        paintGrid,
      );
    }

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    for (var i = 0; i <= 2; i++) {
      final value = maxVenta * i / 2;
      final compact = NumberFormat.compactCurrency(
        locale: 'es_MX',
        symbol: r'$',
        decimalDigits: 0,
      ).format(value);
      textPainter.text = TextSpan(
        text: compact,
        style: TextStyle(color: axisLabel, fontSize: 10),
      );
      textPainter.layout();
      final y = chartBottom - (chartHeight * i / 2);
      textPainter.paint(
        canvas,
        Offset(0, y - textPainter.height / 2),
      );
    }

    if (horas.isEmpty || maxVenta == 0) return;
    final barAreaWidth = chartWidth / horas.length;
    final barWidth = math.max((barAreaWidth * 0.6).clamp(4.0, 20.0), 4.0);
    for (var i = 0; i < horas.length; i++) {
      final h = horas[i];
      final ratio = h.totalVentas / maxVenta;
      final barH = chartHeight * ratio;
      final x = chartLeft + barAreaWidth * i + (barAreaWidth - barWidth) / 2;
      final y = chartBottom - barH;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barH),
        const Radius.circular(2),
      );
      final isSelected = i == selectedIndex;
      canvas.drawRRect(
        rect,
        Paint()
          ..color = isSelected
              ? primary
              : primary.withValues(alpha: 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_HoursChartPainter old) =>
      old.horas != horas ||
      old.maxVenta != maxVenta ||
      old.selectedIndex != selectedIndex;
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
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(DashboardRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time,
              size: 12, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: DashboardSpacing.xs + 2),
          Text(
            '$label: ${formatter.format(hora.totalVentas)}',
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
