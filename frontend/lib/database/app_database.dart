import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Productos extends Table {
  IntColumn get id => integer().named('id').autoIncrement()();
  TextColumn get codigoBarras => text().named('codigo_barras').nullable()();
  TextColumn get nombre => text().named('nombre')();
  TextColumn get marca => text().named('marca').nullable()();
  TextColumn get descripcion => text().named('descripcion').nullable()();
  TextColumn get uso => text().named('uso').nullable()();
  RealColumn get precioCompra => real().named('precio_compra')();
  RealColumn get precioVenta => real().named('precio_venta')();
  RealColumn get precioMayoreo => real().named('precio_mayoreo').nullable()();
  TextColumn get unidadMedida => text().named('unidad_medida')();
  IntColumn get stockActual => integer().named('stock_actual')();
  IntColumn get stockMinimo => integer().named('stock_minimo')();
  IntColumn get categoriaId => integer().named('categoria_id').nullable()();
  TextColumn get ubicacion => text().named('ubicacion').nullable()();
  BoolColumn get activo => boolean().named('activo')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
}

class Categorias extends Table {
  IntColumn get id => integer().named('id').autoIncrement()();
  TextColumn get nombre => text().named('nombre')();
  TextColumn get descripcion => text().named('descripcion').nullable()();
  BoolColumn get activo => boolean().named('activo')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
}

class VentasPendientes extends Table {
  TextColumn get clientId => text().named('client_id')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  TextColumn get ventaData => text().named('venta_data')();
  RealColumn get total => real().named('total')();
  BoolColumn get synced => boolean().withDefault(const Constant(false)).named('synced')();

  @override
  Set<Column> get primaryKey => {clientId};
}

class EntradasPendientes extends Table {
  TextColumn get clientId => text().named('client_id')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  TextColumn get entradaData => text().named('entrada_data')();
  BoolColumn get synced => boolean().withDefault(const Constant(false)).named('synced')();

  @override
  Set<Column> get primaryKey => {clientId};
}

class ProductosPendientes extends Table {
  TextColumn get clientId => text().named('client_id')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  TextColumn get productoData => text().named('producto_data')();
  BoolColumn get synced => boolean().withDefault(const Constant(false)).named('synced')();

  @override
  Set<Column> get primaryKey => {clientId};
}

/// Ventas completadas (sincronizadas del servidor o creadas offline y ya subidas).
/// Esta es la fuente de verdad para el historial de ventas y el dashboard.
class VentasLocal extends Table {
  IntColumn get id => integer().named('id')();
  TextColumn get folio => text().named('folio').nullable()();
  TextColumn get clientId => text().named('client_id').nullable()();
  DateTimeColumn get fecha => dateTime().named('fecha')();
  RealColumn get subtotal => real().named('subtotal')();
  RealColumn get iva => real().named('iva')();
  RealColumn get total => real().named('total')();
  TextColumn get metodoPago => text().named('metodo_pago')();
  RealColumn get montoRecibido => real().named('monto_recibido').nullable()();
  RealColumn get cambio => real().named('cambio').nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(true)).named('synced')();

  @override
  Set<Column> get primaryKey => {id};
}

/// Línea items de cada venta.
class VentasDetalleLocal extends Table {
  IntColumn get id => integer().named('id').autoIncrement()();
  IntColumn get ventaId => integer().named('venta_id')();
  IntColumn get productoId => integer().named('producto_id')();
  TextColumn get nombreProducto => text().named('nombre_producto')();
  RealColumn get precioUnitario => real().named('precio_unitario')();
  IntColumn get cantidad => integer().named('cantidad')();
  RealColumn get subtotal => real().named('subtotal')();
}

/// Entradas de inventario confirmadas (sincronizadas del servidor o creadas offline y ya subidas).
class EntradasLocal extends Table {
  IntColumn get id => integer().named('id')();
  TextColumn get folio => text().named('folio').nullable()();
  TextColumn get proveedor => text().named('proveedor').nullable()();
  TextColumn get observaciones => text().named('observaciones').nullable()();
  RealColumn get total => real().named('total')();
  DateTimeColumn get fecha => dateTime().named('fecha')();
  TextColumn get clientId => text().named('client_id').nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(true)).named('synced')();

  @override
  Set<Column> get primaryKey => {id};
}

