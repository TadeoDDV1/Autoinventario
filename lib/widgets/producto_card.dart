import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/producto.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductoCard({
    super.key,
    required this.producto,
    required this.onEdit,
    required this.onDelete,
  });

  Color _stockColor(StockLevel level) {
    switch (level) {
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

  String _stockLabel(StockLevel level) {
    switch (level) {
      case StockLevel.outOfStock:
        return 'Agotado';
      case StockLevel.low:
        return 'Stock bajo';
      case StockLevel.medium:
        return 'Stock medio';
      case StockLevel.high:
        return 'En stock';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stockColor = _stockColor(producto.stockLevel);

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
            onTap: onEdit,
            borderRadius: BorderRadius.circular(12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 5,
                    height: double.infinity,
                    color: stockColor,
                  ),
                  if (producto.imagenUrl != null &&
                      producto.imagenUrl!.isNotEmpty)
                    Container(
                      width: 100,
                      height: double.infinity,
                      margin: const EdgeInsets.only(left: 1),
                      child: Image.network(
                        producto.imagenUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 100,
                      height: double.infinity,
                      margin: const EdgeInsets.only(left: 1),
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.inventory,
                        color: theme.colorScheme.outline,
                        size: 32,
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  producto.nombre,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 20),
                                onSelected: (value) {
                                  if (value == 'edit') onEdit();
                                  if (value == 'delete') onDelete();
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Editar'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Eliminar'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (producto.categoriaNombre != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                producto.categoriaNombre!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                          if (producto.codigoBarras != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              producto.codigoBarras!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '\$${producto.precioVenta.toStringAsFixed(2)}',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 14,
                                        color: stockColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${producto.stockActual} uds',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: stockColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: stockColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _stockLabel(producto.stockLevel),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: stockColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms);
  }
}
