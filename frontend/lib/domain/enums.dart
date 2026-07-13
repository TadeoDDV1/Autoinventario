/// Modos principales de la app.
enum ModoApp { caja, inventario }

/// Métodos de pago soportados. Single source of truth.
enum MetodoPago {
  efectivo('efectivo'),
  tarjeta('tarjeta');

  final String value;
  const MetodoPago(this.value);

  static MetodoPago fromString(String value) {
    return MetodoPago.values.firstWhere(
      (m) => m.value == value,
      orElse: () => MetodoPago.efectivo,
    );
  }

  String get label => switch (this) {
        MetodoPago.efectivo => 'Efectivo',
        MetodoPago.tarjeta => 'Tarjeta',
      };
}

/// Unidad de medida del producto. Single source of truth que espeja el ENUM
/// de la base de datos (migración 007). El backend devuelve el value; el
/// `fromValue` es tolerante para no romper si la BD tiene valores legacy.
enum UnidadMedida {
  pieza('pieza', 'Pieza'),
  metro('metro', 'Metro'),
  kg('kg', 'Kilogramo'),
  litro('litro', 'Litro'),
  caja('caja', 'Caja'),
  rollo('rollo', 'Rollo'),
  par('par', 'Par'),
  otro('otro', 'Otro');

  final String value;
  final String label;
  const UnidadMedida(this.value, this.label);

  static UnidadMedida fromValue(String? value) {
    if (value == null || value.isEmpty) return UnidadMedida.pieza;
    return UnidadMedida.values.firstWhere(
      (u) => u.value == value,
      orElse: () => UnidadMedida.pieza,
    );
  }
}