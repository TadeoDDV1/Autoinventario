import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/format/money.dart';
import '../../models/sugerencia.dart';
import '../../providers/ia_provider.dart';
import '../../widgets/dashboard/dashboard_shimmer.dart';

/// Dashboard ejecutivo de inicio. Muestra resumen del día, top productos
/// y alertas de stock. Reemplaza la vista vacía anterior con información útil.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resumenAsync = ref.watch(dashboardProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(dashboardProvider),
      child: resumenAsync.when(
        data: (resumen) => _buildContent(context, ref, theme, resumen),
        loading: () => const DashboardShimmer(),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off,
                    size: 64, color: theme.colorScheme.outline),
                const SizedBox(height: 16),
                Text('No se pudo cargar el dashboard',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('$e',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(dashboardProvider),
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
    DashboardResumen resumen,
  ) {
    final formatter = money;
    final isPositive = resumen.variacionPct >= 0;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header con saludo
        Row(
          children: [
            Icon(Icons.dashboard, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Text(
              'DASHBOARD',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => context.push('/chat'),
              icon: const Icon(Icons.chat_bubble_outline),
              tooltip: 'Asistente ejecutivo',
            ),
            IconButton(
              onPressed: () => ref.invalidate(dashboardProvider),
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _saludo() + ' • ${resumen.fecha}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),

        // Cards de métricas principales
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _MetricaCard(
              titulo: 'Ventas hoy',
              valor: formatter.format(resumen.ventasHoy),
              icon: Icons.payments,
              color: Colors.green.shade600,
              subtitulo: '${resumen.transaccionesHoy} transacciones',
            ),
            _MetricaCard(
              titulo: 'Ticket promedio',
              valor: formatter.format(resumen.ticketPromedio),
              icon: Icons.receipt,
              color: Colors.blue.shade600,
              subtitulo: 'por venta',
            ),
            _MetricaCard(
              titulo: 'Efectivo',
              valor: formatter.format(resumen.ventasEfectivo),
              icon: Icons.money,
              color: Colors.amber.shade700,
              subtitulo: 'recaudado',
            ),
            _MetricaCard(
              titulo: 'Tarjeta',
              valor: formatter.format(resumen.ventasTarjeta),
              icon: Icons.credit_card,
              color: Colors.purple.shade600,
              subtitulo: 'recaudado',
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Variación vs ayer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isPositive
                ? Colors.green.shade50
                : (resumen.variacionPct < 0
                    ? Colors.red.shade50
                    : theme.colorScheme.surfaceContainerHighest),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPositive
                  ? Colors.green.shade200
                  : (resumen.variacionPct < 0
                      ? Colors.red.shade200
                      : theme.colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isPositive
                    ? Icons.trending_up
                    : (resumen.variacionPct < 0
                        ? Icons.trending_down
                        : Icons.trending_flat),
                color: isPositive
                    ? Colors.green.shade700
                    : (resumen.variacionPct < 0
                        ? Colors.red.shade700
                        : Colors.grey.shade600),
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Variación vs ayer',
                      style: theme.textTheme.labelMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      resumen.variacionPct == 0
                          ? 'Sin variación'
                          : '${isPositive ? '+' : ''}${resumen.variacionPct.toStringAsFixed(1)}%',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPositive
                            ? Colors.green.shade800
                            : (resumen.variacionPct < 0
                                ? Colors.red.shade800
                                : null),
                      ),
                    ),
                    Text(
                      'Ayer: ${formatter.format(resumen.ventasAyer)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Top productos
        if (resumen.topProductos.isNotEmpty) ...[
          _SeccionHeader(
            titulo: 'Top productos hoy',
            icon: Icons.star,
          ),
          const SizedBox(height: 8),
          ...resumen.topProductos.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(p.nombre),
                subtitle: Text('${p.cantidad} unidades'),
                trailing: Text(
                  formatter.format(p.totalVenta),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
        ] else
          _EmptyHint(
            icon: Icons.shopping_bag,
            mensaje: 'Aún no hay ventas hoy',
            detalle: 'Cuando registres ventas aparecerán aquí',
          ),

        const SizedBox(height: 24),

        // Stock bajo
        if (resumen.stockBajo.isNotEmpty) ...[
          _SeccionHeader(
            titulo: 'Alertas de stock',
            icon: Icons.warning_amber_rounded,
            color: Colors.orange.shade700,
          ),
          const SizedBox(height: 8),
          ...resumen.stockBajo.map((sb) => Card(
                color: Colors.orange.shade50,
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: Icon(Icons.inventory_2,
                      color: Colors.orange.shade700),
                  title: Text(sb.nombre),
                  subtitle: Text(
                      'Stock: ${sb.stockActual} / Mínimo: ${sb.stockMin}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => context.go('/inventario'),
                ),
              )),
        ],

        const SizedBox(height: 24),

        // Ventas últimos 7 días (gráfico simple de barras)
        if (resumen.ventasUltimos7Dias.isNotEmpty) ...[
          _SeccionHeader(
            titulo: 'Ventas últimos 7 días',
            icon: Icons.bar_chart,
          ),
          const SizedBox(height: 8),
          _VentasChart(dias: resumen.ventasUltimos7Dias, formatter: formatter),
        ],
      ],
    );
  }

  String _saludo() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días';
    if (hora < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }
}

class _MetricaCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icon;
  final Color color;
  final String subtitulo;

  const _MetricaCard({
    required this.titulo,
    required this.valor,
    required this.icon,
    required this.color,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            valor,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitulo,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeccionHeader extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final Color? color;

  const _SeccionHeader({
    required this.titulo,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    return Row(
      children: [
        Icon(icon, color: c, size: 20),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String mensaje;
  final String detalle;

  const _EmptyHint({
    required this.icon,
    required this.mensaje,
    required this.detalle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 8),
          Text(mensaje, style: theme.textTheme.titleSmall),
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

class _VentasChart extends StatelessWidget {
  final List<VentasDia> dias;
  final NumberFormat formatter;

  const _VentasChart({required this.dias, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxVenta = dias.fold<double>(0, (m, d) => d.totalVentas > m ? d.totalVentas : m);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dias.map((d) {
                final heightFactor = maxVenta == 0 ? 0.0 : d.totalVentas / maxVenta;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          formatter.format(d.totalVentas),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 90 * heightFactor + 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withValues(alpha: 0.4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: dias.map((d) {
              return Expanded(
                child: Text(
                  _shortDay(d.fecha),
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _shortDay(String iso) {
    try {
      final dt = DateTime.parse(iso);
      const dias = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
      return dias[dt.weekday - 1];
    } catch (_) {
      return iso;
    }
  }
}
