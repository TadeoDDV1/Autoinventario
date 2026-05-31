import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/producto_provider.dart';
import '../../providers/venta_provider.dart';
import '../../widgets/producto_search_bar.dart';
import '../../widgets/category_filter.dart';
import '../../widgets/ventas/carrito_widget.dart';
import '../../widgets/ventas/producto_grid.dart';
import '../../widgets/stock_alert_banner.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onProductoTap(producto) {
    ref.read(carritoProvider.notifier).agregarProducto(producto);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${producto.nombre} agregado al carrito'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            ref.read(carritoProvider.notifier).quitarProducto(producto.id);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productosAsync = ref.watch(productosProvider);
    final categoriasAsync = ref.watch(categoriasProvider);
    final selectedCategoria = ref.watch(productoCategoriaFilterProvider);
    final carritoCantidad = ref.watch(carritoCantidadProvider);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;

          return Row(
            children: [
              Expanded(
                flex: isWide ? 3 : 4,
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar.large(
                      title: Text(
                        'Punto de Venta',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      actions: [
                        FilledButton.icon(
                          onPressed: () => context.go('/ventas/historial'),
                          icon: const Icon(Icons.receipt_long),
                          label: const Text('Historial'),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          if (!isWide) const StockAlertBanner(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                ProductoSearchBar(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    ref
                                        .read(productoSearchProvider.notifier)
                                        .update(value);
                                    ref
                                        .read(productoPageProvider.notifier)
                                        .update(1);
                                  },
                                  onClear: () {
                                    ref
                                        .read(productoSearchProvider.notifier)
                                        .update('');
                                    ref
                                        .read(productoPageProvider.notifier)
                                        .update(1);
                                  },
                                ),
                                const SizedBox(height: 12),
                                if (selectedCategoria != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Chip(
                                          label: Text(
                                            categoriasAsync.when(
                                              data: (cats) => cats
                                                      .where((c) => c.id == selectedCategoria)
                                                      .firstOrNull
                                                      ?.nombre ??
                                                  'Categoría',
                                              loading: () => 'Cargando...',
                                              error: (_, __) => 'Categoría',
                                            ),
                                          ),
                                          deleteIcon: const Icon(Icons.close, size: 18),
                                          onDeleted: () {
                                            ref
                                                .read(productoCategoriaFilterProvider.notifier)
                                                .update(null);
                                            ref
                                                .read(productoPageProvider.notifier)
                                                .update(1);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                categoriasAsync.when(
                                  data: (categorias) => CategoryFilter(
                                    categorias: categorias,
                                    selectedCategoriaId: selectedCategoria,
                                    onSelected: (id) {
                                      ref
                                          .read(productoCategoriaFilterProvider
                                              .notifier)
                                          .update(id);
                                      ref
                                          .read(productoPageProvider.notifier)
                                          .update(1);
                                    },
                                  ),
                                  loading: () => const SizedBox.shrink(),
                                  error: (a, b) => const SizedBox.shrink(),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    productosAsync.when(
                      data: (paginated) => SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: ProductoGrid(
                          productos: paginated.data,
                          onProductoTap: _onProductoTap,
                        ),
                      ),
                      loading: () => const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, _) => SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(height: 16),
                              Text('Error al cargar productos'),
                              const SizedBox(height: 8),
                              Text(
                                error.toString(),
                                style: theme.textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
              if (isWide)
                Container(
                  width: 380,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  child: const CarritoWidget(),
                ),
            ],
          );
        },
      ),
      endDrawer: MediaQuery.of(context).size.width <= 800
          ? const Drawer(child: CarritoWidget())
          : null,
      floatingActionButton:
          MediaQuery.of(context).size.width <= 800 && carritoCantidad > 0
              ? FloatingActionButton.extended(
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  icon: const Icon(Icons.shopping_cart),
                  label: Text('Ver Carrito ($carritoCantidad)'),
                )
              : null,
    );
  }
}