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
      productoId: (json['producto_id'] as num?)?.toInt() ?? 0,
      nombreProducto: (json['nombre_producto'] as String?) ?? 'Producto',
      precioUnitario: (json['precio_unitario'] as num?)?.toDouble() ?? 0.0,
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
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
    // El backend devuelve 'created_at' (de MySQL), pero por compat también
    // aceptamos 'fecha' como fallback.
    DateTime? parseFecha(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v as String);
      } catch (_) {
        return null;
      }
    }

    return Venta(
      id: (json['id'] as num?)?.toInt(),
      folio: json['folio'] as String?,
      detalles: (json['detalles'] as List<dynamic>?)
              ?.map((d) => DetalleVenta.fromJson(d as Map<String, dynamic>))
              .toList() ??
          const <DetalleVenta>[],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      iva: (json['iva'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      metodoPago: (json['metodo_pago'] as String?) ?? 'efectivo',
      montoRecibido: (json['monto_recibido'] as num?)?.toDouble(),
      cambio: (json['cambio'] as num?)?.toDouble(),
      fecha: parseFecha(json['created_at']) ?? parseFecha(json['fecha']),
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
