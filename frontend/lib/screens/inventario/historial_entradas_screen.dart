import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/format/money.dart';
import '../../core/widgets/atmospheric_background.dart';
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
  // Filtros (los 3 clásicos: fechas + proveedor + búsqueda libre).
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  final _proveedorController = TextEditingController();
  final _qController = TextEditingController();
  Timer? _debounceFiltros;

  // Estado de paginación acumulada.
  final List<EntradaInventario> _items = [];
  int _page = 1;
  bool _cargandoMas = false;
  bool _inicialCargado = false;
  int _total = 0;
  int _totalPages = 1;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refrescarTodo();
    });
  }

  @override
  void dispose() {
    _debounceFiltros?.cancel();
    _proveedorController.dispose();
    _qController.dispose();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  /// Scroll infinito: cuando faltan <400px para el final, carga la
  /// siguiente página mientras haya más.
  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 400) {
      _cargarMas();
    }
  }

  /// Resetea la lista y carga la página 1.
  Future<void> _refrescarTodo() async {
    setState(() {
      _items.clear();
      _page = 1;
      _totalPages = 1;
      _inicialCargado = false;
    });
    await _cargar(pagina: 1, append: false);
  }

  /// Carga una página del backend y la concatena a [_items].
  Future<void> _cargar({required int pagina, required bool append}) async {
    if (_cargandoMas) return;
    if (append && _page >= _totalPages) return;
    setState(() => _cargandoMas = true);

    final filtro = HistorialFiltro(
      desde: _fechaDesde?.toIso8601String().split('T').first,
      hasta: _fechaHasta?.toIso8601String().split('T').first,
      proveedor: _proveedorController.text.trim().isEmpty
          ? null
          : _proveedorController.text.trim(),
      q: _qController.text.trim().isEmpty
          ? null
          : _qController.text.trim(),
      page: pagina,
    );

    try {
      final result = await ref.read(entradaHistorialProvider(filtro).future);
      if (!mounted) return;
      setState(() {
        if (append) {
          _items.addAll(result.items);
        } else {
          _items
            ..clear()
            ..addAll(result.items);
        }
        _total = result.total;
        _totalPages = result.totalPages;
        _page = result.page;
        _inicialCargado = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _cargandoMas = false);
    }
  }

  Future<void> _cargarMas() async {
    if (_cargandoMas) return;
    if (_page >= _totalPages) return;
    await _cargar(pagina: _page + 1, append: true);
  }

  void _onFiltroChanged() {
    _debounceFiltros?.cancel();
    _debounceFiltros = Timer(const Duration(milliseconds: 400), () {
      _refrescarTodo();
    });
  }

  void _limpiarFiltros() {
    _fechaDesde = null;
    _fechaHasta = null;
    _proveedorController.clear();
    _qController.clear();
    _refrescarTodo();
  }

  void _setFecha(bool desde, DateTime picked) {
    setState(() {
      if (desde) {
        _fechaDesde = picked;
      } else {
        _fechaHasta = picked;
      }
    });
    _refrescarTodo();
  }

  Future<void> _pickDate(BuildContext context, bool desde) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: desde
          ? (_fechaDesde ?? now.subtract(const Duration(days: 30)))
          : (_fechaHasta ?? now),
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 1)),
    );
    if (picked != null) _setFecha(desde, picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
              _buildBarraFiltros(theme),
              _buildResumenHeader(theme),
              Expanded(child: _buildLista(theme)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarraFiltros(ThemeData theme) {
    final fmt = DateFormat('dd/MM/yyyy');
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _DateChip(
                  label: 'Desde',
                  value: _fechaDesde != null ? fmt.format(_fechaDesde!) : 'Todas',
                  icon: Icons.calendar_today,
                  onTap: () => _pickDate(context, true),
                  onClear: _fechaDesde == null
                      ? null
                      : () {
                          setState(() => _fechaDesde = null);
                          _refrescarTodo();
                        },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DateChip(
                  label: 'Hasta',
                  value: _fechaHasta != null ? fmt.format(_fechaHasta!) : 'Hoy',
                  icon: Icons.calendar_today,
                  onTap: () => _pickDate(context, false),
                  onClear: _fechaHasta == null
                      ? null
                      : () {
                          setState(() => _fechaHasta = null);
                          _refrescarTodo();
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _proveedorController,
            onChanged: (_) => _onFiltroChanged(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.business, size: 18),
              hintText: 'Proveedor',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _qController,
            onChanged: (_) => _onFiltroChanged(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 18),
              hintText: 'Buscar folio u observaciones',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenHeader(ThemeData theme) {
    if (!_inicialCargado && _cargandoMas && _items.isEmpty) {
      return const SizedBox.shrink();
    }
    if (_total == 0) return const SizedBox.shrink();

    final mostrados = _items.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      width: double.infinity,
      child: Text(
        'Mostrando $mostrados de $_total entradas',
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildLista(ThemeData theme) {
    if (!_inicialCargado) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      final hayFiltros =
          _fechaDesde != null || _fechaHasta != null ||
          _proveedorController.text.trim().isNotEmpty ||
          _qController.text.trim().isNotEmpty;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hayFiltros ? Icons.filter_alt_off : Icons.receipt_long_outlined,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                hayFiltros
                    ? 'No hay entradas con esos filtros'
                    : 'No hay entradas registradas',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (hayFiltros) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _limpiarFiltros,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Limpiar filtros'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refrescarTodo,
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
        itemCount: _items.length + (_page < _totalPages ? 1 : 0),
        itemBuilder: (_, i) {
          if (i >= _items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return _EntradaCard(
            entrada: _items[i],
            onTap: () => _showDetalleSheet(_items[i]),
          );
        },
      ),
    );
  }

  Future<void> _showDetalleSheet(EntradaInventario e) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EntradaDetalleSheet(entradaId: e.id),
    );
  }
}

/// Card simple para una entrada en la lista. Tap = abrir detalle.
class _EntradaCard extends StatelessWidget {
  final EntradaInventario entrada;
  final VoidCallback onTap;

  const _EntradaCard({required this.entrada, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            entrada.folio,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (entrada.proveedor != null &&
                            entrada.proveedor!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                entrada.proveedor!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('d MMM yyyy – HH:mm').format(entrada.fecha),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (entrada.observaciones != null &&
                        entrada.observaciones!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          entrada.observaciones!,
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
                money.format(entrada.total),
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
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  Text(value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (onClear != null)
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                onPressed: onClear,
                tooltip: 'Limpiar',
              ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet con el detalle de la entrada usando `getById`.
/// Muestra un spinner mientras carga; se refresca vía pull-to-refresh.
class EntradaDetalleSheet extends ConsumerWidget {
  final int entradaId;

  const EntradaDetalleSheet({super.key, required this.entradaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(entradaByIdProvider(entradaId));
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: async.when(
            data: (e) => e == null
                ? _errorView(theme, 'Entrada no encontrada', () {
                    ref.invalidate(entradaByIdProvider(entradaId));
                  })
                : _DetalleContent(
                    entrada: e,
                    scrollController: scrollController,
                    onCopiarFolio: () => _copiarFolio(context, e.folio),
                  ),
            loading: () => _loadingView(theme),
            error: (err, _) => _errorView(theme, err, () {
              ref.invalidate(entradaByIdProvider(entradaId));
            }),
          ),
        );
      },
    );
  }

  Widget _loadingView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 16),
          Text('Cargando entrada...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
        ],
      ),
    );
  }

  Widget _errorView(ThemeData theme, Object err, VoidCallback retry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off,
                size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Error al cargar la entrada',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text('$err',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  void _copiarFolio(BuildContext context, String folio) {
    Clipboard.setData(ClipboardData(text: folio));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Folio "$folio" copiado'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _DetalleContent extends StatelessWidget {
  final EntradaInventario entrada;
  final ScrollController scrollController;
  final VoidCallback onCopiarFolio;

  const _DetalleContent({
    required this.entrada,
    required this.scrollController,
    required this.onCopiarFolio,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cantProductos = entrada.detalles.length;

    return ListView(
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
        Row(
          children: [
            Expanded(
              child: Text(entrada.folio,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: 'Copiar folio',
              onPressed: onCopiarFolio,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cerrar',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('d MMM yyyy – HH:mm').format(entrada.fecha),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (entrada.proveedor != null && entrada.proveedor!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.business,
                size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(entrada.proveedor!,
                style: theme.textTheme.bodyMedium),
          ]),
        ],
        if (entrada.observaciones != null &&
            entrada.observaciones!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.notes,
                size: 16, color: theme.colorScheme.outline),
            const SizedBox(width: 6),
            Expanded(
              child: Text(entrada.observaciones!,
                  style: theme.textTheme.bodyMedium),
            ),
          ]),
        ],
        const Divider(height: 28),
        Row(
          children: [
            Text('Productos',
                style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('$cantProductos item${cantProductos == 1 ? '' : 's'}',
                style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 8),
        ...entrada.detalles.map(
          (d) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.nombreProducto,
                          style: theme.textTheme.bodyMedium),
                      Text('${d.cantidad} × ${money.format(d.costoUnitario)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 90,
                  child: Text(money.format(d.subtotal),
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600)),
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
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold)),
            Text(money.format(entrada.total),
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary)),
          ],
        ),
      ],
    );
  }
}
