import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BurbujaPosicion { bottomRight, bottomLeft }

final burbujaPosicionProvider =
    NotifierProvider<BurbujaPosicionNotifier, BurbujaPosicionOffset>(
  BurbujaPosicionNotifier.new,
);

class BurbujaPosicionNotifier extends Notifier<BurbujaPosicionOffset> {
  bool _init = false;

  @override
  BurbujaPosicionOffset build() {
    if (!_init) {
      _init = true;
      Future.microtask(_loadFromPrefs);
    }
    return BurbujaPosicionOffset.defaultPosition();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawX = prefs.getDouble('ia_burbuja_offset_x');
    final rawY = prefs.getDouble('ia_burbuja_offset_y');
    if (rawX != null && rawY != null) {
      state = BurbujaPosicionOffset.custom(x: rawX, y: rawY);
      return;
    }
    state = BurbujaPosicionOffset.defaultPosition();
  }

  Future<void> setX(double x) async {
    state = state.copyWith(x: x);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ia_burbuja_offset_x', x);
  }

  Future<void> setY(double y) async {
    state = state.copyWith(y: y);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ia_burbuja_offset_y', y);
  }

  Future<void> togglePosition() async {
    if (state is BurbujaPosicionOffset) {
      final current = state as BurbujaPosicionOffset;
      // Ciclar: default -> bottomRight offset -> bottomLeft offset -> default
      if (current.isDefault) {
        state = BurbujaPosicionOffset.custom(x: 0.0, y: 0.0);
      } else if (current.x == 0.0 && current.y == 0.0) {
        state = BurbujaPosicionOffset.defaultPosition();
      } else {
        state = BurbujaPosicionOffset.defaultPosition();
      }
    }
  }

  Future<void> resetToDefault() async {
    state = BurbujaPosicionOffset.defaultPosition();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ia_burbuja_offset_x');
    await prefs.remove('ia_burbuja_offset_y');
  }
}

/// Estado de posición de la burbuja: offset personalizable (x, y)
/// o posición predefinida (bottomRight/bottomLeft).
class BurbujaPosicionOffset {
  final double x;
  final double y;

  /// Posición por defecto: abajo a la derecha con offset suave
  BurbujaPosicionOffset.defaultPosition()
      : x = 16.0,
        y = 16.0;

  /// Desde enum old
  BurbujaPosicionOffset.fromEnum(BurbujaPosicion enumPos) : x = 0, y = 0;

  /// Constructor unnamed (para compatibilidad con copyWith y Dart 3)
  BurbujaPosicionOffset() : x = 0.0, y = 0.0;

  /// Constructor con valores personalizados
  BurbujaPosicionOffset.custom({required this.x, required this.y});

  /// Copiar con nuevos valores
  BurbujaPosicionOffset copyWith({double? x, double? y}) {
    return BurbujaPosicionOffset.custom(x: x ?? this.x, y: y ?? this.y);
  }

  bool get isDefault => x == 16.0 && y == 16.0;
  bool get isCustom => !isDefault && x != 0.0 && y != 0.0;

  @override
  String toString() => 'BurbujaPosicionOffset(x: $x, y: $y)';
}

/// Estado activable/desactivable de la burbuja.
final burbujaActivaProvider =
    NotifierProvider<BurbujaActivaNotifier, bool>(
  BurbujaActivaNotifier.new,
);

/// Estado expandido/colapsado de la burbuja (abierto/cerrado).
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

class BurbujaActivaNotifier extends Notifier<bool> {
  @override
  bool build() {
    _loadFromPrefs();
    return true;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('ia_burbuja_activo');
    if (raw != null) {
      state = raw == '1';
      return;
    }
    state = true;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ia_burbuja_activo', state ? '1' : '0');
  }

  Future<void> setActivo(bool activo) async {
    state = activo;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ia_burbuja_activo', activo ? '1' : '0');
  }
}