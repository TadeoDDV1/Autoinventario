import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/durations.dart';
import '../../core/errors/api_exception.dart';
import '../../core/format/money.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/widgets/atmospheric_background.dart';
import '../../core/widgets/glass_container.dart';
import '../../models/producto.dart';
import '../../providers/entrada_provider.dart';
import '../../providers/producto_provider.dart';

class EntradaScreen extends ConsumerStatefulWidget {
  const EntradaScreen({super.key});

  @override
  ConsumerState<EntradaScreen> createState() => _EntradaScreenState();
}

class _EntradaScreenState extends ConsumerState<EntradaScreen> {
  final _proveedorController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _busquedaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<_LineaEntrada> _lineas = [];
  bool _procesando = false;

  @override
  void dispose() {
    _proveedorController.dispose();
    _observacionesController.dispose();
    _busquedaController.dispose();
    super.dispose();
  }

  void _agregarProducto(Producto p) {
    setState(() {
      final idx = _lineas.indexWhere((l) => l.productoId == p.id);
      if (idx >= 0) {
        _lineas[idx] = _lineas[idx].copyWith(
          cantidad: _lineas[idx].cantidad + 1,
        );
      } else {
        _lineas.add(_LineaEntrada(
          productoId: p.id,
          nombreProducto: p.nombre,
          cantidad: 1,
          costoUnitario: p.precioCompra > 0 ? p.precioCompra : 0,
        ));
      }
    });
  }

  void _removerLinea(int index) {
    setState(() => _lineas.removeAt(index));
  }

  double get _totalEntrada =>
      _lineas.fold(0.0, (s, l) => s + l.cantidad * l.costoUnitario);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lineas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un producto')),
      );
      return;
    }

    setState(() => _procesando = true);

    final data = <String, dynamic>{
      'detalles': _lineas
          .map((l) => {
                'producto_id': l.productoId,
                'cantidad': l.cantidad,
                'costo_unitario': l.costoUnitario,
              })
          .toList(),
    };
    if (_proveedorController.text.trim().isNotEmpty) {
      data['proveedor'] = _proveedorController.text.trim();
    }
    if (_observacionesController.text.trim().isNotEmpty) {
      data['observaciones'] = _observacionesController.text.trim();
    }

    try {
      final api = ref.read(entradaServiceProvider);
      final result = await api.create(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Entrada creada — Folio: ${result['folio']}'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/inventario');
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _procesando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}'),
            backgroundColor: Colors.red.shade700,
            duration: AppDurations.snackbarLong,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _procesando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productosAsync = ref.watch(productosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrada de inventario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/inventario'),
        ),
      ),
      body: Stack(
        children: [
          const AtmosphericBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBusquedaProductos(theme, productosAsync),
                      const SizedBox(height: 16),
                      _buildLineasSection(theme),
                      const SizedBox(height: 16),
                      _buildDatosEntrada(theme),
                      const SizedBox(height: 16),
                      _buildResumenYSubmit(theme),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusquedaProductos(
    ThemeData theme,
    AsyncValue productosAsync,
  ) {
    final sugerencias = <Producto>[];
    if (_busquedaController.text.length >= 2) {
      final q = _busquedaController.text.toLowerCase();
      final data = productosAsync.maybeWhen(
        data: (p) => p.data,
        orElse: () => <Producto>[],
      );
      sugerencias.addAll(
        data
            .where((p) =>
                p.nombre.toLowerCase().contains(q) ||
                (p.codigoBarras?.toLowerCase().contains(q) ?? false) ||
                (p.sku?.toLowerCase().contains(q) ?? false))
            .take(6),
      );
    }

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: GlassTokens.borderRadiusMedium,
      blur: GlassTokens.blurSmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.search, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Agregar productos',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _busquedaController,
            decoration: const InputDecoration(
              labelText: 'Buscar producto por nombre, código o SKU',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (sugerencias.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...sugerencias.map(
              (p) => ListTile(
                dense: true,
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  p.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '${money.format(p.precioCompra)} c/u · Stock: ${p.stockActual}',
                  style: theme.textTheme.bodySmall,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    _agregarProducto(p);
                    _busquedaController.clear();
                  },
                  tooltip: 'Agregar a entrada',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLineasSection(ThemeData theme) {
    if (_lineas.isEmpty) return const SizedBox.shrink();

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: GlassTokens.borderRadiusMedium,
      blur: GlassTokens.blurSmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.receipt_long, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Productos (${_lineas.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._lineas.asMap().entries.map((entry) {
            final i = entry.key;
            final l = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.nombreProducto,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              SizedBox(
                                width: 70,
                                child: TextFormField(
                                  initialValue: l.cantidad.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    labelText: 'Cant',
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 6),
                                  ),
                                  onChanged: (v) {
                                    final n = int.tryParse(v);
                                    if (n != null && n > 0) {
                                      setState(() =>
                                          _lineas[i] = l.copyWith(cantidad: n));
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 90,
                                child: TextFormField(
                                  initialValue: l.costoUnitario > 0
                                      ? l.costoUnitario.toStringAsFixed(2)
                                      : '',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    labelText: 'Costo',
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 6),
                                  ),
                                  onChanged: (v) {
                                    final n = double.tryParse(v);
                                    if (n != null && n >= 0) {
                                      setState(() => _lineas[i] =
                                          l.copyWith(costoUnitario: n));
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                money.format(l.subtotal),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline,
                          color: Colors.red.shade400),
                      onPressed: () => _removerLinea(i),
                      tooltip: 'Quitar',
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDatosEntrada(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: GlassTokens.borderRadiusMedium,
      blur: GlassTokens.blurSmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.info_outline, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Datos de la entrada',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _proveedorController,
            decoration: const InputDecoration(
              labelText: 'Proveedor',
              prefixIcon: Icon(Icons.business_outlined),
              helperText: 'Opcional',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _observacionesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Observaciones',
              prefixIcon: Icon(Icons.notes_outlined),
              helperText: 'Opcional',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenYSubmit(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: GlassTokens.borderRadiusMedium,
      blur: GlassTokens.blurSmall,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total entrada',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  money.format(_totalEntrada),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: _procesando ? null : _submit,
            icon: _procesando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_procesando ? 'Guardando...' : 'Guardar entrada'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineaEntrada {
  final int productoId;
  final String nombreProducto;
  final int cantidad;
  final double costoUnitario;

  const _LineaEntrada({
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.costoUnitario,
  });

  double get subtotal => cantidad * costoUnitario;

  _LineaEntrada copyWith({int? cantidad, double? costoUnitario}) {
    return _LineaEntrada(
      productoId: productoId,
      nombreProducto: nombreProducto,
      cantidad: cantidad ?? this.cantidad,
      costoUnitario: costoUnitario ?? this.costoUnitario,
    );
  }
}