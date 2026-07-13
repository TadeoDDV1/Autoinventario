import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/format/money.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/widgets/atmospheric_background.dart';
import '../../core/widgets/glass_container.dart';
import '../../models/entrada.dart';
import '../../providers/entrada_provider.dart';

class HistorialEntradasScreen extends ConsumerStatefulWidget {
  const HistorialEntradasScreen({super.key});

  @override
  ConsumerState<HistorialEntradasScreen> createState() =>
      _HistorialEntradasScreenState();
}

class _HistorialEntradasScreenState
    extends ConsumerState<HistorialEntradasScreen> {
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtro = HistorialFiltro(
      desde: _fechaDesde?.toIso8601String().split('T').first,
      hasta: _fechaHasta?.toIso8601String().split('T').first,
    );
    final historialAsync = ref.watch(entradaHistorialProvider(filtro));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de entradas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/inventario'),
        ),
      ),
      body: Stack(
        children: [
          const AtmosphericBackground(),
          Column(
            children: [
              _buildDateFilter(theme),
              Expanded(
                child: historialAsync.when(
                  data: (entradas) {
                    if (entradas.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 64, color: theme.colorScheme.outline),
                            const SizedBox(height: 16),
                            Text(
                              'No hay entradas registradas',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: entradas.length,
                      itemBuilder: (_, i) => _buildEntradaCard(
                          theme, entradas[i]),
                    );
                  },
                  loading: () => const Center(
                      child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter(ThemeData theme) {
    final fmt = DateFormat('dd/MM/yyyy');
    return GlassContainer(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: GlassTokens.borderRadiusMedium,
      blur: GlassTokens.blurSmall,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _pickDate(context, true),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Desde',
                  prefixIcon: const Icon(Icons.calendar_today, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 10),
                ),
                child: Text(
                  _fechaDesde != null ? fmt.format(_fechaDesde!) : 'Todas',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => _pickDate(context, false),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Hasta',
                  prefixIcon: const Icon(Icons.calendar_today, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 10),
                ),
                child: Text(
                  _fechaHasta != null ? fmt.format(_fechaHasta!) : 'Hoy',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _fechaDesde = null;
                _fechaHasta = null;
              });
            },
            tooltip: 'Limpiar filtros',
          ),
        ],
      ),
    );
  }

  Widget _buildEntradaCard(ThemeData theme, EntradaInventario e) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      borderRadius: GlassTokens.borderRadiusMedium,
      blur: GlassTokens.blurSmall,
      child: InkWell(
        borderRadius: BorderRadius.circular(GlassTokens.borderRadiusMedium),
        onTap: () => _showDetalles(e),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        e.folio,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (e.proveedor != null && e.proveedor!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            e.proveedor!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('d MMM yyyy – HH:mm').format(e.fecha),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (e.observaciones != null && e.observaciones!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        e.observaciones!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              money.format(e.total),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }

  void _pickDate(BuildContext context, bool desde) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: desde
          ? (_fechaDesde ?? now.subtract(const Duration(days: 30)))
          : (_fechaHasta ?? now),
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        if (desde) {
          _fechaDesde = picked;
        } else {
          _fechaHasta = picked;
        }
      });
    }
  }

  void _showDetalles(EntradaInventario e) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.35,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(e.folio,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                DateFormat('d MMM yyyy – HH:mm').format(e.fecha),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              if (e.proveedor != null && e.proveedor!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.business, size: 16,
                      color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(e.proveedor!),
                ]),
              ],
              if (e.observaciones != null && e.observaciones!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.notes, size: 16,
                      color: theme.colorScheme.outline),
                  const SizedBox(width: 6),
                  Expanded(child: Text(e.observaciones!)),
                ]),
              ],
              const Divider(height: 28),
              Text('Productos',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...e.detalles.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(d.nombreProducto,
                            style: theme.textTheme.bodyMedium),
                      ),
                      Text('${d.cantidad} × ${money.format(d.costoUnitario)}',
                          style: theme.textTheme.bodySmall),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 80,
                        child: Text(money.format(d.subtotal),
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(money.format(e.total),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}