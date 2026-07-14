// Modelos para el módulo de IA.
class Sugerencia {
  final String tipo; // "complemento" | "sustituto" | "alerta_stock" | "upgrade"
  final int productoId;
  final String nombre;
  final double precio;
  final String razon;

  // Campos enriquecidos (opcionales, vienen del backend si están disponibles)
  final String? descripcion;
  final List<int> compatibles;
  final int? stockActual;
  final String nivelUrgencia; // "bajo" | "medio" | "alto" | ""

  const Sugerencia({
    required this.tipo,
    required this.productoId,
    required this.nombre,
    required this.precio,
    required this.razon,
    this.descripcion,
    this.compatibles = const <int>[],
    this.stockActual,
    this.nivelUrgencia = '',
  });

  factory Sugerencia.fromJson(Map<String, dynamic> json) {
    return Sugerencia(
      tipo: json['tipo'] as String? ?? 'complemento',
      productoId: (json['producto_id'] as num).toInt(),
      nombre: json['nombre'] as String? ?? 'Producto',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      razon: json['razon'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      compatibles: ((json['compatibles'] as List<dynamic>?) ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
      stockActual: (json['stock_actual'] as num?)?.toInt(),
      nivelUrgencia: json['nivel_urgencia'] as String? ?? '',
    );
  }

  /// Etiqueta corta según el tipo (para el header del recuadro).
  String get etiqueta {
    switch (tipo) {
      case 'alerta_stock':
        return 'Stock bajo';
      case 'sustituto':
        return 'Alternativa';
      case 'upgrade':
        return 'Versión mejorada';
      default:
        return 'Sugerencia';
    }
  }
}

class SugerenciasResponse {
  final List<Sugerencia> sugerencias;
  final String fuente; // "reglas_locales" | "hibrido" | "cache"

  const SugerenciasResponse({
    required this.sugerencias,
    required this.fuente,
  });

  factory SugerenciasResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['sugerencias'] as List<dynamic>?) ?? const [];
    return SugerenciasResponse(
      sugerencias: list
          .map((e) => Sugerencia.fromJson(e as Map<String, dynamic>))
          .toList(),
      fuente: json['fuente'] as String? ?? 'desconocido',
    );
  }
}

class DashboardResumen {
  final String fecha;
  final double ventasHoy;
  final int transaccionesHoy;
  final double ticketPromedio;
  final double ventasAyer;
  final double variacionPct;
  final double ventasEfectivo;
  final double ventasTarjeta;
  final List<TopProducto> topProductos;
  final List<StockBajoItem> stockBajo;
  final List<VentasDia> ventasUltimos7Dias;

  const DashboardResumen({
    required this.fecha,
    required this.ventasHoy,
    required this.transaccionesHoy,
    required this.ticketPromedio,
    required this.ventasAyer,
    required this.variacionPct,
    required this.ventasEfectivo,
    required this.ventasTarjeta,
    required this.topProductos,
    required this.stockBajo,
    required this.ventasUltimos7Dias,
  });

