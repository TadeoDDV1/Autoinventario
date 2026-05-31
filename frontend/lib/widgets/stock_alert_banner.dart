import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/producto.dart';
import '../providers/producto_provider.dart';
import '../providers/venta_provider.dart';

class StockAlertBanner extends ConsumerWidget {
  const StockAlertBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productosAsync = ref.watch(productosProvider);

    return productosAsync.when(
      data: (paginated) {
        final lowStockCount = paginated.data
            .where((p) => p.stockLevel == StockLevel.outOfStock || p.stockLevel == StockLevel.low)
            .length;

        if (lowStockCount == 0) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/inventario?filter=low-stock'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stock bajo',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade900,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '$lowStockCount producto${lowStockCount > 1 ? 's' : ''} con stock bajo o agotado',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.orange.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

final stockAlertCountProvider = Provider<int>((ref) {
  final productosAsync = ref.watch(productosProvider);
  return productosAsync.when(
    data: (paginated) => paginated.data
        .where((p) => p.stockLevel == StockLevel.outOfStock || p.stockLevel == StockLevel.low)
        .length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});