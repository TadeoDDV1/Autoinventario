import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/producto.dart';
import 'venta_provider.dart';

enum BurbujaPosicion { bottomRight, bottomLeft }

final burbujaPosicionProvider =
    NotifierProvider<BurbujaPosicionNotifier, BurbujaPosicion>(
  BurbujaPosicionNotifier.new,
);

class BurbujaPosicionNotifier extends Notifier<BurbujaPosicion> {
  bool _init = false;

  @override
  BurbujaPosicion build() {
    if (!_init) {
      _init = true;
      Future.microtask(_loadFromPrefs);
    }
    return BurbujaPosicion.bottomRight;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('ia_burbuja_posicion');
    if (raw != null) {
      state = raw == 'bottomLeft'
          ? BurbujaPosicion.bottomLeft
          : BurbujaPosicion.bottomRight;
    }
  }

  Future<void> toggle() async {
    state = state == BurbujaPosicion.bottomRight
        ? BurbujaPosicion.bottomLeft
        : BurbujaPosicion.bottomRight;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ia_burbuja_posicion', state.name);
  }
}

/// Estado expandido de la burbuja (abierto/cerrado).
/// Se usa desde el atajo Ctrl+K y desde el widget de la burbuja.
final burbujaExpandidaProvider =
    NotifierProvider<BurbujaExpandidaNotifier, bool>(
  BurbujaExpandidaNotifier.new,
);

class BurbujaExpandidaNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;

  void close() => state = false;
}

/// Helper para agregar productos al carrito desde la burbuja IA.
Future<void> burbujaAgregarProducto(WidgetRef ref, Producto producto) async {
  ref.read(carritoProvider.notifier).agregarProducto(producto);
}
