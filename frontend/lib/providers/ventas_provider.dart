import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/venta.dart';
import '../services/api_service.dart';
import 'producto_provider.dart';

final ventasProvider = AsyncNotifierProvider<VentasNotifier, List<Venta>>(
  VentasNotifier.new,
);

class VentasNotifier extends AsyncNotifier<List<Venta>> {
  @override
  Future<List<Venta>> build() async {
    final api = ref.watch(apiServiceProvider);
    return api.getVentas();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final ventaDetalleProvider = FutureProvider.family<Venta, int>((ref, id) async {
  final api = ref.watch(apiServiceProvider);
  return api.getVentaById(id);
});