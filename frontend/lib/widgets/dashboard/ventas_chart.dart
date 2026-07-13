import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/sugerencia.dart';
import 'dashboard_constants.dart';

/// Gráfico de barras de los últimos 7 días con CustomPaint.
///
/// - Eje Y con 3 gridlines sutiles (0, mitad, máximo) usando
///   outlineVariant.withOpacity(0.3).
/// - Cada barra coloreada con el primary color del tema.
/// - Etiqueta de día (L M M J V S D) arriba del número corto del mes.
/// - Tap sobre una barra muestra el monto en un tooltip.
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
    final maxVenta = widget.dias.fold<double>(
      0,
      (m, d) => d.totalVentas > m ? d.totalVentas : m,
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
                  painter: _ChartPainter(
                    dias: widget.dias,
                    maxVenta: maxVenta,
                    primary: theme.colorScheme.primary,
                    gridLine: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.3),
                    axisLabel: theme.colorScheme.outline,
                    selectedIndex: _selectedIndex,
                  ),
                  size: Size(constraints.maxWidth,
                      DashboardSizes.chartHeight),
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
          );
        },
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<VentasDia> dias;
  final double maxVenta;
  final Color primary;
  final Color gridLine;
  final Color axisLabel;
  final int? selectedIndex;

  _ChartPainter({
    required this.dias,
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
    if (dias.isEmpty) return;
    final paintGrid = Paint()
      ..color = gridLine
      ..strokeWidth = 1;

    final chartTop = 0.0;
    final chartBottom = size.height - _labelAreaHeight;
    final chartHeight = chartBottom - chartTop;
    final chartLeft = _leftAxisWidth;
    final chartWidth = size.width - chartLeft;

    // Gridlines horizontales (3 niveles: 0, 50%, 100%)
    for (var i = 0; i <= 2; i++) {
      final y = chartBottom - (chartHeight * i / 2);
      canvas.drawLine(
        Offset(chartLeft, y),
        Offset(size.width, y),
        paintGrid,
      );
    }

    // Etiquetas del eje Y (formato compacto)
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

    // Barras
    if (dias.isEmpty || maxVenta == 0) return;
    final barAreaWidth = chartWidth / dias.length;
    final barWidth = (barAreaWidth * 0.6).clamp(8.0, 36.0);
    for (var i = 0; i < dias.length; i++) {
      final d = dias[i];
      final ratio = d.totalVentas / maxVenta;
      final h = chartHeight * ratio;
      final x = chartLeft + barAreaWidth * i + (barAreaWidth - barWidth) / 2;
      final y = chartBottom - h;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, h),
        const Radius.circular(4),
      );
      final isSelected = i == selectedIndex;
      canvas.drawRRect(
        rect,
        Paint()
          ..color = isSelected
              ? primary
              : primary.withValues(alpha: 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.dias != dias ||
      old.maxVenta != maxVenta ||
      old.selectedIndex != selectedIndex;
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
      // Si falla el parse, mostrar la fecha raw
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