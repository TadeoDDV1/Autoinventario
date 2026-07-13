class DetalleEntrada {
  final int productoId;
  final String nombreProducto;
  final int cantidad;
  final double costoUnitario;

  const DetalleEntrada({
    required this.productoId,
    this.nombreProducto = '',
    required this.cantidad,
    required this.costoUnitario,
  });

  double get subtotal => cantidad * costoUnitario;

  factory DetalleEntrada.fromJson(Map<String, dynamic> json) {
    return DetalleEntrada(
      productoId: (json['producto_id'] as num?)?.toInt() ?? 0,
      nombreProducto: (json['nombre_producto'] as String?) ?? '',
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 0,
      costoUnitario: (json['costo_unitario'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'producto_id': productoId,
        'cantidad': cantidad,
        'costo_unitario': costoUnitario,
      };
}

class EntradaInventario {
  final int id;
  final String folio;
  final String? proveedor;
  final String? observaciones;
  final double total;
  final DateTime fecha;
  final List<DetalleEntrada> detalles;

  const EntradaInventario({
    required this.id,
    required this.folio,
    this.proveedor,
    this.observaciones,
    required this.total,
    required this.fecha,
    this.detalles = const [],
  });

  factory EntradaInventario.fromJson(Map<String, dynamic> json) {
    return EntradaInventario(
      id: (json['id'] as num?)?.toInt() ?? 0,
      folio: (json['folio'] as String?) ?? '',
      proveedor: json['proveedor'] as String?,
      observaciones: json['observaciones'] as String?,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'] as String)
          : DateTime.now(),
      detalles: (json['detalles'] as List<dynamic>?)
              ?.map((d) => DetalleEntrada.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}