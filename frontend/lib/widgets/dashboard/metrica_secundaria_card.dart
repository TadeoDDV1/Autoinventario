import 'package:flutter/material.dart';
import 'dashboard_constants.dart';

/// Card de métrica secundaria. Más compacta que [MetricaPrincipalCard]:
///   - Icono a la derecha (no a la izquierda).
///   - Valor a 18pt w700.
///   - Altura fija de DashboardSizes.cardSecundariaHeight.
///   - Sin sombras pesadas — solo un borde sutil.
class MetricaSecundariaCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final String subtitulo;
  final IconData icon;
  final Color colorIcono;

  const MetricaSecundariaCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.subtitulo,
    required this.icon,
    required this.colorIcono,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: DashboardSizes.cardSecundariaHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(DashboardRadius.md),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(DashboardSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 18, color: colorIcono),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                height: 1.1,
              ),
            ),
          ),
          Text(
            subtitulo,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}