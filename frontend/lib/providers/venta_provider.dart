import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/producto.dart';
import '../models/venta.dart';
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
      // Ignore storage errors
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
  }

  void quitarProducto(int productoId) {
    state = state.where((item) => item.producto.id != productoId).toList();
    _saveToStorage();
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
  }

  void vaciar() {
    state = [];
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
