import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/producto.dart';
import '../models/venta.dart';

class CarritoItem {
  final Producto producto;
  final int cantidad;

  const CarritoItem({
    required this.producto,
    required this.cantidad,
  });

  double get subtotal => producto.precioVenta * cantidad;

  CarritoItem copyWith({int? cantidad}) {
    return CarritoItem(
      producto: producto,
      cantidad: cantidad ?? this.cantidad,
    );
  }
}

class CarritoNotifier extends Notifier<List<CarritoItem>> {
  @override
  List<CarritoItem> build() => [];

  void agregarProducto(Producto producto) {
    final index = state.indexWhere((item) => item.producto.id == producto.id);
    if (index >= 0) {
      final item = state[index];
      state = [
        ...state.sublist(0, index),
        item.copyWith(cantidad: item.cantidad + 1),
        ...state.sublist(index + 1),
      ];
    } else {
      state = [...state, CarritoItem(producto: producto, cantidad: 1)];
    }
  }

  void quitarProducto(int productoId) {
    state = state.where((item) => item.producto.id != productoId).toList();
  }

  void actualizarCantidad(int productoId, int cantidad) {
    if (cantidad <= 0) {
      quitarProducto(productoId);
      return;
    }
    final index = state.indexWhere((item) => item.producto.id == productoId);
    if (index >= 0) {
      state = [
        ...state.sublist(0, index),
        state[index].copyWith(cantidad: cantidad),
        ...state.sublist(index + 1),
      ];
    }
  }

  void incrementarCantidad(int productoId) {
    final index = state.indexWhere((item) => item.producto.id == productoId);
    if (index >= 0) {
      final item = state[index];
      state = [
        ...state.sublist(0, index),
        item.copyWith(cantidad: item.cantidad + 1),
        ...state.sublist(index + 1),
      ];
    }
  }

  void decrementarCantidad(int productoId) {
    final index = state.indexWhere((item) => item.producto.id == productoId);
    if (index >= 0) {
      final item = state[index];
      if (item.cantidad <= 1) {
        quitarProducto(productoId);
      } else {
        state = [
          ...state.sublist(0, index),
          item.copyWith(cantidad: item.cantidad - 1),
          ...state.sublist(index + 1),
        ];
      }
    }
  }

  void vaciar() {
    state = [];
  }
}

final carritoProvider =
    NotifierProvider<CarritoNotifier, List<CarritoItem>>(
  CarritoNotifier.new,
);

final carritoTotalProvider = Provider<double>((ref) {
  final carrito = ref.watch(carritoProvider);
  return carrito.fold(0.0, (sum, item) => sum + item.subtotal);
});

final carritoSubtotalProvider = Provider<double>((ref) {
  final total = ref.watch(carritoTotalProvider);
  return total / 1.16;
});

final carritoIvaProvider = Provider<double>((ref) {
  final subtotal = ref.watch(carritoSubtotalProvider);
  return subtotal * 0.16;
});

final carritoCantidadProvider = Provider<int>((ref) {
  final carrito = ref.watch(carritoProvider);
  return carrito.fold(0, (sum, item) => sum + item.cantidad);
});

final metodoPagoProvider = NotifierProvider<MetodoPagoNotifier, MetodoPago>(
  MetodoPagoNotifier.new,
);

class MetodoPagoNotifier extends Notifier<MetodoPago> {
  @override
  MetodoPago build() => MetodoPago.efectivo;
}
