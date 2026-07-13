import 'package:flutter/material.dart';

import '../../core/format/money.dart';

/// Banner que muestra en vivo la ganancia unitaria y el margen % calculado
/// entre precio de compra y precio de venta. Aparece sólo cuando el usuario
/// ha capturado ambos precios.
///
/// Color del margen:
///  - verde si >= 30%
///  - ámbar si 10-30%
///  - rojo si < 10% o margen negativo
class MargenBanner extends StatelessWidget {
  final double precioCompra;
  final double precioVenta;

  const MargenBanner({
    super.key,
    required this.precioCompra,
    required this.precioVenta,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (precioCompra <= 0 || precioVenta <= 0) {
      return const SizedBox.shrink();
    }

    final ganancia = precioVenta - precioCompra;
    final margen = (ganancia / precioCompra) * 100;
    final color = _colorFor(margen, theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ganancia: ${money.format(ganancia)} c/u',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  'Margen ${margen.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          if (precioVenta > 0 && precioCompra > 0)
            Text(
              '${((ganancia / precioVenta) * 100).toStringAsFixed(1)}% s/venta',
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
        ],
      ),
    );
  }

  Color _colorFor(double margen, ThemeData theme) {
    if (margen < 10) return Colors.red.shade600;
    if (margen < 30) return Colors.amber.shade700;
    return Colors.green.shade600;
  }
}