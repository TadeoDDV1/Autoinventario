import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/format/money.dart';
import '../../models/producto.dart';
import '../../providers/venta_provider.dart';

/// Tile de producto para el grid de Caja v2.
///
/// Interacciones:
///   - Tap → incrementa 1 al carrito.
///   - LongPress → decrementa 1 (si está en el carrito).
///   - Muestra badge con la cantidad ya en el carrito (si > 0).
///   - Muestra badge de stock bajo si está por debajo del mínimo.
///
/// Sin glass, sin sombra pesada, sin animación — performance nativa.
class ProductTile extends ConsumerWidget {
  final Producto producto;

  const ProductTile({super.key, required this.producto});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = money;
    final carrito = ref.watch(carritoProvider);
    final enCarrito =
        carrito.firstWhere((c) => c.producto.id == producto.id,
            orElse: () => CarritoItem(producto: producto, cantidad: 0));
    final cantidadEnCarrito = enCarrito.cantidad;
    final stockBajo = producto.stockActual <= producto.stockMinimo;
    final sinStock = producto.stockActual <= 0;

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: sinStock
            ? null
            : () {
                ref.read(carritoProvider.notifier).agregarProducto(producto);
              },
        onLongPress: cantidadEnCarrito > 0
            ? () {
                ref
                    .read(carritoProvider.notifier)
                    .decrementarCantidad(producto.id);
              }
            : null,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      producto.nombre,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (cantidadEnCarrito > 0)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'x$cantidadEnCarrito',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatter.format(producto.precioVenta),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (stockBajo)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: sinStock
                            ? theme.colorScheme.errorContainer
                            : Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sinStock ? 'Agotado' : 'Stock bajo',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: sinStock
                              ? theme.colorScheme.onErrorContainer
                              : Colors.amber.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Text(
                      '${producto.stockActual} disp.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
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
