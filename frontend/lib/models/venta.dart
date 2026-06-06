export '../domain/enums.dart' show MetodoPago;

class DetalleVenta {
  final int productoId;
  final String nombreProducto;
  final double precioUnitario;
  final int cantidad;
  final double subtotal;

  const DetalleVenta({
    required this.productoId,
    required this.nombreProducto,
    required this.precioUnitario,
    required this.cantidad,
    required this.subtotal,
  });

  factory DetalleVenta.fromJson(Map<String, dynamic> json) {
    return DetalleVenta(
      productoId: json['producto_id'] as int,
      nombreProducto: json['nombre_producto'] as String,
      precioUnitario: (json['precio_unitario'] as num).toDouble(),
      cantidad: json['cantidad'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'nombre_producto': nombreProducto,
      'precio_unitario': precioUnitario,
      'cantidad': cantidad,
      'subtotal': subtotal,
    };
  }
}

class Venta {
  final int? id;
  final String? folio;
  final List<DetalleVenta> detalles;
  final double subtotal;
  final double iva;
  final double total;
  final String metodoPago;
  final double? montoRecibido;
  final double? cambio;
  final DateTime? fecha;

  const Venta({
    this.id,
    this.folio,
    required this.detalles,
    required this.subtotal,
    required this.iva,
    required this.total,
    required this.metodoPago,
    this.montoRecibido,
    this.cambio,
    this.fecha,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: json['id'] as int?,
      folio: json['folio'] as String?,
      detalles: (json['detalles'] as List<dynamic>?)
              ?.map((d) => DetalleVenta.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num).toDouble(),
      iva: (json['iva'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      metodoPago: json['metodo_pago'] as String,
      montoRecibido: json['monto_recibido'] != null
          ? (json['monto_recibido'] as num).toDouble()
          : null,
      cambio: json['cambio'] != null
          ? (json['cambio'] as num).toDouble()
          : null,
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detalles': detalles.map((d) => d.toJson()).toList(),
      'subtotal': subtotal,
      'iva': iva,
      'total': total,
      'metodo_pago': metodoPago,
      'monto_recibido': montoRecibido,
      'cambio': cambio,
    };
  }
}
