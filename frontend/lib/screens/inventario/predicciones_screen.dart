import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/format/money.dart';
import '../../models/sugerencia.dart';
import '../../providers/ia_provider.dart';

/// Pantalla de predicciones de inventario.
/// Muestra un análisis IA del stock vs ritmo de ventas, ordenado por urgencia.
class PrediccionesScreen extends ConsumerWidget {
  const PrediccionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prediccionesAsync = ref.watch(prediccionesInventarioProvider);
    final formatter = money;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(prediccionesInventarioProvider),
      child: prediccionesAsync.when(
        data: (resumen) => _buildContent(context, ref, theme, resumen, formatter),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off,
                    size: 64, color: theme.colorScheme.outline),
                const SizedBox(height: 16),
                Text('No se pudo analizar el inventario',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('$e',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(prediccionesInventarioProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    PrediccionesResumen resumen,
    NumberFormat formatter,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Row(
          children: [
            IconButton(
              onPressed: () => context.go('/inventario'),
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Volver a inventario',
            ),
            const SizedBox(width: 4),
            Icon(Icons.auto_graph, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'ANÁLISIS PREDICTIVO',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            IconButton(
              onPressed: () =>
                  ref.invalidate(prediccionesInventarioProvider),
              icon: const Icon(Icons.refresh),
              tooltip: 'Recalcular',
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 48),
          child: Text(
            'Stock vs ritmo de ventas • ${resumen.fechaAnalisis}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Recomendaciones IA (caja destacada)
        if (resumen.recomendaciones.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.tertiaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tips_and_updates,
                        color: theme.colorScheme.onPrimaryContainer),
                    const SizedBox(width: 8),
                    Text(
                      'Recomendaciones IA',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...resumen.recomendaciones.map((rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.fiber_manual_record, size: 8),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rec,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color:
                                    theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Métricas globales
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.7,
          children: [
            _MetricaCard(
              titulo: 'Críticos',
              valor: '${resumen.productosCriticos}',
              icon: Icons.error,
              color: Colors.red.shade700,
              subtitulo: 'agotarse pronto',
              onTap: () => _scrollToUrgencia(context, ref, 'critico'),
            ),
            _MetricaCard(
              titulo: 'Urgentes',
              valor: '${resumen.productosUrgentes}',
              icon: Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
              subtitulo: '≤ 7 días',
              onTap: () => _scrollToUrgencia(context, ref, 'urgente'),
            ),
            _MetricaCard(
              titulo: 'Sin ventas',
              valor: '${resumen.productosSinVentas}',
              icon: Icons.trending_down,
              color: Colors.grey.shade600,
              subtitulo: 'últimos 30 días',
            ),
            _MetricaCard(
              titulo: 'Dormidos',
              valor: '${resumen.productosDormidos}',
              icon: Icons.bedtime,
              color: Colors.brown.shade400,
              subtitulo: '60+ días sin venta',
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Valor en riesgo
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: resumen.valorCritico > 0
                ? Colors.red.shade50
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: resumen.valorCritico > 0
                  ? Colors.red.shade200
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Icon(
                resumen.valorCritico > 0
                    ? Icons.warning
                    : Icons.check_circle,
                color: resumen.valorCritico > 0
                    ? Colors.red.shade700
                    : Colors.green.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resumen.valorCritico > 0
                          ? 'Valor en riesgo de agotarse'
                          : 'Sin riesgo de agotamiento',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      resumen.valorCritico > 0
                          ? 'Inventario crítico + urgente'
                          : 'Todos los productos tienen cobertura > 7 días',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatter.format(resumen.valorCritico),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: resumen.valorCritico > 0
                      ? Colors.red.shade700
                      : Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Lista priorizada
        Row(
          children: [
            Icon(Icons.list_alt, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Productos priorizados',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (resumen.topCriticos.isEmpty)
          _EmptyState(
            icon: Icons.check_circle,
            titulo: 'Todo bajo control',
            detalle: 'No hay productos que requieran atención urgente',
          )
        else
          ...resumen.topCriticos.asMap().entries.map((entry) {
            final p = entry.value;
            return _PrediccionCard(prediccion: p, formatter: formatter);
          }),
      ],
    );
  }

  void _scrollToUrgencia(BuildContext context, WidgetRef ref, String nivel) {
    // El filtro no lo implementamos (la lista es corta), pero podríamos
    // navegar al inventario con query param. Por ahora solo toast.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mostrando productos $nivel'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _MetricaCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icon;
  final Color color;
  final String subtitulo;
  final VoidCallback? onTap;

  const _MetricaCard({
    required this.titulo,
    required this.valor,
    required this.icon,
    required this.color,
    required this.subtitulo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      titulo,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                valor,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                subtitulo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrediccionCard extends StatelessWidget {
  final PrediccionInventario prediccion;
  final NumberFormat formatter;

  const _PrediccionCard({required this.prediccion, required this.formatter});

  Color _urgencyColor() {
    switch (prediccion.nivelUrgencia) {
      case 'critico':
        return Colors.red.shade700;
      case 'urgente':
        return Colors.orange.shade700;
      case 'sin_ventas':
        return Colors.grey.shade600;
      case 'muerto':
        return Colors.brown.shade400;
      default:
        return Colors.blue.shade600;
    }
  }

  IconData _urgencyIcon() {
    switch (prediccion.nivelUrgencia) {
      case 'critico':
        return Icons.error;
      case 'urgente':
        return Icons.warning_amber_rounded;
      case 'sin_ventas':
        return Icons.trending_down;
      case 'muerto':
        return Icons.bedtime;
      default:
        return Icons.check_circle_outline;
    }
  }

  String _urgencyLabel() {
    switch (prediccion.nivelUrgencia) {
      case 'critico':
        return 'CRÍTICO';
      case 'urgente':
        return 'URGENTE';
      case 'sin_ventas':
        return 'SIN VENTAS';
      case 'muerto':
        return 'DORMIDO';
      default:
        return 'NORMAL';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _urgencyColor();
    final icon = _urgencyIcon();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prediccion.nombre,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        prediccion.categoria,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _urgencyLabel(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Métricas en fila
            Row(
              children: [
                _MiniMetrica(
                  label: 'Stock',
                  valor: '${prediccion.stockActual}',
                  sublabel: 'mín ${prediccion.stockMinimo}',
                  color: prediccion.stockActual <= prediccion.stockMinimo
                      ? Colors.red
                      : null,
                ),
                _MiniMetrica(
                  label: 'Días restantes',
                  valor: prediccion.diasRestantes == 0
                      ? '∞'
                      : prediccion.diasRestantes.toStringAsFixed(0),
                  sublabel: prediccion.fechaAgotamiento.isNotEmpty
                      ? '~${prediccion.fechaAgotamiento}'
                      : 'sin ventas',
                  color: prediccion.diasRestantes > 0 &&
                          prediccion.diasRestantes <= 7
                      ? Colors.orange
                      : null,
                ),
                _MiniMetrica(
                  label: 'Venta/día',
                  valor: prediccion.promedioDiario.toStringAsFixed(2),
                  sublabel: '${prediccion.vendidosUltimos30D} / 30d',
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Razón principal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      prediccion.razon,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sugerencia de reorden
            if (prediccion.cantidadSugerida > 0) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sugerencia: pedir ${prediccion.cantidadSugerida} unidades',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                    Text(
                      formatter.format(
                          prediccion.cantidadSugerida * prediccion.precioVenta),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniMetrica extends StatelessWidget {
  final String label;
  final String valor;
  final String sublabel;
  final Color? color;

  const _MiniMetrica({
    required this.label,
    required this.valor,
    required this.sublabel,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.onSurface;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            valor,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: c,
            ),
          ),
          Text(
            sublabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String detalle;

  const _EmptyState({
    required this.icon,
    required this.titulo,
    required this.detalle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.green.shade600),
          const SizedBox(height: 8),
          Text(titulo,
              style: theme.textTheme.titleSmall
                  ?.copyWith(color: Colors.green.shade800)),
          const SizedBox(height: 4),
          Text(
            detalle,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
