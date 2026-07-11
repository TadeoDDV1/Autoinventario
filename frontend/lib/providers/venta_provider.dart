import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/producto.dart';
import '../models/venta.dart';
import 'caja_sesion_service_provider.dart';
import 'producto_provider.dart';

const String _carritoKey = 'carrito_items';

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

  Map<String, dynamic> toJson() => {
        'producto': producto.id,
        'cantidad': cantidad,
      };

  static CarritoItem fromJson(
    Map<String, dynamic> json,
    List<Producto> productos,
  ) {
    final productoId = json['producto'] as int;
    final producto = productos.firstWhere((p) => p.id == productoId);
    return CarritoItem(
      producto: producto,
      cantidad: json['cantidad'] as int,
    );
  }
}

class CarritoNotifier extends Notifier<List<CarritoItem>> {
  bool _hydrated = false;

  @override
  List<CarritoItem> build() {
    if (!_hydrated) {
      Future.microtask(loadFromStorage);
    }
    return const <CarritoItem>[];
  }

  Future<void> loadFromStorage() async {
    if (_hydrated) return;
    _hydrated = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final carritoJson = prefs.getString(_carritoKey);
      if (carritoJson == null) return;
      final api = ref.read(apiServiceProvider);
      final productosResponse = await api.getProductos(pageSize: 100);
      final productos = productosResponse.data;
      final List<dynamic> decoded = jsonDecode(carritoJson);
      final items = decoded
          .map((json) =>
              CarritoItem.fromJson(json as Map<String, dynamic>, productos))
          .toList();
      state = items;
    } catch (_) {
      // Si falla la carga, dejar el carrito vacío silenciosamente
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = state.map((item) => item.toJson()).toList();
      await prefs.setString(_carritoKey, jsonEncode(json));
    } catch (_) {
    }
  }

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
    _saveToStorage();
    _syncAdd(producto.id);
  }

  void _syncAdd(int productoId) {
    try {
      ref.read(cajaSesionServiceProvider).agregarItem(productoId);
    } catch (_) {
    }
  }

  void quitarProducto(int productoId) {
    state = state.where((item) => item.producto.id != productoId).toList();
    _saveToStorage();
    _syncRemove(productoId);
  }

  void _syncRemove(int productoId) {
    try {
      ref.read(cajaSesionServiceProvider).removerItem(productoId);
    } catch (_) {
    }
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
    _saveToStorage();
    _syncSet(productoId, cantidad);
  }

  void _syncSet(int productoId, int cantidad) {
    try {
      ref.read(cajaSesionServiceProvider).setCantidad(productoId, cantidad);
    } catch (_) {
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
    _saveToStorage();
    _syncAdd(productoId);
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
    _saveToStorage();
    _syncAfterDecrement(productoId);
  }

  void _syncAfterDecrement(int productoId) {
    final idx = state.indexWhere((i) => i.producto.id == productoId);
    if (idx >= 0) {
      _syncSet(productoId, state[idx].cantidad);
    }
  }

  void vaciar() {
    state = [];
    _saveToStorage();
    try {
      ref.read(cajaSesionServiceProvider).limpiar();
    } catch (_) {
    }
  }

  /// Reordena un item dentro del carrito. Sigue la convención de
  /// [ReorderableListView]: si el destino está después del origen, el índice
  /// que llega en [newIndex] ya fue decrementado por el framework, así que
  /// se descuenta 1 para reinsertar en la posición lógica correcta.
  void reordenar(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.length) return;
    if (newIndex < 0 || newIndex > state.length) return;
    if (oldIndex == newIndex) return;
    final item = state[oldIndex];
    final nuevaLista = [...state]..removeAt(oldIndex);
    final destino = newIndex > oldIndex ? newIndex - 1 : newIndex;
    nuevaLista.insert(destino.clamp(0, nuevaLista.length), item);
    state = nuevaLista;
    _saveToStorage();
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

final ventasProvider = FutureProvider<List<Venta>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getVentas();
});

/// Extensión para setear cantidad sin pasar por el server.
/// Usado durante reconciliación inicial.
extension CarritoDirectSetter on CarritoNotifier {
  int get cantidadTotal => state.length;

  void setCantidadDirecta(Producto producto, int cantidad) {
    final idx = state.indexWhere((i) => i.producto.id == producto.id);
    if (idx >= 0) {
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == idx) state[i].copyWith(cantidad: cantidad) else state[i],
      ];
    } else {
      agregarProducto(producto);
      if (cantidad > 1) {
        actualizarCantidad(producto.id, cantidad);
      }
    }
  }
}
