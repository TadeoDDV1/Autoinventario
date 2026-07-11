import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/sse/event_source_client.dart';
import '../models/producto.dart';
import '../services/caja_sesion_service.dart';
import 'caja_sesion_service_provider.dart';
import 'producto_provider.dart';
import 'venta_provider.dart';

final cajaSesionEstadoProvider =
    NotifierProvider<CajaSesionEstadoNotifier, CajaSesionEstado?>(
  CajaSesionEstadoNotifier.new,
);

class CajaSesionEstadoNotifier extends Notifier<CajaSesionEstado?> {
  @override
  CajaSesionEstado? build() => null;

  void setEstado(CajaSesionEstado estado) {
    state = estado;
  }
}

final cajaSesionSyncProvider = Provider<void>((ref) {
  final svc = ref.read(cajaSesionServiceProvider);
  final carritoNotifier = ref.read(carritoProvider.notifier);
  final estadoNotifier = ref.read(cajaSesionEstadoProvider.notifier);
  final productosAsync = ref.watch(productosProvider);
  final sseConnected = ref.read(sseConnectedProvider.notifier);

  svc.obtenerEstado().then((estado) {
    estadoNotifier.setEstado(estado);
    final prods = productosAsync.asData?.value.data ?? [];
    _reconciliarCarrito(carritoNotifier, estado, prods);
  });

  svc.onConnectionChange = (connected) {
    sseConnected.setConnected(connected);
  };
  svc.conectarSSE();
  final sub = svc.events.listen((event) {
    _procesarEvento(event, svc, carritoNotifier, estadoNotifier, productosAsync.asData?.value.data ?? []);
  });

  ref.onDispose(() {
    sub.cancel();
    svc.desconectarSSE();
  });

  return;
});

void _reconciliarCarrito(
  CarritoNotifier carritoNotifier,
  CajaSesionEstado estado,
  List<Producto> productos,
) {
  final serverItems = {
    for (final item in estado.items) item.productoId: item.cantidad,
  };

  if (carritoNotifier.cantidadTotal == 0) {
    for (final item in estado.items) {
      final producto = productos.cast<Producto?>().firstWhere(
        (p) => p?.id == item.productoId,
        orElse: () => null,
      );
      if (producto != null) {
        carritoNotifier.setCantidadDirecta(producto, item.cantidad);
      }
    }
  }
}

void _procesarEvento(
  SSEEvent event,
  CajaSesionService svc,
  CarritoNotifier carritoNotifier,
  CajaSesionEstadoNotifier estadoNotifier,
  List<Producto> productos,
) {
  if (event.type == 'ping') return;

  final pid = event.data['producto_id'] as int?;
  final cantidad = event.data['cantidad'] as int?;

  svc.obtenerEstado().then((estado) {
    estadoNotifier.setEstado(estado);
  });
}
