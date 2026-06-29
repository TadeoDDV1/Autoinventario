import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/durations.dart';
import '../../core/errors/api_exception.dart';
import '../../providers/producto_provider.dart';

/// Modo de presentación del formulario de producto.
///
/// - [full]: formulario completo (todos los campos). Es el default.
/// - [rapido]: sólo 3 campos (Nombre, Código de barras auto-generado readonly,
///   Precio venta) con defaults en stock (1/1) y precio_compra (0). Pensado
///   para alta inline desde Caja.
///
/// NOTA: si se está editando (productoId != null), el `mode` se IGNORA y se
/// muestra siempre el form completo (no tiene sentido editar en modo rápido).
enum ProductoFormMode { full, rapido }

class ProductoFormScreen extends ConsumerStatefulWidget {
  final int? productoId;
  final ProductoFormMode mode;

  const ProductoFormScreen({
    super.key,
    this.productoId,
    this.mode = ProductoFormMode.full,
  });

  @override
  ConsumerState<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends ConsumerState<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoBarrasController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _stockActualController = TextEditingController();
  final _stockMinimoController = TextEditingController();
  final _imagenUrlController = TextEditingController();
  int? _selectedCategoriaId;
  bool _isLoading = false;
  bool get _isEditing => widget.productoId != null;

  /// Modo rápido efectivo: requiere `mode == rapido` Y NO estar editando.
  /// (Editar siempre se hace en form completo.)
  bool get _esRapido =>
      widget.mode == ProductoFormMode.rapido && !_isEditing;

  /// Generador placeholder de código interno para modo rápido.
  ///
  /// TODO(A2): reemplazar por `generarCodigoManualCaja()` cuando se implemente
  /// el helper centralizado en `producto_provider.dart`. Por ahora produce un
  /// código numérico en el rango 0-9999 (4 dígitos con padding a la izquierda).
  String _generarCodigoRapido() {
    final n = DateTime.now().millisecondsSinceEpoch % 10000;
    return n.toString().padLeft(4, '0');
  }

  void _regenerarCodigoRapido() {
    setState(() {
      _codigoBarrasController.text = _generarCodigoRapido();
    });
  }

  @override
  void initState() {
    super.initState();
    if (_esRapido) {
      // Aplicar defaults del modo rápido
      _codigoBarrasController.text = _generarCodigoRapido();
      _stockActualController.text = '1';
      _stockMinimoController.text = '1';
      _precioCompraController.text = '0';
    }
    if (_isEditing) {
      _loadProducto();
    }
  }

