import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/format/money.dart';
import '../../models/sugerencia.dart';
import '../../providers/ia_provider.dart';
import '../../widgets/dashboard/dashboard_constants.dart';
import '../../widgets/dashboard/dashboard_layout.dart';
import '../../widgets/dashboard/dashboard_shimmer.dart';
import '../../widgets/dashboard/metrica_principal_card.dart';
import '../../widgets/dashboard/metrica_secundaria_card.dart';
import '../../widgets/dashboard/seccion_header.dart';
import '../../widgets/dashboard/stock_alert_list.dart';
import '../../widgets/dashboard/top_productos_list.dart';
import '../../widgets/dashboard/variacion_badge.dart';
import '../../widgets/dashboard/ventas_chart.dart';

/// Dashboard ejecutivo de inicio. Orquestador: compone los widgets
/// extraídos en `widgets/dashboard/` con un layout responsivo que
/// se adapta a mobile/tablet/desktop. Sin lógica de pintado propia.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resumenAsync = ref.watch(dashboardProvider);
    final width = MediaQuery.of(context).size.width;
    final variant = dashboardVariantDe(width);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(dashboardProvider),
      child: resumenAsync.when(
        data: (resumen) => _buildContent(context, ref, theme, resumen, variant),
        loading: () => const DashboardShimmer(),
        error: (e, _) => _buildError(context, ref, theme, e),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Object e,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DashboardSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: DashboardSpacing.lg),
            Text('No se pudo cargar el dashboard',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: DashboardSpacing.sm),
            Text('$e',
                style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: DashboardSpacing.lg),
            FilledButton.icon(
              onPressed: () => ref.invalidate(dashboardProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    DashboardResumen resumen,
    DashboardLayoutVariant variant,
  ) {
    final formatter = money;
    final maxWidth = variant == DashboardLayoutVariant.mobile
        ? double.infinity
        : (variant == DashboardLayoutVariant.tablet ? 720.0 : 1100.0);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: const EdgeInsets.all(DashboardSpacing.lg),
          children: [
            _buildHeader(context, ref, theme, resumen),
            const SizedBox(height: DashboardSpacing.lg),
            _buildMetricasRow(context, resumen, formatter, variant),
            if (variant == DashboardLayoutVariant.desktop) ...[
              const SizedBox(height: DashboardSpacing.lg),
              _buildTopYChartRow(context, ref, resumen),
            ] else ...[
              const SizedBox(height: DashboardSpacing.xl),
              _buildTopProductos(context, ref, resumen),
              const SizedBox(height: DashboardSpacing.xl),
              _buildStockAlertas(context, resumen),
              const SizedBox(height: DashboardSpacing.xl),
              _buildChart(context, resumen),
            ],
            const SizedBox(height: DashboardSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    DashboardResumen resumen,
  ) {
    final row = Row(
      children: [
        Icon(Icons.dashboard, color: theme.colorScheme.primary, size: 24),
        const SizedBox(width: DashboardSpacing.sm),
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
    );
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 200)),
        SlideEffect(begin: Offset(0, -0.05)),
      ],
      child: row,
    );
  }

  Widget _buildMetricasRow(
    BuildContext context,
    DashboardResumen resumen,
    NumberFormat formatter,
    DashboardLayoutVariant variant,
  ) {
    final heroRaw = MetricaPrincipalCard(
      titulo: 'Ventas hoy',
      valor: formatter.format(resumen.ventasHoy),
      subtitulo: '${resumen.transaccionesHoy} transacciones',
      meta: 'Ticket promedio: ${formatter.format(resumen.ticketPromedio)}',
      icon: Icons.payments,
      colorPrimario: Theme.of(context).colorScheme.primary,
      trailing: VariacionBadge(variacionPct: resumen.variacionPct),
    );
    final hero = Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 300)),
        SlideEffect(begin: Offset(0, 0.1)),
      ],
      child: heroRaw,
    );

    final secundariasRaw = [
      MetricaSecundariaCard(
        titulo: 'Efectivo',
        valor: formatter.format(resumen.ventasEfectivo),
        subtitulo: 'recaudado',
        icon: Icons.money,
        colorIcono: Colors.green.shade700,
      ),
      MetricaSecundariaCard(
        titulo: 'Tarjeta',
        valor: formatter.format(resumen.ventasTarjeta),
        subtitulo: 'recaudado',
        icon: Icons.credit_card,
        colorIcono: Colors.purple.shade700,
      ),
      MetricaSecundariaCard(
        titulo: 'Ticket prom.',
        valor: formatter.format(resumen.ticketPromedio),
        subtitulo: 'por venta',
        icon: Icons.receipt_long,
        colorIcono: Colors.blue.shade700,
      ),
    ];
    final secundarias = [
      for (var i = 0; i < secundariasRaw.length; i++)
        Animate(
          effects: [
            const FadeEffect(duration: Duration(milliseconds: 300)),
            const SlideEffect(begin: Offset(0, 0.1)),
          ],
          delay: Duration(milliseconds: 80 * (i + 1)),
          child: secundariasRaw[i],
        ),
    ];

    if (variant == DashboardLayoutVariant.desktop) {
      return Column(
        children: [
          hero,
          const SizedBox(height: DashboardSpacing.md),
          Row(
            children: [
              for (var i = 0; i < secundarias.length; i++) ...[
                Expanded(child: secundarias[i]),
                if (i < secundarias.length - 1)
                  const SizedBox(width: DashboardSpacing.md),
              ],
            ],
          ),
        ],
      );
    }
    return Column(
      children: [
        hero,
        const SizedBox(height: DashboardSpacing.md),
        for (var i = 0; i < secundarias.length; i++) ...[
          secundarias[i],
          if (i < secundarias.length - 1)
            const SizedBox(height: DashboardSpacing.sm),
        ],
      ],
    );
  }

  Widget _buildTopYChartRow(
    BuildContext context,
    WidgetRef ref,
    DashboardResumen resumen,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: _buildChart(context, resumen),
        ),
        const SizedBox(width: DashboardSpacing.md),
        Expanded(
          flex: 4,
          child: _buildTopProductos(context, ref, resumen),
        ),
      ],
    );
  }

  Widget _buildTopProductos(
    BuildContext context,
    WidgetRef ref,
    DashboardResumen resumen,
  ) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SeccionHeader(
          titulo: 'Top productos hoy',
          icon: Icons.star,
          badgeCount: 5,
        ),
        TopProductosList(productos: resumen.topProductos),
      ],
    );
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 300)),
        SlideEffect(begin: Offset(0, 0.05)),
      ],
      delay: const Duration(milliseconds: 200),
      child: content,
    );
  }

  Widget _buildStockAlertas(BuildContext context, DashboardResumen resumen) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SeccionHeader(
          titulo: 'Alertas de stock',
          icon: Icons.warning_amber_rounded,
          color: DashboardColors.advertenciaFg,
          badgeCount: resumen.stockBajo.length,
        ),
        StockAlertList(
          items: resumen.stockBajo,
          onVerTodas: () => context.go('/inventario'),
        ),
      ],
    );
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 300)),
        SlideEffect(begin: Offset(0, 0.05)),
      ],
      delay: const Duration(milliseconds: 280),
      child: content,
    );
  }

  Widget _buildChart(BuildContext context, DashboardResumen resumen) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SeccionHeader(
          titulo: 'Ventas últimos 7 días',
          icon: Icons.bar_chart,
        ),
        if (resumen.ventasUltimos7Dias.isEmpty)
          Container(
            padding: const EdgeInsets.all(DashboardSpacing.xl),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(DashboardRadius.md),
            ),
            child: Center(
              child: Text(
                'Sin datos de los últimos 7 días',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          VentasChart(dias: resumen.ventasUltimos7Dias),
      ],
    );
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 300)),
        SlideEffect(begin: Offset(0, 0.05)),
      ],
      delay: const Duration(milliseconds: 360),
      child: content,
    );
  }
}