/// Línea items de cada entrada de inventario.
class EntradasDetalleLocal extends Table {
  IntColumn get id => integer().named('id').autoIncrement()();
  IntColumn get entradaId => integer().named('entrada_id')();
  IntColumn get productoId => integer().named('producto_id')();
  TextColumn get nombreProducto => text().named('nombre_producto')();
  IntColumn get cantidad => integer().named('cantidad')();
  RealColumn get costoUnitario => real().named('costo_unitario')();
}

/// Metadata de sincronización (último sync, configuración, etc).
class SyncMeta extends Table {
  TextColumn get key => text().named('key')();
  TextColumn get value => text().named('value')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [
  Productos,
  Categorias,
  VentasPendientes,
  EntradasPendientes,
  ProductosPendientes,
  VentasLocal,
  VentasDetalleLocal,
  EntradasLocal,
  EntradasDetalleLocal,
  SyncMeta,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.test() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await m.database.customStatement('PRAGMA foreign_keys = ON;');
          await m.database.customStatement('CREATE INDEX IF NOT EXISTS idx_productos_nombre ON productos (nombre DESC);');
          await m.database.customStatement('CREATE INDEX IF NOT EXISTS idx_productos_categoria ON productos (categoria_id DESC);');
          await m.database.customStatement('CREATE INDEX IF NOT EXISTS idx_ventas_fecha ON ventas_local (fecha DESC);');
          await m.database.customStatement('CREATE INDEX IF NOT EXISTS idx_ventas_detalle_venta ON ventas_detalle_local (venta_id DESC);');
          await m.database.customStatement('CREATE INDEX IF NOT EXISTS idx_entradas_fecha ON entradas_local (fecha DESC);');
          await m.database.customStatement('CREATE INDEX IF NOT EXISTS idx_entradas_detalle_entrada ON entradas_detalle_local (entrada_id DESC);');
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.database.customStatement('CREATE INDEX IF NOT EXISTS idx_productos_nombre ON productos (nombre DESC);');
            await m.database.customStatement('CREATE INDEX IF NOT EXISTS idx_productos_categoria ON productos (categoria_id DESC);');
            await m.database.customStatement('UPDATE productos SET activo = 1 WHERE activo IS NULL;');
            await m.database.customStatement('DELETE FROM productos WHERE id IS NULL OR nombre IS NULL;');
          }
          if (from < 3) {
            await m.createTable(entradasPendientes);
          }
          if (from < 4) {
            await m.createTable(productosPendientes);
          }
          if (from < 5) {
            await m.createTable(ventasLocal);
            await m.createTable(ventasDetalleLocal);
            await m.createTable(entradasLocal);
            await m.createTable(entradasDetalleLocal);
            await m.createTable(syncMeta);
            try {
              await m.database.customStatement('CREATE INDEX IF NOT EXISTS idx_ventas_fecha ON ventas_local (fecha DESC);');
              await m.database.customStatement('CREATE INDEX IF NOT EXISTS idx_ventas_detalle_venta ON ventas_detalle_local (venta_id DESC);');
              await m.database.customStatement('CREATE INDEX IF NOT EXISTS idx_entradas_fecha ON entradas_local (fecha DESC);');
              await m.database.customStatement('CREATE INDEX IF NOT EXISTS idx_entradas_detalle_entrada ON entradas_detalle_local (entrada_id DESC);');
            } catch (_) {
              // Los índices no son críticos — la migración debe continuar
            }
          }
          await m.database.customStatement('PRAGMA foreign_keys = ON;');
        },
      );

  // ========== PRODUCTOS ==========
  Future<void> clearProductos() => delete(productos).go();
  Future<void> insertProductos(List<ProductosCompanion> rows) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(productos, rows);
    });
  }
  Future<List<Producto>> getAllProductos() => select(productos).get();

  Future<List<Producto>> buscarProductos(String query) {
    return (select(productos)
          ..where((tbl) =>
              tbl.nombre.like('%$query%') |
              tbl.codigoBarras.like('%$query%') |
              tbl.marca.like('%$query%'))
          ..limit(50))
        .get();
  }

  Future<Producto?> getProductoById(int id) {
    return (select(productos)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<Producto?> getProductoByCodigo(String codigo) {
    return (select(productos)
          ..where((tbl) => tbl.codigoBarras.equals(codigo)))
        .getSingleOrNull();
  }

  Future<List<Producto>> getProductosByCategoria(int? categoriaId) {
    if (categoriaId == null) return getAllProductos();
    return (select(productos)
          ..where((tbl) => tbl.categoriaId.equals(categoriaId)))
        .get();
  }

  Future<int> countProductos() async {
    final count = productos.id.count();
    final result = await (selectOnly(productos)..addColumns([count])).getSingle();
    return result.read(count)!;
  }

  Future<int> insertProductoLocal(ProductosCompanion row) async {
    final id = -(DateTime.now().millisecondsSinceEpoch % 1000000);
    final withId = row.copyWith(id: Value(id));
    await into(productos).insertOnConflictUpdate(withId);
    return id;
  }

  Future<void> decrementarStock(int productoId, int cantidad) async {
    final actual = await getProductoById(productoId);
    if (actual == null) return;
    final nuevo = (actual.stockActual - cantidad).clamp(0, 1 << 31);
    await (update(productos)..where((tbl) => tbl.id.equals(productoId)))
        .write(ProductosCompanion(stockActual: Value(nuevo)));
  }

  Future<void> reemplazarProductoProvisional(int idProvisional, int idReal) async {
    await (update(productos)..where((tbl) => tbl.id.equals(idProvisional)))
        .write(ProductosCompanion(id: Value(idReal)));
  }

  Future<void> borrarProductoProvisional(int idProvisional) async {
    await (delete(productos)..where((tbl) => tbl.id.equals(idProvisional))).go();
  }

  // ========== CATEGORIAS ==========
  Future<void> clearCategorias() => delete(categorias).go();
  Future<void> insertCategorias(List<CategoriasCompanion> rows) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(categorias, rows);
    });
  }
  Future<List<Categoria>> getAllCategorias() => select(categorias).get();

  // ========== VENTAS PENDIENTES (cola offline) ==========
  Future<void> addVentaPendiente(VentasPendientesCompanion row) async {
    await into(ventasPendientes).insertOnConflictUpdate(row);
  }
  Future<List<VentasPendiente>> getVentasPendientes() =>
      (select(ventasPendientes)..where((tbl) => tbl.synced.equals(false))).get();
  Future<void> markVentasSynced(List<String> clientIds) async {
    await (delete(ventasPendientes)..where((tbl) => tbl.clientId.isIn(clientIds))).go();
  }

  // ========== ENTRADAS PENDIENTES (cola offline) ==========
  Future<void> addEntradaPendiente(EntradasPendientesCompanion row) async {
    await into(entradasPendientes).insertOnConflictUpdate(row);
  }
  Future<List<EntradasPendiente>> getEntradasPendientes() =>
      (select(entradasPendientes)..where((tbl) => tbl.synced.equals(false))).get();
  Future<void> markEntradasSynced(List<String> clientIds) async {
    await (delete(entradasPendientes)..where((tbl) => tbl.clientId.isIn(clientIds))).go();
  }

  // ========== PRODUCTOS PENDIENTES (cola offline) ==========
  Future<void> addProductoPendiente(ProductosPendientesCompanion row) async {
    await into(productosPendientes).insertOnConflictUpdate(row);
  }
  Future<List<ProductosPendiente>> getProductosPendientes() =>
      (select(productosPendientes)..where((tbl) => tbl.synced.equals(false))).get();
  Future<void> markProductosSynced(List<String> clientIds) async {
    await (delete(productosPendientes)..where((tbl) => tbl.clientId.isIn(clientIds))).go();
  }

  // ========== VENTAS (confirmadas) ==========
  Future<void> insertVentaConDetalle(VentasLocalCompanion venta, List<VentasDetalleLocalCompanion> detalles) async {
    await transaction(() async {
      await into(ventasLocal).insertOnConflictUpdate(venta);
      for (final d in detalles) {
        await into(ventasDetalleLocal).insert(d);
      }
    });
  }

  Future<void> upsertVentaConDetalle(VentasLocalCompanion venta, List<VentasDetalleLocalCompanion> detalles) async {
    await transaction(() async {
      await into(ventasLocal).insertOnConflictUpdate(venta);
      await (delete(ventasDetalleLocal)..where((tbl) => tbl.ventaId.equals(venta.id.value))).go();
      for (final d in detalles) {
        await into(ventasDetalleLocal).insert(d);
      }
    });
  }

  /// Reemplaza un ID temporal negativo de una venta por el ID real del servidor.
  /// También actualiza los detalles asociados.
  Future<void> reemplazarIdVentaLocal(int idTemporal, int idReal) async {
    await transaction(() async {
      // Actualizar el ID de la venta
      await (update(ventasLocal)..where((tbl) => tbl.id.equals(idTemporal)))
          .write(VentasLocalCompanion(id: Value(idReal), synced: const Value(true)));
      // Actualizar los detalles asociados
      await (update(ventasDetalleLocal)..where((tbl) => tbl.ventaId.equals(idTemporal)))
          .write(VentasDetalleLocalCompanion(ventaId: Value(idReal)));
    });
  }

  Future<void> clearVentas() async {
    await transaction(() async {
      await delete(ventasDetalleLocal).go();
      await delete(ventasLocal).go();
    });
  }

  Future<List<VentasLocalData>> getAllVentas({int limit = 500}) {
    return (select(ventasLocal)
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
          ..limit(limit))
        .get();
  }

  Future<VentasLocalData?> getVentaByIdLocal(int id) {
    return (select(ventasLocal)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<List<VentasDetalleLocalData>> getDetallesByVenta(int ventaId) {
    return (select(ventasDetalleLocal)..where((tbl) => tbl.ventaId.equals(ventaId))).get();
  }

  Future<int> countVentas() async {
    final count = ventasLocal.id.count();
    final result = await (selectOnly(ventasLocal)..addColumns([count])).getSingle();
    return result.read(count) ?? 0;
  }

  // ========== ENTRADAS (confirmadas) ==========
  Future<void> insertEntradaConDetalle(EntradasLocalCompanion entrada, List<EntradasDetalleLocalCompanion> detalles) async {
    await transaction(() async {
      await into(entradasLocal).insertOnConflictUpdate(entrada);
      for (final d in detalles) {
        await into(entradasDetalleLocal).insert(d);
      }
    });
  }

  Future<void> upsertEntradaConDetalle(EntradasLocalCompanion entrada, List<EntradasDetalleLocalCompanion> detalles) async {
    await transaction(() async {
      await into(entradasLocal).insertOnConflictUpdate(entrada);
      await (delete(entradasDetalleLocal)..where((tbl) => tbl.entradaId.equals(entrada.id.value))).go();
      for (final d in detalles) {
        await into(entradasDetalleLocal).insert(d);
      }
    });
  }

  Future<void> clearEntradas() async {
    await transaction(() async {
      await delete(entradasDetalleLocal).go();
      await delete(entradasLocal).go();
    });
  }

  Future<List<EntradasLocalData>> getAllEntradas({int limit = 500}) {
    return (select(entradasLocal)
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
          ..limit(limit))
        .get();
  }

  Future<EntradasLocalData?> getEntradaByIdLocal(int id) {
    return (select(entradasLocal)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<List<EntradasDetalleLocalData>> getDetallesByEntrada(int entradaId) {
    return (select(entradasDetalleLocal)..where((tbl) => tbl.entradaId.equals(entradaId))).get();
  }

  Future<int> countEntradas() async {
    final count = entradasLocal.id.count();
    final result = await (selectOnly(entradasLocal)..addColumns([count])).getSingle();
    return result.read(count) ?? 0;
  }

  // ========== SYNC META ==========
  Future<void> setSyncMeta(String key, String value) async {
    await into(syncMeta).insertOnConflictUpdate(
      SyncMetaCompanion(
        key: Value(key),
        value: Value(value),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<String?> getSyncMeta(String key) async {
    final row = await (select(syncMeta)..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
    return row?.value;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.db'));
    return NativeDatabase(file);
  });
}
