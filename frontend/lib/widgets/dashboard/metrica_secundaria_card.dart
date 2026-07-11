import 'package:flutter/material.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/widgets/glass_container.dart';
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
    return GlassContainer(
      height: DashboardSizes.cardSecundariaHeight,
      padding: const EdgeInsets.all(DashboardSpacing.md),
      borderRadius: DashboardRadius.md,
      blur: GlassTokens.blurSmall,
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