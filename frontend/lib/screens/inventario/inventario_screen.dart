import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/durations.dart';
import '../../core/layout/breakpoints.dart';
import '../../providers/producto_provider.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../widgets/producto_search_bar.dart';
import '../../widgets/producto_card.dart';
import '../../widgets/category_filter.dart';

class InventarioScreen extends ConsumerStatefulWidget {
  const InventarioScreen({super.key});

  @override
  ConsumerState<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends ConsumerState<InventarioScreen> {
  final _searchController = TextEditingController();
  DateTime? _lastSearchTime;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final now = DateTime.now();
    if (_lastSearchTime != null &&
        now.difference(_lastSearchTime!).inMilliseconds <
            AppDurations.debounceSearch.inMilliseconds) {
      return;
    }
    _lastSearchTime = now;
    ref.read(productoSearchProvider.notifier).update(value);
    ref.read(productoPageProvider.notifier).update(1);
  }

  void _showDeleteConfirmation(int id, String nombre) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Estás seguro de eliminar "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(productosProvider.notifier).deleteProducto(id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productosAsync = ref.watch(productosProvider);
    final categoriasAsync = ref.watch(categoriasProvider);
    final selectedCategoria = ref.watch(productoCategoriaFilterProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              'Inventario',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => context.push('/inventario/entrada'),
                icon: const Icon(Icons.add_shopping_cart),
                tooltip: 'Entrada de inventario',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.tertiaryContainer,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => context.push('/inventario/entradas'),
                icon: const Icon(Icons.history),
                tooltip: 'Historial de entradas',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => context.go('/inventario/predicciones'),
                icon: const Icon(Icons.auto_graph),
                tooltip: 'Análisis predictivo (IA)',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () => context.push('/inventario/escanear'),
                icon: const Icon(Icons.qr_code_scanner),
                tooltip: 'Escanear producto nuevo',
              ),
              const SizedBox(width: 4),
              IconButton.filled(
                onPressed: () => context.push('/inventario/nuevo'),
                icon: const Icon(Icons.edit_note),
                tooltip: 'Registro manual',
              ),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ProductoSearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onClear: () {
                      ref.read(productoSearchProvider.notifier).update('');
                      ref.read(productoPageProvider.notifier).update(1);
                    },
                  ),
                  const SizedBox(height: 12),
                  categoriasAsync.when(
                    data: (categorias) => CategoryFilter(
                      categorias: categorias,
                      selectedCategoriaId: selectedCategoria,
                      onSelected: (id) {
                        ref
                            .read(productoCategoriaFilterProvider.notifier)
                            .update(id);
                        ref.read(productoPageProvider.notifier).update(1);
                      },
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (a, b) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          productosAsync.when(
            data: (paginated) {
              if (paginated.data.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron productos',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Agrega tu primer producto para comenzar',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: paginated.data.length,
                  itemBuilder: (context, index) {
                    final producto = paginated.data[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ProductoCard(
                        producto: producto,
                        onEdit: () => context.push(
                          '/inventario/editar/${producto.id}',
                        ),
                        onDelete: () => _showDeleteConfirmation(
                          producto.id,
                          producto.nombre,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: SkeletonList(),
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
                    Text(
                      'Error al cargar productos',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: () => ref.invalidate(productosProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, _) {
          final width = MediaQuery.of(context).size.width;
          if (Breakpoints.isTablet(width) || Breakpoints.isDesktop(width)) {
            return const SizedBox.shrink();
          }
          // FAB dual: tap abre menu con 2 opciones
          return PopupMenuButton<String>(
            tooltip: 'Agregar producto',
            onSelected: (value) {
              if (value == 'escanear') {
                context.push('/inventario/escanear');
              } else if (value == 'manual') {
                context.push('/inventario/nuevo');
              } else if (value == 'entrada') {
                context.push('/inventario/entrada');
              } else if (value == 'historial_entradas') {
                context.push('/inventario/entradas');
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'escanear',
                child: Row(
                  children: [
                    Icon(Icons.qr_code_scanner),
                    SizedBox(width: 12),
                    Text('Escanear nuevo'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'manual',
                child: Row(
                  children: [
                    Icon(Icons.edit_note),
                    SizedBox(width: 12),
                    Text('Registro manual'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'entrada',
                child: Row(
                  children: [
                    Icon(Icons.add_shopping_cart),
                    SizedBox(width: 12),
                    Text('Entrada de inventario'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'historial_entradas',
                child: Row(
                  children: [
                    Icon(Icons.history),
                    SizedBox(width: 12),
                    Text('Historial de entradas'),
                  ],
                ),
              ),
            ],
            child: FloatingActionButton(
              onPressed: null, // delegado al PopupMenuButton
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
