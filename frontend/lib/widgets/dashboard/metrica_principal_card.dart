import 'package:flutter/material.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/widgets/glass_container.dart';
import 'dashboard_constants.dart';

/// Hero card: la métrica principal del dashboard (Ventas hoy).
/// Diseño:
///   - Borde izquierdo acentuado de 4pt en color primario (clipado).
///   - Valor a 32pt w800.
///   - Subtítulo con icono + texto de soporte.
///   - Padding generoso (20).
class MetricaPrincipalCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final String subtitulo;
  final String? meta;
  final IconData icon;
  final Color colorPrimario;
  final Widget? trailing;

  const MetricaPrincipalCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.subtitulo,
    this.meta,
    required this.icon,
    required this.colorPrimario,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      borderRadius: DashboardRadius.lg,
      blur: GlassTokens.blurSmall,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: colorPrimario),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(DashboardSpacing.xl - 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(icon, color: colorPrimario, size: 18),
                              const SizedBox(width: DashboardSpacing.sm),
                              Flexible(
                                child: Text(
                                  titulo.toUpperCase(),
                                  style: theme.textTheme.labelMedium
                                      ?.copyWith(
                                    color: theme
                                        .colorScheme.onSurfaceVariant,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: DashboardSpacing.sm),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              valor,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: DashboardSpacing.xs),
                          Text(
                            subtitulo,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (meta != null) ...[
                            const SizedBox(height: DashboardSpacing.xs),
                            Text(
                              meta!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: DashboardSpacing.md),
                      trailing!,
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}