  Future<void> _loadProducto() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final producto = await api.getProductoById(widget.productoId!);
      if (mounted) {
        _nombreController.text = producto.nombre;
        _codigoBarrasController.text = producto.codigoBarras ?? '';
        _descripcionController.text = producto.descripcion ?? '';
        _precioCompraController.text = producto.precioCompra.toStringAsFixed(2);
        _precioVentaController.text = producto.precioVenta.toStringAsFixed(2);
        _stockActualController.text = producto.stockActual.toString();
        _stockMinimoController.text = producto.stockMinimo.toString();
        _imagenUrlController.text = producto.imagenUrl ?? '';
        _selectedCategoriaId = producto.categoriaId;
        setState(() => _isLoading = false);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar producto: ${e.message}'),
            backgroundColor: Colors.red.shade700,
            duration: AppDurations.snackbarLong,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar producto: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoBarrasController.dispose();
    _descripcionController.dispose();
    _precioCompraController.dispose();
    _precioVentaController.dispose();
    _stockActualController.dispose();
    _stockMinimoController.dispose();
    _imagenUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = <String, dynamic>{
      'nombre': _nombreController.text.trim(),
      'precio_compra': double.tryParse(_precioCompraController.text) ?? 0,
      'precio_venta': double.tryParse(_precioVentaController.text) ?? 0,
      'stock_actual': int.tryParse(_stockActualController.text) ?? 0,
      'stock_minimo': int.tryParse(_stockMinimoController.text) ?? 5,
    };

    if (_codigoBarrasController.text.trim().isNotEmpty) {
      data['codigo_barras'] = _codigoBarrasController.text.trim();
    }
    if (_descripcionController.text.trim().isNotEmpty) {
      data['descripcion'] = _descripcionController.text.trim();
    }
    if (_imagenUrlController.text.trim().isNotEmpty) {
      data['imagen_url'] = _imagenUrlController.text.trim();
    }
    if (_selectedCategoriaId != null) {
      data['categoria_id'] = _selectedCategoriaId;
    }

    try {
      if (_isEditing) {
        await ref
            .read(productosProvider.notifier)
            .updateProducto(widget.productoId!, data);
      } else {
        await ref.read(productosProvider.notifier).createProducto(data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Producto actualizado' : 'Producto creado',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/inventario');
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade700,
            duration: AppDurations.snackbarLong,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriasAsync = ref.watch(categoriasProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Producto' : 'Nuevo Producto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/inventario'),
        ),
        actions: [
          // Switch "modo rápido" sólo visible al CREAR en modo full.
          // En edición no aplica (modo rápido se ignora al editar).
          if (widget.mode == ProductoFormMode.full && !_isEditing)
            IconButton(
              icon: const Icon(Icons.flash_on),
              tooltip: 'Cambiar a modo rápido',
              onPressed: () => context.go('/inventario/nuevo-rapido'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Banner informativo solo en modo rápido
                        if (_esRapido) ...[
                          _bannerModoRapido(theme),
                          const SizedBox(height: 16),
                        ],
                        // En modo rápido se omite el sectionTitle "Información
                        // General" porque sólo hay 3 campos; en full se mantiene.
                        if (!_esRapido) ...[
                          _sectionTitle(theme, 'Información General'),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre del producto *',
                            prefixIcon: Icon(Icons.label_outline),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Requerido'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        if (_esRapido)
                          _campoCodigoRapido(theme)
                        else
                          TextFormField(
                            controller: _codigoBarrasController,
                            decoration: const InputDecoration(
                              labelText: 'Código de barras',
                              prefixIcon: Icon(Icons.barcode_reader),
                            ),
                          ),
                        // Campos sólo en modo full
                        if (!_esRapido) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _imagenUrlController,
                            decoration: const InputDecoration(
                              labelText: 'URL de Imagen (Opcional)',
                              prefixIcon: Icon(Icons.image_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descripcionController,
                            decoration: const InputDecoration(
                              labelText: 'Descripción',
                              prefixIcon: Icon(Icons.description_outlined),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          categoriasAsync.when(
                            data: (categorias) => DropdownButtonFormField<int>(
                              initialValue: _selectedCategoriaId,
                              decoration: const InputDecoration(
                                labelText: 'Categoría',
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                              items: categorias
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text(c.nombre),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedCategoriaId = v),
                            ),
                            loading: () => const LinearProgressIndicator(),
                            error: (a, b) =>
                                const Text('Error cargando categorías'),
                          ),
                          const SizedBox(height: 32),
                          _sectionTitle(theme, 'Precios'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _precioCompraController,
                                  decoration: const InputDecoration(
                                    labelText: 'Precio compra *',
                                    prefixIcon: Icon(Icons.attach_money),
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Requerido';
                                    }
                                    final val = double.tryParse(v);
                                    if (val == null) return 'Número inválido';
                                    if (val < 0) {
                                      return 'No puede ser negativo';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _precioVentaController,
                                  decoration: const InputDecoration(
                                    labelText: 'Precio venta *',
                                    prefixIcon: Icon(Icons.sell_outlined),
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Requerido';
                                    }
                                    final val = double.tryParse(v);
                                    if (val == null) return 'Número inválido';
                                    if (val <= 0) {
                                      return 'Debe ser mayor a 0';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          _sectionTitle(theme, 'Stock'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _stockActualController,
                                  decoration: const InputDecoration(
                                    labelText: 'Stock actual',
                                    prefixIcon:
                                        Icon(Icons.inventory_2_outlined),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v != null &&
                                        int.tryParse(v) == null) {
                                      return 'Inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _stockMinimoController,
                                  decoration: const InputDecoration(
                                    labelText: 'Stock mínimo',
                                    prefixIcon: Icon(Icons.warning_amber),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v != null &&
                                        int.tryParse(v) == null) {
                                      return 'Inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Modo rápido: sólo Precio venta
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _precioVentaController,
                            decoration: const InputDecoration(
                              labelText: 'Precio venta *',
                              prefixIcon: Icon(Icons.sell_outlined),
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Requerido';
                              }
                              final val = double.tryParse(v);
                              if (val == null) return 'Número inválido';
                              if (val <= 0) return 'Debe ser mayor a 0';
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 40),
                        FilledButton(
                              onPressed: _isLoading ? null : _submit,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _submitButtonLabel(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  /// Label del botón submit según modo + edición.
  String _submitButtonLabel() {
    if (_esRapido) return 'Crear y agregar al carrito';
    return _isEditing ? 'Actualizar Producto' : 'Crear Producto';
  }

  /// Banner informativo que aparece sólo en modo rápido.
  Widget _bannerModoRapido(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bolt,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Modo rápido: Código interno generado automáticamente. '
              'Stock inicial = 1.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Campo de código de barras en modo rápido: readonly + botón regenerar.
  Widget _campoCodigoRapido(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: _codigoBarrasController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Código de barras',
              prefixIcon: Icon(Icons.barcode_reader),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Regenerar código',
          icon: const Icon(Icons.refresh),
          onPressed: _regenerarCodigoRapido,
          style: IconButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(ThemeData theme, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
