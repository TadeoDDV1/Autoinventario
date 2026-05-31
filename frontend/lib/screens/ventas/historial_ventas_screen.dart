import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/ventas_provider.dart';
import '../../models/venta.dart';

enum FiltroFecha { hoy, semana, mes, all }

class HistorialVentasScreen extends ConsumerStatefulWidget {
  const HistorialVentasScreen({super.key});

  @override
  ConsumerState<HistorialVentasScreen> createState() => _HistorialVentasScreenState();
}

class _HistorialVentasScreenState extends ConsumerState<HistorialVentasScreen> {
  FiltroFecha _filtroFecha = FiltroFecha.all;
  String? _filtroMetodoPago;
  Venta? _selectedVenta;

  List<Venta> _filtrarVentas(List<Venta> ventas) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    return ventas.where((v) {
      if (_filtroFecha != FiltroFecha.all && v.fecha != null) {
        final fechaVenta = DateTime(v.fecha!.year, v.fecha!.month, v.fecha!.day);
        switch (_filtroFecha) {
          case FiltroFecha.hoy:
            if (fechaVenta != hoy) return false;
            break;
          case FiltroFecha.semana:
            final haceUnaSemana = hoy.subtract(const Duration(days: 7));
            if (fechaVenta.isBefore(haceUnaSemana)) return false;
            break;
          case FiltroFecha.mes:
            final haceUnMes = DateTime(hoy.year, hoy.month - 1, hoy.day);
            if (fechaVenta.isBefore(haceUnMes)) return false;
            break;
          case FiltroFecha.all:
            break;
        }
      }
      if (_filtroMetodoPago != null && v.metodoPago != _filtroMetodoPago) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ventasAsync = ref.watch(ventasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ventas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/ventas'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(ventasProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltros(theme),
          Expanded(
            child: ventasAsync.when(
              data: (ventas) {
                final filtradas = _filtrarVentas(ventas);
                if (filtradas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay ventas',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(ventasProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtradas.length,
                    itemBuilder: (context, index) {
                      final venta = filtradas[index];
                      return _VentaCard(
                        venta: venta,
                        onTap: () => setState(() => _selectedVenta = venta),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text('Error al cargar ventas'),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: () => ref.read(ventasProvider.notifier).refresh(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip(
                  label: 'Hoy',
                  selected: _filtroFecha == FiltroFecha.hoy,
                  onSelected: () => setState(() => _filtroFecha = FiltroFecha.hoy),
                ),
                const SizedBox(width: 8),
                _filterChip(
                  label: 'Esta semana',
                  selected: _filtroFecha == FiltroFecha.semana,
                  onSelected: () => setState(() => _filtroFecha = FiltroFecha.semana),
                ),
                const SizedBox(width: 8),
                _filterChip(
                  label: 'Este mes',
                  selected: _filtroFecha == FiltroFecha.mes,
                  onSelected: () => setState(() => _filtroFecha = FiltroFecha.mes),
                ),
                const SizedBox(width: 8),
                _filterChip(
                  label: 'Todo',
                  selected: _filtroFecha == FiltroFecha.all,
                  onSelected: () => setState(() => _filtroFecha = FiltroFecha.all),
                ),
                const SizedBox(width: 16),
                Container(
                  height: 24,
                  width: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
                const SizedBox(width: 16),
                _filterChip(
                  label: 'Efectivo',
                  selected: _filtroMetodoPago == 'efectivo',
                  onSelected: () => setState(() => _filtroMetodoPago =
                      _filtroMetodoPago == 'efectivo' ? null : 'efectivo'),
                ),
                const SizedBox(width: 8),
                _filterChip(
                  label: 'Tarjeta',
                  selected: _filtroMetodoPago == 'tarjeta',
                  onSelected: () => setState(() => _filtroMetodoPago =
                      _filtroMetodoPago == 'tarjeta' ? null : 'tarjeta'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _VentaCard extends StatelessWidget {
  final Venta venta;
  final VoidCallback onTap;

  const _VentaCard({required this.venta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  venta.metodoPago == 'efectivo'
                      ? Icons.money
                      : Icons.credit_card,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venta.folio ?? 'Venta #${venta.id}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      venta.fecha != null
                          ? dateFormatter.format(venta.fecha!)
                          : 'Sin fecha',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: venta.metodoPago == 'efectivo'
                                ? Colors.green.shade100
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            venta.metodoPago == 'efectivo'
                                ? 'Efectivo'
                                : 'Tarjeta',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: venta.metodoPago == 'efectivo'
                                  ? Colors.green.shade900
                                  : Colors.blue.shade900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${venta.detalles.length} item${venta.detalles.length > 1 ? 's' : ''}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatter.format(venta.total),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}