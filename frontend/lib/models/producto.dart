import '../domain/enums.dart';

class Producto {
  final int id;
  final String? codigoBarras;
  final String nombre;
  final String? marca;
  final String? descripcion;
  final String? uso;
  final double precioCompra;
  final double precioVenta;
  final double? precioMayoreo;
  final UnidadMedida unidadMedida;
  final int stockActual;
  final int stockMinimo;
  final int? categoriaId;
  final String? ubicacion;
  final bool activo;

  const Producto({
    required this.id,
    this.codigoBarras,
    required this.nombre,
    this.marca,
    this.descripcion,
    this.uso,
    required this.precioCompra,
    required this.precioVenta,
    this.precioMayoreo,
    this.unidadMedida = UnidadMedida.pieza,
    required this.stockActual,
    required this.stockMinimo,
    this.categoriaId,
    this.ubicacion,
    required this.activo,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as int,
      codigoBarras: json['codigo_barras'] as String?,
      nombre: json['nombre'] as String,
      marca: json['marca'] as String?,
      descripcion: json['descripcion'] as String?,
      precioCompra: (json['precio_compra'] as num).toDouble(),
      precioVenta: (json['precio_venta'] as num).toDouble(),
      precioMayoreo: (json['precio_mayoreo'] as num?)?.toDouble(),
      unidadMedida: UnidadMedida.fromValue(json['unidad_medida'] as String?),
      stockActual: json['stock_actual'] as int,
      stockMinimo: json['stock_minimo'] as int,
      categoriaId: json['categoria_id'] as int?,
      uso: json['uso'] as String?,
      ubicacion: json['ubicacion'] as String?,
      activo: json['activo'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo_barras': codigoBarras,
      'nombre': nombre,
      'marca': marca,
      'descripcion': descripcion,
      'uso': uso,
      'precio_compra': precioCompra,
      'precio_venta': precioVenta,
      'precio_mayoreo': precioMayoreo,
      'unidad_medida': unidadMedida.value,
      'stock_actual': stockActual,
      'stock_minimo': stockMinimo,
      'categoria_id': categoriaId,
      'ubicacion': ubicacion,
    };
  }

  /// Ganancia unitaria = precioVenta - precioCompra.
  /// Negativa si el precio de venta es menor al de compra (caso de error).
  double get gananciaUnitaria => precioVenta - precioCompra;

  /// Margen porcentual sobre el precio de compra. Null si no hay precio
  /// de compra registrado (evita división por cero).
  double? get margenPorcentaje {
    if (precioCompra <= 0) return null;
    return ((precioVenta - precioCompra) / precioCompra) * 100;
  }

  /// Etiqueta corta del margen para mostrar en UI (ej: "32% margen").
  String get margenLabel {
    final m = margenPorcentaje;
    if (m == null) return 'Sin margen';
    final rounded = m.toStringAsFixed(1);
    return '$rounded% margen';
  }

  StockLevel get stockLevel {
    if (stockActual <= 0) return StockLevel.outOfStock;
    if (stockActual <= stockMinimo) return StockLevel.low;
    if (stockActual <= stockMinimo * 2) return StockLevel.medium;
    return StockLevel.high;
  }
}

enum StockLevel { outOfStock, low, medium, high }