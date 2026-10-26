import 'dart:convert' show jsonEncode;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/producto.dart';
import '../models/categoria.dart';
import '../models/paginated_response.dart';
import '../domain/enums.dart';
import '../services/api_service.dart';
import '../database/app_database.dart' as drift_db;
import '../database/database_provider.dart';
import '../core/errors/api_exception.dart';

/// Convierte un Producto de la BD drift a un Producto del modelo de dominio.
Producto _dbProductoToModel(drift_db.Producto p) {
  return Producto(
    id: p.id,
    codigoBarras: p.codigoBarras,
    nombre: p.nombre,
    marca: p.marca,
    descripcion: p.descripcion,
    uso: p.uso,
    precioCompra: p.precioCompra,
    precioVenta: p.precioVenta,
    precioMayoreo: p.precioMayoreo,
    unidadMedida: UnidadMedida.fromValue(p.unidadMedida),
    stockActual: p.stockActual,
    stockMinimo: p.stockMinimo,
    categoriaId: p.categoriaId,
    ubicacion: p.ubicacion,
    activo: p.activo,
  );
}

/// Convierte una Categoría de la BD drift a un modelo de dominio.
Categoria _dbCategoriaToModel(drift_db.Categoria c) {
  return Categoria(id: c.id, nombre: c.nombre, descripcion: c.descripcion);
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final productoSearchProvider = NotifierProvider<ProductoSearchNotifier, String>(
  ProductoSearchNotifier.new,
);
final productoCategoriaFilterProvider =
    NotifierProvider<ProductoCategoriaFilterNotifier, int?>(
      ProductoCategoriaFilterNotifier.new,
    );
final productoPageProvider = NotifierProvider<ProductoPageNotifier, int>(
  ProductoPageNotifier.new,
);

class ProductoSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) {
    state = value;
  }
}

class ProductoCategoriaFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void update(int? value) {
    state = value;
  }
}

class ProductoPageNotifier extends Notifier<int> {
  @override
  int build() => 1;

  void update(int value) {
    state = value;
  }
}

final productosProvider =
    AsyncNotifierProvider<ProductosNotifier, PaginatedResponse<Producto>>(
      ProductosNotifier.new,
    );

