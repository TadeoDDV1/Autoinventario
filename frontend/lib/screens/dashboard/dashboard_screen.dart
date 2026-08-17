import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/format/money.dart';
import '../../core/widgets/atmospheric_background.dart';
import '../../core/widgets/glass_container.dart';
import '../../models/sugerencia.dart';
import '../../providers/ia_provider.dart';
import '../../widgets/common/shimmer_loading.dart';
import '../../widgets/dashboard/dashboard_constants.dart';
import '../../widgets/dashboard/dashboard_layout.dart';
import '../../widgets/dashboard/metrica_principal_card.dart';
import '../../widgets/dashboard/metrica_secundaria_card.dart';
import '../../widgets/dashboard/seccion_header.dart';
import '../../widgets/dashboard/stock_alert_list.dart';
import '../../widgets/dashboard/top_productos_list.dart';
import '../../widgets/dashboard/variacion_badge.dart';
import '../../widgets/dashboard/ventas_chart.dart';
import '../../widgets/dashboard/ventas_horas_chart.dart';
import '../../widgets/dashboard/ventas_recientes_list.dart';

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
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      child: resumenAsync.when(
        data: (resumen) => _buildContent(context, ref, theme, resumen, variant),
        loading: () => _buildLoading(context),
        error: (e, _) => _buildError(context, ref, theme, e),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Stack(
      children: [
        const AtmosphericBackground(),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: const ShimmerDashboard(
              cardCount: 4,
              chartHeight: 200,
              listItems: 5,
            ),
          ),
        ),
      ],
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
            Icon(Icons.cloud_off, size: 64, color: theme.colorScheme.outline)
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: DashboardSpacing.lg),
            Text(
              'No se pudo cargar el dashboard',
              style: theme.textTheme.titleMedium,
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
            const SizedBox(height: DashboardSpacing.sm),
            Text(
              '$e',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
            const SizedBox(height: DashboardSpacing.lg),
            FilledButton.icon(
              onPressed: () => ref.invalidate(dashboardProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.3),
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

    return Stack(
      children: [
        const AtmosphericBackground(),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: ListView(
              padding: const EdgeInsets.all(DashboardSpacing.lg),
              children: [
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  borderRadius: 20,
                  borderColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  child: _buildHeader(context, ref, theme, resumen),
                ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),
                const SizedBox(height: DashboardSpacing.lg),
                _buildMetricasRow(context, resumen, formatter, variant),
                if (variant == DashboardLayoutVariant.desktop) ...[
                  const SizedBox(height: DashboardSpacing.lg),
                  _buildTopYChartRow(context, ref, resumen),
                  const SizedBox(height: DashboardSpacing.xl),
                  _buildHorasYRecientesRow(context, ref),
                ] else ...[
                  const SizedBox(height: DashboardSpacing.xl),
                  _buildTopProductos(context, ref, resumen),
                  const SizedBox(height: DashboardSpacing.xl),
                  _buildStockAlertas(context, resumen),
                  const SizedBox(height: DashboardSpacing.xl),
                  _buildChart(context, resumen),
                  const SizedBox(height: DashboardSpacing.xl),
                  _buildHorasChart(context, ref),
                  const SizedBox(height: DashboardSpacing.xl),
                  _buildRecientes(context, ref),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    DashboardResumen resumen,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.dashboard, color: theme.colorScheme.primary, size: 24),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.8, 0.8)),
        const SizedBox(width: DashboardSpacing.sm),
        Text(
          'DASHBOARD',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 50.ms).slideX(begin: -0.1),
        const Spacer(),
        IconButton(
          onPressed: () => context.push('/chat'),
          icon: const Icon(Icons.chat_bubble_outline),
          tooltip: 'Asistente ejecutivo',
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
        IconButton(
          onPressed: () => ref.invalidate(dashboardProvider),
          icon: const Icon(Icons.refresh),
          tooltip: 'Actualizar',
        ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
      ],
    );
  }

  Widget _buildMetricasRow(
    BuildContext context,
    DashboardResumen resumen,
    NumberFormat formatter,
    DashboardLayoutVariant variant,
  ) {
    final hero = MetricaPrincipalCard(
      titulo: 'Ventas hoy',
      valor: formatter.format(resumen.ventasHoy),
      subtitulo: '${resumen.transaccionesHoy} transacciones',
      meta: 'Ticket promedio: ${formatter.format(resumen.ticketPromedio)}',
      icon: Icons.payments,
      colorPrimario: Theme.of(context).colorScheme.primary,
      trailing: VariacionBadge(variacionPct: resumen.variacionPct),
    );

    final secundarias = [
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
        colorIcono: Theme.of(context).colorScheme.secondary,
      ),
      MetricaSecundariaCard(
        titulo: 'Ticket prom.',
        valor: formatter.format(resumen.ticketPromedio),
        subtitulo: 'por venta',
        icon: Icons.receipt_long,
        colorIcono: Theme.of(context).colorScheme.tertiary,
      ),
    ];

    final heroAnimated = hero
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, curve: Curves.easeOutCubic);

    final secundariasAnimated = secundarias.asMap().entries.map((entry) {
      final index = entry.key;
      return entry.value
          .animate()
          .fadeIn(duration: 400.ms, delay: (100 + index * 80).ms)
          .slideY(begin: 0.15, curve: Curves.easeOutCubic);
    }).toList();

    if (variant == DashboardLayoutVariant.desktop) {
      return Column(
        children: [
          heroAnimated,
          const SizedBox(height: DashboardSpacing.md),
          Row(
            children: [
              for (var i = 0; i < secundariasAnimated.length; i++) ...[
                Expanded(child: secundariasAnimated[i]),
                if (i < secundariasAnimated.length - 1)
                  const SizedBox(width: DashboardSpacing.md),
              ],
            ],
          ),
        ],
      );
    }
    return Column(
      children: [
        heroAnimated,
        const SizedBox(height: DashboardSpacing.md),
        for (var i = 0; i < secundariasAnimated.length; i++) ...[
          secundariasAnimated[i],
          if (i < secundariasAnimated.length - 1)
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
          child: _buildChart(context, resumen, staggerIndex: 5),
        ),
        const SizedBox(width: DashboardSpacing.md),
        Expanded(
          flex: 4,
          child: _buildTopProductos(context, ref, resumen, staggerIndex: 4),
        ),
      ],
    );
  }

  Widget _buildTopProductos(
    BuildContext context,
    WidgetRef ref,
    DashboardResumen resumen, {
    int staggerIndex = 3,
  }) {
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
    return GlassContainer(
      padding: const EdgeInsets.all(DashboardSpacing.md),
      borderRadius: 20,
      borderColor: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
      child: content,
    ).animate().fadeIn(duration: 400.ms, delay: (staggerIndex * 80).ms).slideY(begin: 0.15);
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
    return GlassContainer(
      padding: const EdgeInsets.all(DashboardSpacing.md),
      borderRadius: 20,
      borderColor: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
      child: content,
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.15);
  }

  Widget _buildChart(
    BuildContext context,
    DashboardResumen resumen, {
    int staggerIndex = 5,
  }) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SeccionHeader(
          titulo: 'Ventas últimos 7 días',
          icon: Icons.bar_chart,
        ),
        if (resumen.ventasUltimos7Dias.isEmpty)
          GlassContainer(
            padding: const EdgeInsets.all(DashboardSpacing.xl),
            borderRadius: DashboardRadius.md,
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
    return GlassContainer(
      padding: const EdgeInsets.all(DashboardSpacing.md),
      borderRadius: 20,
      borderColor: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
      child: content,
    ).animate().fadeIn(duration: 400.ms, delay: (staggerIndex * 80).ms).slideY(begin: 0.15);
  }

  Widget _buildHorasChart(BuildContext context, WidgetRef ref) {
    final horasAsync = ref.watch(ventasHoyPorHoraProvider);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SeccionHeader(
          titulo: 'Ventas por hora (hoy)',
          icon: Icons.show_chart,
        ),
        horasAsync.when(
          data: (horas) => horas.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(DashboardSpacing.xl),
                  child: Text(
                    'Sin datos de ventas hoy',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : VentasHorasChart(horas: horas),
          loading: () => const SizedBox(
            height: DashboardSizes.chartHeight,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(DashboardSpacing.md),
            child: Text(
              'Error al cargar: $e',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
    return GlassContainer(
      padding: const EdgeInsets.all(DashboardSpacing.md),
      borderRadius: 20,
      borderColor: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
      child: content,
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideY(begin: 0.15);
  }

  Widget _buildRecientes(BuildContext context, WidgetRef ref) {
    final recientesAsync = ref.watch(ventasRecientesProvider);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SeccionHeader(
          titulo: 'Últimas ventas',
          icon: Icons.receipt_long,
          badgeCount: 5,
        ),
        recientesAsync.when(
          data: (ventas) => VentasRecientesList(ventas: ventas),
          loading: () => const SizedBox(
            height: DashboardSizes.rowListHeight * 3,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(DashboardSpacing.md),
            child: Text(
              'Error: $e',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
    return GlassContainer(
      padding: const EdgeInsets.all(DashboardSpacing.md),
      borderRadius: 20,
      borderColor: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
      child: content,
    ).animate().fadeIn(duration: 400.ms, delay: 700.ms).slideY(begin: 0.15);
  }

  Widget _buildHorasYRecientesRow(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: _buildHorasChart(context, ref),
        ),
        const SizedBox(width: DashboardSpacing.md),
        Expanded(
          flex: 4,
          child: _buildRecientes(context, ref),
        ),
      ],
    );
  }
}