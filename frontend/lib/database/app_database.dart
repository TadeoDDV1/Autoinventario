import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Productos extends Table {
  IntColumn get id => integer().named('id').autoIncrement()();
  TextColumn get codigoBarras => text().named('codigo_barras').nullable()();
  TextColumn get sku => text().named('sku').nullable()();
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
  TextColumn get categoriaNombre => text().named('categoria_nombre').nullable()();
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
  TextColumn get clientId => text().named('client_id').customConstraint('UNIQUE')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  TextColumn get ventaData => text().named('venta_data')(); // JSON representation
  RealColumn get total => real().named('total')();
  BoolColumn get synced => boolean().withDefault(const Constant(false)).named('synced')();
}

@DriftDatabase(tables: [Productos, Categorias, VentasPendientes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Productos
  Future<void> clearProductos() => delete(productos).go();
  Future<void> insertProductos(List<ProductosCompanion> rows) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(productos, rows);
    });
  }
  Future<List<Producto>> getAllProductos() => select(productos).get();

  // Categorias
  Future<void> clearCategorias() => delete(categorias).go();
  Future<void> insertCategorias(List<CategoriasCompanion> rows) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(categorias, rows);
    });
  }
  Future<List<Categoria>> getAllCategorias() => select(categorias).get();

  // Ventas pendientes
  Future<void> addVentaPendiente(VentasPendientesCompanion row) async {
    await into(ventasPendientes).insertOnConflictUpdate(row);
  }
  Future<List<VentasPendiente>> getVentasPendientes() =>
      (select(ventasPendientes)..where((tbl) => tbl.synced.equals(false))).get();
  Future<void> markVentasSynced(List<String> clientIds) async {
    await (delete(ventasPendientes)..where((tbl) => tbl.clientId.isIn(clientIds))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.db'));
    return NativeDatabase(file);
  });
}
