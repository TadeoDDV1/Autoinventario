class DetalleEntrada {
  final int id;
  final int entradaId;
  final int productoId;
  final String nombreProducto;
  final int cantidad;
  final double costoUnitario;

  const DetalleEntrada({
    this.id = 0,
    this.entradaId = 0,
    required this.productoId,
    this.nombreProducto = '',
    required this.cantidad,
    required this.costoUnitario,
  });

  double get subtotal => cantidad * costoUnitario;

  factory DetalleEntrada.fromJson(Map<String, dynamic> json) {
    return DetalleEntrada(
      id: (json['id'] as num?)?.toInt() ?? 0,
      entradaId: (json['entrada_id'] as num?)?.toInt() ?? 0,
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

/// Respuesta paginada genérica para listas que vienen del backend
/// con metadata `total`, `page`, `page_size`, `total_pages`.
class PaginatedEntradas {
  final List<EntradaInventario> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaginatedEntradas({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
  bool get isEmpty => items.isEmpty;

  factory PaginatedEntradas.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['data'] as List<dynamic>?) ?? const [];
    return PaginatedEntradas(
      items: rawItems
          .map((e) => EntradaInventario.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Filtro para consultar el historial de entradas. Es inmutable;
/// [`copyWith`] permite actualizar páginas/filtros sin recrear la lista.
class HistorialFiltro {
  final String? desde;
  final String? hasta;
  final String? proveedor;
  final String? q;
  final int page;
  final int pageSize;

  const HistorialFiltro({
    this.desde,
    this.hasta,
    this.proveedor,
    this.q,
    this.page = 1,
    this.pageSize = 20,
  });

  HistorialFiltro copyWith({
    String? desde,
    String? hasta,
    String? proveedor,
    String? q,
    int? page,
    int? pageSize,
    bool clearDesde = false,
    bool clearHasta = false,
    bool clearProveedor = false,
    bool clearQ = false,
  }) {
    return HistorialFiltro(
      desde: clearDesde ? null : (desde ?? this.desde),
      hasta: clearHasta ? null : (hasta ?? this.hasta),
      proveedor: clearProveedor ? null : (proveedor ?? this.proveedor),
      q: clearQ ? null : (q ?? this.q),
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  bool get hasFiltros =>
      (desde != null && desde!.isNotEmpty) ||
      (hasta != null && hasta!.isNotEmpty) ||
      (proveedor != null && proveedor!.isNotEmpty) ||
      (q != null && q!.isNotEmpty);

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (desde != null && desde!.isNotEmpty) params['desde'] = desde;
    if (hasta != null && hasta!.isNotEmpty) params['hasta'] = hasta;
    if (proveedor != null && proveedor!.isNotEmpty) {
      params['proveedor'] = proveedor;
    }
    if (q != null && q!.isNotEmpty) params['q'] = q;
    return params;
  }
}
