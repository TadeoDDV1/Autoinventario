import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/producto.dart';

class ProductoGrid extends StatelessWidget {
  final List<Producto> productos;
  final Function(Producto) onProductoTap;

  const ProductoGrid({
    super.key,
    required this.productos,
    required this.onProductoTap,
  });

  @override
  Widget build(BuildContext context) {
    if (productos.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay productos disponibles',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final producto = productos[index];
          return _ProductoGridItem(
            producto: producto,
            onTap: () => onProductoTap(producto),
          )
              .animate()
              .fadeIn(duration: 200.ms, delay: (index * 30).ms);
        },
        childCount: productos.length,
      ),
    );
  }
}

class _ProductoGridItem extends StatelessWidget {
  final Producto producto;
  final VoidCallback onTap;

  const _ProductoGridItem({
    required this.producto,
    required this.onTap,
  });

  Color _stockColor() {
    switch (producto.stockLevel) {
      case StockLevel.outOfStock:
        return Colors.red;
      case StockLevel.low:
        return Colors.orange;
      case StockLevel.medium:
        return Colors.amber;
      case StockLevel.high:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stockColor = _stockColor();
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: producto.stockActual > 0 ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: producto.imagenUrl != null &&
                        producto.imagenUrl!.isNotEmpty
                    ? Image.network(
                        producto.imagenUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.inventory,
                          size: 40,
                          color: theme.colorScheme.outline,
                        ),
                      )
                    : Icon(
                        Icons.inventory,
                        size: 40,
                        color: theme.colorScheme.outline,
                      ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatter.format(producto.precioVenta),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 14,
                        color: stockColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${producto.stockActual} uds',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: stockColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (producto.stockActual <= 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Agotado',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