class ProductosNotifier extends AsyncNotifier<PaginatedResponse<Producto>> {
  @override
  Future<PaginatedResponse<Producto>> build() async {
    final search = ref.watch(productoSearchProvider);
    final categoriaId = ref.watch(productoCategoriaFilterProvider);
    final database = ref.read(appDatabaseProvider);

    // 1. Intentar leer de la BD local primero
    try {
      List<drift_db.Producto> localProductos;
      if (search.isNotEmpty) {
        localProductos = await database.buscarProductos(search);
      } else if (categoriaId != null) {
        localProductos = await database.getProductosByCategoria(categoriaId);
      } else {
        localProductos = await database.getAllProductos();
      }

      if (localProductos.isNotEmpty) {
        return PaginatedResponse(
          data: localProductos.map(_dbProductoToModel).toList(),
          total: localProductos.length,
          page: 1,
          pageSize: 200,
          totalPages: 1,
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('DB read fallback: $e');
    }

    // 2. Si la BD está vacía, intentar del backend
    try {
      final api = ref.read(apiServiceProvider);
      final result = await api.getProductos(
        page: 1,
        search: search.isEmpty ? null : search,
        categoriaId: categoriaId,
      );
      return result;
    } on ApiException {
      return PaginatedResponse(
        data: [],
        total: 0,
        page: 1,
        pageSize: 20,
        totalPages: 0,
      );
    }
  }

  /// Crea un producto SIEMPRE en la BD local (offline-first estricto).
  /// Lo guarda con ID provisional negativo y lo encola en
  /// [ProductosPendientes] para que el botón Sincronizar lo suba al
  /// servidor. Devuelve el producto creado con su ID provisional.
  Future<Producto> createProducto(Map<String, dynamic> data) async {
    final creado = await _crearProductoOffline(data);
    return creado;
  }

  Future<Producto> _crearProductoOffline(Map<String, dynamic> data) async {
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    final clientId =
        'prod-${now.millisecondsSinceEpoch}-${now.hashCode.toRadixString(16)}';

    final companion = drift_db.ProductosCompanion.insert(
      nombre: data['nombre'] as String,
      precioCompra: (data['precio_compra'] as num?)?.toDouble() ?? 0,
      precioVenta: (data['precio_venta'] as num?)?.toDouble() ?? 0,
      unidadMedida:
          (data['unidad_medida'] as String?) ?? UnidadMedida.pieza.value,
      stockActual: (data['stock_actual'] as int?) ?? 0,
      stockMinimo: (data['stock_minimo'] as int?) ?? 0,
      activo: true,
      createdAt: now,
      updatedAt: now,
      codigoBarras: Value(data['codigo_barras'] as String?),
      marca: Value(data['marca'] as String?),
      descripcion: Value(data['descripcion'] as String?),
      uso: Value(data['uso'] as String?),
      precioMayoreo: Value((data['precio_mayoreo'] as num?)?.toDouble()),
      categoriaId: Value(data['categoria_id'] as int?),
      ubicacion: Value(data['ubicacion'] as String?),
    );

    final idProvisional = await db.insertProductoLocal(companion);

    // Encolar para sincronización posterior
    await db.addProductoPendiente(
      drift_db.ProductosPendientesCompanion.insert(
        clientId: clientId,
        createdAt: now,
        productoData: _jsonEncode(data),
      ),
    );

    if (kDebugMode) {
      debugPrint('createProducto offline: id=$idProvisional client=$clientId');
    }

    ref.invalidateSelf();

    return Producto(
      id: idProvisional,
      codigoBarras: data['codigo_barras'] as String?,
      nombre: data['nombre'] as String,
      marca: data['marca'] as String?,
      descripcion: data['descripcion'] as String?,
      uso: data['uso'] as String?,
      precioCompra: (data['precio_compra'] as num?)?.toDouble() ?? 0,
      precioVenta: (data['precio_venta'] as num?)?.toDouble() ?? 0,
      precioMayoreo: (data['precio_mayoreo'] as num?)?.toDouble(),
      unidadMedida: UnidadMedida.fromValue(data['unidad_medida'] as String?),
      stockActual: (data['stock_actual'] as int?) ?? 0,
      stockMinimo: (data['stock_minimo'] as int?) ?? 0,
      categoriaId: data['categoria_id'] as int?,
      ubicacion: data['ubicacion'] as String?,
      activo: true,
    );
  }

  String _jsonEncode(Map<String, dynamic> data) {
    try {
      return jsonEncode(data);
    } catch (_) {
      return '{}';
    }
  }

  Future<void> updateProducto(int id, Map<String, dynamic> data) async {
    final db = ref.read(appDatabaseProvider);

    // 1. Actualizar BD local primero (offline-first)
    final now = DateTime.now();
    await db.actualizarProductoLocal(
      id,
      drift_db.ProductosCompanion(
        nombre: Value(data['nombre'] as String? ?? ''),
        marca: Value(data['marca'] as String?),
        codigoBarras: Value(data['codigo_barras'] as String?),
        descripcion: Value(data['descripcion'] as String?),
        uso: Value(data['uso'] as String?),
        precioCompra: Value((data['precio_compra'] as num?)?.toDouble() ?? 0),
        precioVenta: Value((data['precio_venta'] as num?)?.toDouble() ?? 0),
        precioMayoreo: Value((data['precio_mayoreo'] as num?)?.toDouble()),
        unidadMedida: Value(
          (data['unidad_medida'] as String?) ?? UnidadMedida.pieza.value,
        ),
        stockActual: Value((data['stock_actual'] as int?) ?? 0),
        stockMinimo: Value((data['stock_minimo'] as int?) ?? 0),
        categoriaId: Value(data['categoria_id'] as int?),
        ubicacion: Value(data['ubicacion'] as String?),
        updatedAt: Value(now),
      ),
    );

    // 2. Si el producto ya tiene ID real del servidor, encolar el update
    // para sincronización. Productos provisionales (id < 0) ya tienen su
    // POST pendiente y no deben duplicarse.
    if (id > 0) {
      final payload = {...data, '_accion': 'update', '_id_remoto': id};
      await db.addProductoPendiente(
        drift_db.ProductosPendientesCompanion.insert(
          clientId:
              'prod-upd-$now.millisecondsSinceEpoch-${now.hashCode.toRadixString(16)}',
          createdAt: now,
          productoData: _jsonEncode(payload),
        ),
      );
    }

    ref.invalidateSelf();
  }

  Future<void> deleteProducto(int id) async {
    final api = ref.read(apiServiceProvider);
    await api.deleteProducto(id);
    ref.invalidateSelf();
  }

  void refresh() {
    ref.invalidateSelf();
  }
}

final categoriasProvider =
    AsyncNotifierProvider<CategoriasNotifier, List<Categoria>>(
      CategoriasNotifier.new,
    );

class CategoriasNotifier extends AsyncNotifier<List<Categoria>> {
  @override
  Future<List<Categoria>> build() async {
    final database = ref.read(appDatabaseProvider);

    // 1. Intentar de la BD local
    try {
      final localCategorias = await database.getAllCategorias();
      if (localCategorias.isNotEmpty) {
        return localCategorias.map(_dbCategoriaToModel).toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Categorias DB read fallback: $e');
    }

    // 2. Si vacía, intentar del backend
    try {
      final api = ref.read(apiServiceProvider);
      return await api.getCategorias();
    } on ApiException {
      return [];
    }
  }

  void refresh() {
    ref.invalidateSelf();
  }
}

Map<String, dynamic> buildRapidoCreatePayload({
  required String nombre,
  required String codigoBarras,
  required double precioVenta,
}) {
  return {
    'nombre': nombre,
    'codigo_barras': codigoBarras.trim(),
    'precio_venta': precioVenta,
    'precio_compra': 0,
    'stock_actual': 1,
    'stock_minimo': 1,
  };
}

/// Producto individual por ID desde la BD local (offline-first).
/// Si no existe localmente, intenta la API como fallback.
final productoByIdProvider = FutureProvider.family<Producto?, int>((
  ref,
  id,
) async {
  final database = ref.read(appDatabaseProvider);
  try {
    final local = await database.getProductoById(id);
    if (local != null) {
      return _dbProductoToModel(local);
    }
  } catch (e) {
    if (kDebugMode) debugPrint('productoByIdProvider local: $e');
  }
  // Fallback a la API
  try {
    final api = ref.read(apiServiceProvider);
    return await api.getProductoById(id);
  } catch (_) {
    return null;
  }
});
