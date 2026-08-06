import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../core/api/dio_client.dart';
import '../providers/producto_provider.dart';
import 'cache_service.dart';

/// Estado de conectividad de la app.
enum ConectividadEstado { online, offline, sincronizando }

class ConectividadNotifier extends Notifier<ConectividadEstado> {
  Timer? _pingTimer;
  int _consecutiveFailures = 0;

  @override
  ConectividadEstado build() {
    // Ping al backend cada 30s
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _checkConnectivity());
    // Primer check inmediato
    Future.microtask(_checkConnectivity);
    ref.onDispose(() => _pingTimer?.cancel());
    return ConectividadEstado.online; // optimista al inicio
  }

  Future<void> _checkConnectivity() async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      ));
      final resp = await dio.get('/health').timeout(const Duration(seconds: 4));
if (resp.statusCode == 200) {
          _consecutiveFailures = 0;
          if (state != ConectividadEstado.sincronizando) {
            state = ConectividadEstado.online;
          }
          // Refresh local catalog from server
          await _refreshCatalog();
          // Si acabamos de reconectar, intentar sincronizar
          if (_wasOffline) {
            _wasOffline = false;
            await _sincronizarCola();
          }
        }
        // Si acabamos de reconectar, intentar sincronizar
        if (_wasOffline) {
          _wasOffline = false;
          await _sincronizarCola();
        }
      } else {
        _incrementarFallo();
      }
    } catch (_) {
      _incrementarFallo();
    }
  }

  bool _wasOffline = false;

  void _incrementarFallo() {
    _consecutiveFailures++;
    if (_consecutiveFailures >= 1) {
      _wasOffline = true;
      state = ConectividadEstado.offline;
    }
  }

  /// Fuerza un check inmediato (útil después de operaciones).
  Future<void> forzarCheck() => _checkConnectivity();

  /// Sincroniza la cola de ventas pendientes con el backend.
  /// Devuelve la cantidad sincronizada.
  Future<int> _sincronizarCola() async {
    final cache = ref.read(cacheServiceProvider);
    final cola = await cache.getColaVentas();
    if (cola.isEmpty) return 0;

    state = ConectividadEstado.sincronizando;
    try {
      final dio = DioClient().dio;
      final body = {
        'ventas': cola
            .map((v) => {
                  'client_id': v.clientId,
                  'created_at': v.createdAt.toIso8601String(),
                  'venta': v.ventaData,
                })
            .toList(),
      };
      final resp = await dio.post('/sync/ventas', data: body);
      if (resp.statusCode == 200) {
        final data = resp.data as Map<String, dynamic>;
        final resultados =
            (data['resultados'] as List<dynamic>?) ?? const [];
        final idsExito = <String>[];
        for (final r in resultados) {
          final m = r as Map<String, dynamic>;
          if (m['ok'] == true) {
            idsExito.add(m['client_id'] as String);
          }
        }
        await cache.marcarSincronizadas(idsExito);
        ref.invalidate(colaVentasCountProvider);
        if (kDebugMode) debugPrint('Sync: ${idsExito.length}/${cola.length} ventas sincronizadas');
        return idsExito.length;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Sync error: $e');
    } finally {
      state = ConectividadEstado.online;
    }
    return 0;
  }

  /// Llamado por el usuario para forzar sincronización.
  Future<int> sincronizarAhora() => _sincronizarCola();

  /// Llamado cuando se quiere agregar una venta a la cola.
  Future<void> encolarVenta(VentaPendiente venta) async {
    final cache = ref.read(cacheServiceProvider);
    await cache.encolarVenta(venta);
    ref.invalidate(colaVentasCountProvider);
  }

  /// Llamado desde POS al confirmar: intenta POST directo, si falla encola.
  /// Devuelve (éxito, idVenta, folio, mensaje).
  Future<({bool ok, int? id, String? folio, String? mensaje, bool encolado})>
      intentarVenta(Map<String, dynamic> ventaData) async {
    final clientId = ventaData['_client_id'] as String?;
    final cache = ref.read(cacheServiceProvider);
    final cola = await cache.getColaVentas();

    if (clientId == null) {
      return (
        ok: false,
        id: null,
        folio: null,
        mensaje: 'Falta client_id',
        encolado: false
      );
    }

    // Verificar si ya está en la cola (idempotencia)
    if (cola.any((v) => v.clientId == clientId)) {
      return (
        ok: true,
        id: null,
        folio: null,
        mensaje: 'Venta ya en cola (sincronizará cuando vuelva la red)',
        encolado: true
      );
    }

    try {
      final dio = DioClient().dio;
      final resp = await dio
          .post('/ventas', data: ventaData)
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 201) {
        return (
          ok: true,
          id: resp.data['id'] as int?,
          folio: resp.data['folio'] as String?,
          mensaje: 'Venta registrada',
          encolado: false
        );
      } else {
        return (
          ok: false,
          id: null,
          folio: null,
          mensaje: 'Error del servidor (${resp.statusCode})',
          encolado: false
        );
      }
    } on DioException catch (e) {
      // Error de red: encolar
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout) {
        final ventaPendiente = VentaPendiente(
          clientId: clientId,
          createdAt: DateTime.now(),
          ventaData: ventaData,
          total: (ventaData['total'] as num?)?.toDouble() ?? 0,
        );
        await encolarVenta(ventaPendiente);
        state = ConectividadEstado.offline;
        _wasOffline = true;
        return (
          ok: true,
          id: null,
          folio: null,
          mensaje: 'Sin conexión — venta guardada localmente',
          encolado: true
        );
      }
      return (
        ok: false,
        id: null,
        folio: null,
        mensaje: 'Error: ${e.message}',
        encolado: false
      );
    } catch (e) {
      return (
        ok: false,
        id: null,
        folio: null,
        mensaje: 'Error inesperado: $e',
        encolado: false
      );
    }
  }
}

Future<void> _refreshCatalog() async {
  final api = ref.read(apiServiceProvider);
  try {
    // Fetch all products (big page size) and categories
    final productosResp = await api.getProductos(pageSize: 1000);
    final productos = productosResp.data;
    final categorias = await api.getCategorias();

    final db = ref.read(appDatabaseProvider);
    await db.clearProductos();
    await db.clearCategorias();

    // Insert products
    await db.insertProductos(productos.map((p) => ProductosCompanion(
      id: Value(p.id),
      codigoBarras: Value(p.codigoBarras),
      sku: Value(p.sku),
      nombre: Value(p.nombre),
      marca: Value(p.marca),
      descripcion: Value(p.descripcion),
      uso: Value(p.uso),
      precioCompra: Value(p.precioCompra),
      precioVenta: Value(p.precioVenta),
      precioMayoreo: Value(p.precioMayoreo),
      unidadMedida: Value(p.unidadMedida.value),
      stockActual: Value(p.stockActual),
      stockMinimo: Value(p.stockMinimo),
      categoriaId: Value(p.categoriaId),
      ubicacion: Value(p.ubicacion),
      activo: Value(p.activo),
      createdAt: Value(p.createdAt),
      updatedAt: Value(p.updatedAt),
      categoriaNombre: Value(p.categoriaNombre),
    )).toList());

    // Insert categories
    await db.insertCategorias(categorias.map((c) => CategoriasCompanion(
      id: Value(c.id),
      nombre: Value(c.nombre),
      descripcion: Value(c.descripcion),
      activo: const Value(true),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    )).toList());
  } catch (_) {
    // ignore errors, will retry on next ping
  }
}

final conectividadProvider =
    NotifierProvider<ConectividadNotifier, ConectividadEstado>(
  ConectividadNotifier.new,
);