  factory DashboardResumen.fromJson(Map<String, dynamic> json) {
    return DashboardResumen(
      fecha: json['fecha'] as String? ?? '',
      ventasHoy: (json['ventas_hoy'] as num?)?.toDouble() ?? 0,
      transaccionesHoy: (json['transacciones_hoy'] as num?)?.toInt() ?? 0,
      ticketPromedio: (json['ticket_promedio'] as num?)?.toDouble() ?? 0,
      ventasAyer: (json['ventas_ayer'] as num?)?.toDouble() ?? 0,
      variacionPct: (json['variacion_pct'] as num?)?.toDouble() ?? 0,
      ventasEfectivo: (json['ventas_efectivo'] as num?)?.toDouble() ?? 0,
      ventasTarjeta: (json['ventas_tarjeta'] as num?)?.toDouble() ?? 0,
      topProductos: ((json['top_productos'] as List<dynamic>?) ?? const [])
          .map((e) => TopProducto.fromJson(e as Map<String, dynamic>))
          .toList(),
      stockBajo: ((json['stock_bajo'] as List<dynamic>?) ?? const [])
          .map((e) => StockBajoItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      ventasUltimos7Dias: ((json['ventas_ultimos_7_dias'] as List<dynamic>?) ??
              const [])
          .map((e) => VentasDia.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TopProducto {
  final int productoId;
  final String nombre;
  final int cantidad;
  final double totalVenta;

  const TopProducto({
    required this.productoId,
    required this.nombre,
    required this.cantidad,
    required this.totalVenta,
  });

  factory TopProducto.fromJson(Map<String, dynamic> json) {
    return TopProducto(
      productoId: json['producto_id'] as int,
      nombre: json['nombre'] as String,
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 0,
      totalVenta: (json['total_venta'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PrediccionInventario {
  final int productoId;
  final String nombre;
  final String categoria;
  final int stockActual;
  final int stockMinimo;
  final double precioVenta;
  final int vendidosUltimos30D;
  final double promedioDiario;
  final double diasRestantes;
  final String fechaAgotamiento;
  final int cantidadSugerida;
  final String nivelUrgencia;
  final String razon;

  const PrediccionInventario({
    required this.productoId,
    required this.nombre,
    required this.categoria,
    required this.stockActual,
    required this.stockMinimo,
    required this.precioVenta,
    required this.vendidosUltimos30D,
    required this.promedioDiario,
    required this.diasRestantes,
    required this.fechaAgotamiento,
    required this.cantidadSugerida,
    required this.nivelUrgencia,
    required this.razon,
  });

  factory PrediccionInventario.fromJson(Map<String, dynamic> json) {
    return PrediccionInventario(
      productoId: json['producto_id'] as int,
      nombre: json['nombre'] as String,
      categoria: json['categoria'] as String? ?? '',
      stockActual: (json['stock_actual'] as num?)?.toInt() ?? 0,
      stockMinimo: (json['stock_minimo'] as num?)?.toInt() ?? 0,
      precioVenta: (json['precio_venta'] as num?)?.toDouble() ?? 0,
      vendidosUltimos30D:
          (json['vendidos_ultimos_30d'] as num?)?.toInt() ?? 0,
      promedioDiario: (json['promedio_diario'] as num?)?.toDouble() ?? 0,
      diasRestantes: (json['dias_restantes'] as num?)?.toDouble() ?? 0,
      fechaAgotamiento: json['fecha_agotamiento'] as String? ?? '',
      cantidadSugerida: (json['cantidad_sugerida'] as num?)?.toInt() ?? 0,
      nivelUrgencia: json['nivel_urgencia'] as String? ?? 'normal',
      razon: json['razon'] as String? ?? '',
    );
  }
}

class PrediccionesResumen {
  final String fechaAnalisis;
  final int totalProductos;
  final int productosCriticos;
  final int productosUrgentes;
  final int productosSinVentas;
  final int productosDormidos;
  final double valorInventario;
  final double valorCritico;
  final List<PrediccionInventario> topCriticos;
  final List<String> recomendaciones;

  const PrediccionesResumen({
    required this.fechaAnalisis,
    required this.totalProductos,
    required this.productosCriticos,
    required this.productosUrgentes,
    required this.productosSinVentas,
    required this.productosDormidos,
    required this.valorInventario,
    required this.valorCritico,
    required this.topCriticos,
    required this.recomendaciones,
  });

  factory PrediccionesResumen.fromJson(Map<String, dynamic> json) {
    return PrediccionesResumen(
      fechaAnalisis: json['fecha_analisis'] as String? ?? '',
      totalProductos: (json['total_productos'] as num?)?.toInt() ?? 0,
      productosCriticos: (json['productos_criticos'] as num?)?.toInt() ?? 0,
      productosUrgentes: (json['productos_urgentes'] as num?)?.toInt() ?? 0,
      productosSinVentas: (json['productos_sin_ventas'] as num?)?.toInt() ?? 0,
      productosDormidos: (json['productos_dormidos'] as num?)?.toInt() ?? 0,
      valorInventario: (json['valor_inventario'] as num?)?.toDouble() ?? 0,
      valorCritico: (json['valor_critico'] as num?)?.toDouble() ?? 0,
      topCriticos: ((json['top_criticos'] as List<dynamic>?) ?? const [])
          .map((e) => PrediccionInventario.fromJson(e as Map<String, dynamic>))
          .toList(),
      recomendaciones:
          ((json['recomendaciones'] as List<dynamic>?) ?? const [])
              .map((e) => e as String)
              .toList(),
    );
  }
}

class StockBajoItem {
  final int productoId;
  final String nombre;
  final int stockActual;
  final int stockMin;

  const StockBajoItem({
    required this.productoId,
    required this.nombre,
    required this.stockActual,
    required this.stockMin,
  });

  factory StockBajoItem.fromJson(Map<String, dynamic> json) {
    return StockBajoItem(
      productoId: json['producto_id'] as int,
      nombre: json['nombre'] as String,
      stockActual: (json['stock_actual'] as num?)?.toInt() ?? 0,
      stockMin: (json['stock_minimo'] as num?)?.toInt() ?? 0,
    );
  }
}

class VentaHora {
  final int hora;
  final double totalVentas;
  final int transacciones;

  const VentaHora({
    required this.hora,
    required this.totalVentas,
    required this.transacciones,
  });

  factory VentaHora.fromJson(Map<String, dynamic> json) {
    return VentaHora(
      hora: (json['hora'] as num?)?.toInt() ?? 0,
      totalVentas: (json['total_ventas'] as num?)?.toDouble() ?? 0,
      transacciones: (json['transacciones'] as num?)?.toInt() ?? 0,
    );
  }
}

class VentaReciente {
  final int id;
  final String folio;
  final double total;
  final String metodoPago;
  final DateTime fecha;
  final int numProductos;

  const VentaReciente({
    required this.id,
    required this.folio,
    required this.total,
    required this.metodoPago,
    required this.fecha,
    required this.numProductos,
  });

  factory VentaReciente.fromJson(Map<String, dynamic> json) {
    return VentaReciente(
      id: (json['id'] as num?)?.toInt() ?? 0,
      folio: json['folio'] as String? ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0,
      metodoPago: json['metodo_pago'] as String? ?? '',
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'] as String)
          : DateTime.now(),
      numProductos: (json['num_productos'] as num?)?.toInt() ?? 0,
    );
  }
}

class VentasDia {
  final String fecha;
  final double totalVentas;
  final int transacciones;

  const VentasDia({
    required this.fecha,
    required this.totalVentas,
    required this.transacciones,
  });

  factory VentasDia.fromJson(Map<String, dynamic> json) {
    return VentasDia(
      fecha: json['fecha'] as String? ?? '',
      totalVentas: (json['total_ventas'] as num?)?.toDouble() ?? 0,
      transacciones: (json['transacciones'] as num?)?.toInt() ?? 0,
    );
  }
}
