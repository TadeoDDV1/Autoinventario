import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/animations/app_animations.dart';
import '../../core/widgets/glass_container.dart';
import 'dashboard_constants.dart';

class MetricaSecundariaCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final String subtitulo;
  final IconData icon;
  final Color colorIcono;
  final double? numericValue;
  final String valorPrefix;
  final String valorSuffix;

  const MetricaSecundariaCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.subtitulo,
    required this.icon,
    required this.colorIcono,
    this.numericValue,
    this.valorPrefix = '',
    this.valorSuffix = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      height: DashboardSizes.cardSecundariaHeight,
      padding: const EdgeInsets.all(DashboardSpacing.md),
      borderRadius: 20,
      borderColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorIcono.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: colorIcono),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: numericValue != null
                ? DashboardCounter(
                    target: numericValue!,
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    prefix: valorPrefix,
                    suffix: valorSuffix,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      height: 1.1,
                    ),
                  )
                : Text(
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