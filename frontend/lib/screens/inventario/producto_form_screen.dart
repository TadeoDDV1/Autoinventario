import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../providers/producto_provider.dart';

class ProductoFormScreen extends ConsumerStatefulWidget {
  final int? productoId;

  const ProductoFormScreen({super.key, this.productoId});

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

  @override
  void initState() {
    super.initState();
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
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
                        _sectionTitle(theme, 'Información General'),
                        const SizedBox(height: 12),
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
                          controller: _codigoBarrasController,
                          decoration: const InputDecoration(
                            labelText: 'Código de barras',
                            prefixIcon: Icon(Icons.barcode_reader),
                          ),
                        ),
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
                                  if (v == null || v.isEmpty)
                                    return 'Requerido';
                                  if (double.tryParse(v) == null)
                                    return 'Número inválido';
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
                                  if (v == null || v.isEmpty)
                                    return 'Requerido';
                                  final val = double.tryParse(v);
                                  if (val == null) return 'Número inválido';
                                  if (val <= 0) return 'Debe ser mayor a 0';
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
                                  prefixIcon: Icon(Icons.inventory_2_outlined),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v != null && int.tryParse(v) == null)
                                    return 'Inválido';
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
                                  if (v != null && int.tryParse(v) == null)
                                    return 'Inválido';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
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
                                      _isEditing
                                          ? 'Actualizar Producto'
                                          : 'Crear Producto',
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
