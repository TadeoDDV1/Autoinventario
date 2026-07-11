class Producto {
  final int id;
  final String? codigoBarras;
  final String nombre;
  final String? descripcion;
  final double precioCompra;
  final double precioVenta;
  final int stockActual;
  final int stockMinimo;
  final int? categoriaId;
  final bool activo;
  final String? categoriaNombre;
  final String? uso;

  const Producto({
    required this.id,
    this.codigoBarras,
    required this.nombre,
    this.descripcion,
    this.uso,
    required this.precioCompra,
    required this.precioVenta,
    required this.stockActual,
    required this.stockMinimo,
    this.categoriaId,
    required this.activo,
    this.categoriaNombre,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as int,
      codigoBarras: json['codigo_barras'] as String?,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      precioCompra: (json['precio_compra'] as num).toDouble(),
      precioVenta: (json['precio_venta'] as num).toDouble(),
      stockActual: json['stock_actual'] as int,
      stockMinimo: json['stock_minimo'] as int,
      categoriaId: json['categoria_id'] as int?,
      uso: json['uso'] as String?,
      activo: json['activo'] as bool,
      categoriaNombre: json['categoria_nombre'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo_barras': codigoBarras,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio_compra': precioCompra,
      'precio_venta': precioVenta,
      'stock_actual': stockActual,
      'stock_minimo': stockMinimo,
      'uso': uso,
      'categoria_id': categoriaId,
    };
  }

  StockLevel get stockLevel {
    if (stockActual <= 0) return StockLevel.outOfStock;
    if (stockActual <= stockMinimo) return StockLevel.low;
    if (stockActual <= stockMinimo * 2) return StockLevel.medium;
    return StockLevel.high;
  }
}

enum StockLevel { outOfStock, low, medium, high }
