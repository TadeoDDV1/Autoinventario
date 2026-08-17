import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_database.dart';

const _initializedKey = 'db_initialized_v2';

class DatabaseInitializer {
  final AppDatabase db;

  DatabaseInitializer(this.db);

  Future<void> initializeIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyInit = prefs.getBool(_initializedKey) ?? false;
    if (alreadyInit) return;

    final count = await db.countProductos();
    if (count > 0) {
      await prefs.setBool(_initializedKey, true);
      return;
    }

    if (kDebugMode) debugPrint('DatabaseInitializer: sembrando BD inicial...');

    final now = DateTime.now();

    final categorias = [
      CategoriasCompanion.insert(
        nombre: 'Herramientas manuales',
        descripcion: Value('Martillos, destornilladores, llaves, etc.'),
        activo: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoriasCompanion.insert(
        nombre: 'Tornillería',
        descripcion: Value('Tornillos, tuercas, clavos, anclas'),
        activo: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoriasCompanion.insert(
        nombre: 'Pinturas',
        descripcion: Value('Pinturas, brochas, rodillos, thinner'),
        activo: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoriasCompanion.insert(
        nombre: 'Electricidad',
        descripcion: Value('Cables, enchufes, interruptores, breaker'),
        activo: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoriasCompanion.insert(
        nombre: 'Plomería',
        descripcion: Value('Tuberías, conexiones, llaves de paso'),
        activo: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoriasCompanion.insert(
        nombre: 'Material de construcción',
        descripcion: Value('Cemento, varilla, block, arena'),
        activo: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await db.insertCategorias(categorias);
    final cats = await db.getAllCategorias();

    final productos = [
      ProductosCompanion.insert(
        nombre: 'Martillo de uña 16oz',
        codigoBarras: Value('7501001000001'),
        marca: Value('Truper'),
        precioCompra: 85.0,
        precioVenta: 149.0,
        unidadMedida: 'pieza',
        stockActual: 12,
        stockMinimo: 3,
        categoriaId: Value(cats[0].id),
        ubicacion: Value('Pasillo A-1'),
        activo: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductosCompanion.insert(
        nombre: 'Deslizante Phillips #2 x 4"',
        codigoBarras: Value('7501001000002'),
        marca: Value('DeWalt'),
        precioCompra: 12.0,
        precioVenta: 22.0,
        unidadMedida: 'pieza',
        stockActual: 200,
        stockMinimo: 50,
        categoriaId: Value(cats[1].id),
        ubicacion: Value('Pasillo B-2'),
        activo: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductosCompanion.insert(
        nombre: 'Pintura vinílica blanca 19L',
        codigoBarras: Value('7501001000003'),
        marca: Value('Comex'),
        precioCompra: 520.0,
        precioVenta: 749.0,
        unidadMedida: 'galón',
        stockActual: 8,
        stockMinimo: 3,
        categoriaId: Value(cats[2].id),
        ubicacion: Value('Pasillo C-1'),
        activo: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductosCompanion.insert(
        nombre: 'Cable THW #12 verde-amarillo 100m',
        codigoBarras: Value('7501001000004'),
        marca: Value('Condumex'),
        precioCompra: 680.0,
        precioVenta: 950.0,
        unidadMedida: 'rollo',
        stockActual: 5,
        stockMinimo: 2,
        categoriaId: Value(cats[3].id),
        ubicacion: Value('Pasillo D-1'),
        activo: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductosCompanion.insert(
        nombre: 'PVC 3/4" tubo 6m',
        codigoBarras: Value('7501001000005'),
        marca: Value('Amanco'),
        precioCompra: 42.0,
        precioVenta: 68.0,
        unidadMedida: 'pieza',
        stockActual: 30,
        stockMinimo: 10,
        categoriaId: Value(cats[4].id),
        ubicacion: Value('Pasillo E-1'),
        activo: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductosCompanion.insert(
        nombre: 'Cemento gris 50kg',
        codigoBarras: Value('7501001000006'),
        marca: Value('Cruz Azul'),
        precioCompra: 185.0,
        precioVenta: 245.0,
        unidadMedida: 'pieza',
        stockActual: 40,
        stockMinimo: 10,
        categoriaId: Value(cats[5].id),
        ubicacion: Value('Almacén'),
        activo: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductosCompanion.insert(
        nombre: 'Destornillador plano 6x150',
        codigoBarras: Value('7501001000007'),
        marca: Value('Stanley'),
        precioCompra: 55.0,
        precioVenta: 95.0,
        unidadMedida: 'pieza',
        stockActual: 18,
        stockMinimo: 5,
        categoriaId: Value(cats[0].id),
        ubicacion: Value('Pasillo A-2'),
        activo: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductosCompanion.insert(
        nombre: 'Grava fina 1kg',
        codigoBarras: Value('7501001000008'),
        marca: Value(''),
        precioCompra: 8.0,
        precioVenta: 15.0,
        unidadMedida: 'kg',
        stockActual: 500,
        stockMinimo: 100,
        categoriaId: Value(cats[5].id),
        ubicacion: Value('Almacén exterior'),
        activo: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await db.insertProductos(productos);

    if (kDebugMode) {
      final totalProductos = await db.countProductos();
      debugPrint('DatabaseInitializer: BD sembrada con $totalProductos productos');
    }

    await prefs.setBool(_initializedKey, true);
  }
}
