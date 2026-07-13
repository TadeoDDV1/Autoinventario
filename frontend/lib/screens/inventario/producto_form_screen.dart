import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/durations.dart';
import '../../core/errors/api_exception.dart';
import '../../core/widgets/atmospheric_background.dart';
import '../../domain/enums.dart';
import '../../providers/producto_provider.dart';
import '../../widgets/inventario/margen_banner.dart';
import '../../widgets/inventario/producto_form_section.dart';

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
  final _skuController = TextEditingController();
  final _marcaController = TextEditingController();
  final _codigoBarrasController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _usoController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _precioMayoreoController = TextEditingController();
  final _stockActualController = TextEditingController();
  final _stockMinimoController = TextEditingController();
  final _ubicacionController = TextEditingController();
  int? _selectedCategoriaId;
  UnidadMedida _unidadMedida = UnidadMedida.pieza;
  bool _isLoading = false;
  bool get _isEditing => widget.productoId != null;

  bool get _esRapido =>
      widget.mode == ProductoFormMode.rapido && !_isEditing;

  /// Generador placeholder de código interno para modo rápido.
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
      _codigoBarrasController.text = _generarCodigoRapido();
      _stockActualController.text = '1';
      _stockMinimoController.text = '1';
      _precioCompraController.text = '0';
    }
    if (_isEditing) {
      _loadProducto();
    }
    // Listeners para refrescar el banner de margen en vivo
    _precioCompraController.addListener(_onPreciosChanged);
    _precioVentaController.addListener(_onPreciosChanged);
  }

  void _onPreciosChanged() {
    setState(() {});
  }

  Future<void> _loadProducto() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final producto = await api.getProductoById(widget.productoId!);
      if (mounted) {
        _nombreController.text = producto.nombre;
        _skuController.text = producto.sku ?? '';
        _marcaController.text = producto.marca ?? '';
        _codigoBarrasController.text = producto.codigoBarras ?? '';
        _descripcionController.text = producto.descripcion ?? '';
        _precioCompraController.text = producto.precioCompra.toStringAsFixed(2);
        _precioVentaController.text = producto.precioVenta.toStringAsFixed(2);
        _precioMayoreoController.text =
            producto.precioMayoreo?.toStringAsFixed(2) ?? '';
        _stockActualController.text = producto.stockActual.toString();
        _stockMinimoController.text = producto.stockMinimo.toString();
        _usoController.text = producto.uso ?? '';
        _ubicacionController.text = producto.ubicacion ?? '';
        _selectedCategoriaId = producto.categoriaId;
        _unidadMedida = producto.unidadMedida;
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
    _skuController.dispose();
    _marcaController.dispose();
    _codigoBarrasController.dispose();
    _descripcionController.dispose();
    _precioCompraController.dispose();
    _precioVentaController.dispose();
    _precioMayoreoController.dispose();
    _stockActualController.dispose();
    _stockMinimoController.dispose();
    _usoController.dispose();
    _ubicacionController.dispose();
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
      'unidad_medida': _unidadMedida.value,
    };

    if (_codigoBarrasController.text.trim().isNotEmpty) {
      data['codigo_barras'] = _codigoBarrasController.text.trim();
    }
    if (_skuController.text.trim().isNotEmpty) {
      data['sku'] = _skuController.text.trim();
    }
    if (_marcaController.text.trim().isNotEmpty) {
      data['marca'] = _marcaController.text.trim();
    }
    if (_descripcionController.text.trim().isNotEmpty) {
      data['descripcion'] = _descripcionController.text.trim();
    }
    if (_usoController.text.trim().isNotEmpty) {
      data['uso'] = _usoController.text.trim();
    }
    if (_ubicacionController.text.trim().isNotEmpty) {
      data['ubicacion'] = _ubicacionController.text.trim();
    }
    if (_precioMayoreoController.text.trim().isNotEmpty) {
      data['precio_mayoreo'] =
          double.tryParse(_precioMayoreoController.text) ?? 0;
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
          if (widget.mode == ProductoFormMode.full && !_isEditing)
            IconButton(
              icon: const Icon(Icons.flash_on),
              tooltip: 'Cambiar a modo rápido',
              onPressed: () => context.go('/inventario/nuevo-rapido'),
            ),
        ],
      ),
      body: Stack(
        children: [
          const AtmosphericBackground(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(theme, categoriasAsync),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, AsyncValue categoriasAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _esRapido
                  ? _buildRapidoSections(theme)
                  : _buildFullSections(theme, categoriasAsync),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRapidoSections(ThemeData theme) {
    return [
      ProductoFormSection(
        title: 'Alta rápida',
        icon: Icons.bolt,
        subtitle:
            'Código interno generado automáticamente. Stock inicial = 1. '
            'Completa los datos del producto.',
        children: [
          _campoCodigoRapido(theme),
          const SizedBox(height: 16),
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
          TextFormField(
            controller: _precioVentaController,
            decoration: const InputDecoration(
              labelText: 'Precio venta *',
              prefixIcon: Icon(Icons.sell_outlined),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Requerido';
              final val = double.tryParse(v);
              if (val == null) return 'Número inválido';
              if (val <= 0) return 'Debe ser mayor a 0';
              return null;
            },
          ),
          const SizedBox(height: 32),
          _buildSubmitButton(),
          const SizedBox(height: 24),
        ],
      ),
    ];
  }

  List<Widget> _buildFullSections(
    ThemeData theme,
    AsyncValue categoriasAsync,
  ) {
    final precioCompra =
        double.tryParse(_precioCompraController.text) ?? 0;
    final precioVenta = double.tryParse(_precioVentaController.text) ?? 0;

    return [
      // ── 1. Identificación ──
      ProductoFormSection(
        title: 'Identificación',
        icon: Icons.label_outline,
        subtitle: 'Datos básicos para identificar el producto',
        children: [
          TextFormField(
            controller: _nombreController,
            decoration: const InputDecoration(
              labelText: 'Nombre del producto *',
              prefixIcon: Icon(Icons.label_outline),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _marcaController,
            decoration: const InputDecoration(
              labelText: 'Marca',
              prefixIcon: Icon(Icons.business_center_outlined),
              helperText: 'Opcional',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _skuController,
                  decoration: const InputDecoration(
                    labelText: 'SKU interno',
                    prefixIcon: Icon(Icons.qr_code_2),
                    helperText: 'Opcional, único',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _codigoBarrasController,
                  decoration: const InputDecoration(
                    labelText: 'Código de barras',
                    prefixIcon: Icon(Icons.barcode_reader),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      const SizedBox(height: 16),

      // ── 2. Descripción y uso ──
      ProductoFormSection(
        title: 'Descripción y uso',
        icon: Icons.description_outlined,
        subtitle: 'Información que verá el vendedor y el cliente',
        children: [
          TextFormField(
            controller: _descripcionController,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              prefixIcon: Icon(Icons.description_outlined),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _usoController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Uso / Aplicaciones',
              prefixIcon: Icon(Icons.build_circle_outlined),
              helperText: 'Opcional: principales usos o aplicaciones',
            ),
          ),
        ],
      ),

      const SizedBox(height: 16),

      // ── 3. Categoría y ubicación ──
      ProductoFormSection(
        title: 'Categoría y ubicación',
        icon: Icons.category_outlined,
        subtitle: 'Dónde se guarda y cómo se mide',
        children: [
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
              onChanged: (v) => setState(() => _selectedCategoriaId = v),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text('Error cargando categorías'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<UnidadMedida>(
                  initialValue: _unidadMedida,
                  decoration: const InputDecoration(
                    labelText: 'Unidad de medida',
                    prefixIcon: Icon(Icons.straighten),
                  ),
                  items: UnidadMedida.values
                      .map(
                        (u) => DropdownMenuItem(
                          value: u,
                          child: Text(u.label),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _unidadMedida = v);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _ubicacionController,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación',
                    prefixIcon: Icon(Icons.place_outlined),
                    helperText: 'Pasillo, estante o anaquel',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      const SizedBox(height: 16),

      // ── 4. Precios ──
      ProductoFormSection(
        title: 'Precios',
        icon: Icons.attach_money,
        subtitle: 'Define el margen y, opcionalmente, precio de mayoreo',
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _precioCompraController,
                  decoration: const InputDecoration(
                    labelText: 'Precio compra *',
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    final val = double.tryParse(v);
                    if (val == null) return 'Número inválido';
                    if (val < 0) return 'No puede ser negativo';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _precioVentaController,
                  decoration: const InputDecoration(
                    labelText: 'Precio venta *',
                    prefixIcon: Icon(Icons.sell_outlined),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    final val = double.tryParse(v);
                    if (val == null) return 'Número inválido';
                    if (val <= 0) return 'Debe ser mayor a 0';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _precioMayoreoController,
            decoration: const InputDecoration(
              labelText: 'Precio mayoreo',
              prefixIcon: Icon(Icons.local_offer_outlined),
              helperText: 'Opcional. Precio para venta en volumen',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.isEmpty) return null;
              final val = double.tryParse(v);
              if (val == null) return 'Número inválido';
              if (val < 0) return 'No puede ser negativo';
              return null;
            },
          ),
          if (precioCompra > 0 && precioVenta > 0) ...[
            const SizedBox(height: 14),
            MargenBanner(
              precioCompra: precioCompra,
              precioVenta: precioVenta,
            ),
          ],
        ],
      ),

      const SizedBox(height: 16),

      // ── 5. Stock ──
      ProductoFormSection(
        title: 'Stock',
        icon: Icons.inventory_2_outlined,
        subtitle: 'Cantidad actual y umbral para alertas de reposición',
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _stockActualController,
                  decoration: const InputDecoration(
                    labelText: 'Stock actual',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v != null && int.tryParse(v) == null) {
                      return 'Inválido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _stockMinimoController,
                  decoration: const InputDecoration(
                    labelText: 'Stock mínimo',
                    prefixIcon: Icon(Icons.warning_amber),
                    helperText: 'Para alertas',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v != null && int.tryParse(v) == null) {
                      return 'Inválido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),

      const SizedBox(height: 32),

      _buildSubmitButton(),

      const SizedBox(height: 32),
    ];
  }

  Widget _buildSubmitButton() {
    return FilledButton(
      onPressed: _isLoading ? null : _submit,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              _submitButtonLabel(),
              style: const TextStyle(fontSize: 16),
            ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  String _submitButtonLabel() {
    if (_esRapido) return 'Crear y agregar al carrito';
    return _isEditing ? 'Actualizar Producto' : 'Crear Producto';
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
}