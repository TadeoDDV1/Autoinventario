import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/animations/app_animations.dart';
import '../../core/widgets/glass_container.dart';
import 'dashboard_constants.dart';

class MetricaPrincipalCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final String subtitulo;
  final String? meta;
  final IconData icon;
  final Color colorPrimario;
  final Widget? trailing;
  final double? numericValue;
  final String valorPrefix;
  final String valorSuffix;

  const MetricaPrincipalCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.subtitulo,
    this.meta,
    required this.icon,
    required this.colorPrimario,
    this.trailing,
    this.numericValue,
    this.valorPrefix = '',
    this.valorSuffix = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      borderRadius: 24,
      borderColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: colorPrimario,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: colorPrimario.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(icon, color: colorPrimario, size: 16),
                              ),
                              const SizedBox(width: DashboardSpacing.sm),
                              Flexible(
                                child: Text(
                                  titulo.toUpperCase(),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
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
                            child: numericValue != null
                                ? DashboardCounter(
                                    target: numericValue!,
                                    duration: const Duration(milliseconds: 1200),
                                    curve: Curves.easeOutCubic,
                                    prefix: valorPrefix,
                                    suffix: valorSuffix,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.onSurface,
                                      height: 1.1,
                                    ),
                                  )
                                : Text(
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