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
