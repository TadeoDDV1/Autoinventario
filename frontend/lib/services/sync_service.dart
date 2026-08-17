import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../core/api/dio_client.dart';
import '../core/utils/test_environment.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../providers/configuracion_provider.dart';
import '../providers/entrada_provider.dart';
import '../providers/producto_provider.dart';
import 'cache_service.dart';

/// Estado de conectividad de la app.
enum ConectividadEstado { online, offline, sincronizando }

class ConectividadNotifier extends Notifier<ConectividadEstado> {
  Timer? _pingTimer;
  int _consecutiveFailures = 0;

  @override
  ConectividadEstado build() {
    // En tests el Timer.periodic agenda frames sin fin y nunca deja
    // "settle" a pumpAndSettle. En producción se comporta igual que antes.
    if (!isRunningTests) {
      _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _checkConnectivity());
    }
    Future.microtask(_checkConnectivity);
    ref.onDispose(() => _pingTimer?.cancel());
    return ConectividadEstado.online;
  }

  Future<void> _checkConnectivity() async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: apiBaseUrlSync,
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      ));
      final resp = await dio.get('/health').timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        _consecutiveFailures = 0;
        if (state != ConectividadEstado.sincronizando) {
          state = ConectividadEstado.online;
        }
        await _refreshCatalog();
        if (_wasOffline) {
          _wasOffline = false;
          await sincronizarCompleto();
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

  Future<void> _refreshCatalog() async {
    final api = ref.read(apiServiceProvider);
    try {
      final productosResp = await api.getProductos(pageSize: 1000);
      final productos = productosResp.data;
      final categorias = await api.getCategorias();
      final db = ref.read(appDatabaseProvider);

      await db.clearProductos();
      await db.clearCategorias();
      await db.insertProductos(productos.map((p) => ProductosCompanion(
            id: Value(p.id),
            codigoBarras: Value(p.codigoBarras),
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
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          )).toList());
      await db.insertCategorias(categorias.map((c) => CategoriasCompanion(
            id: Value(c.id),
            nombre: Value(c.nombre),
            descripcion: Value(c.descripcion),
            activo: const Value(true),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          )).toList());
    } catch (_) {}
  }

  Future<void> forzarCheck() => _checkConnectivity();

  /// Llamado por el usuario para forzar sincronización.
  /// Ejecuta sincronización bidireccional completa.
  Future<Map<String, int>> sincronizarAhora() => sincronizarCompleto();

  /// Sincronización manual completa:
  /// 1. Push: sube ventas/entradas/productos pendientes.
  /// 2. Pull: descarga productos, categorías, ventas y entradas del servidor.
  Future<Map<String, int>> sincronizarCompleto() async {
    state = ConectividadEstado.sincronizando;
    final result = <String, int>{
      'ventas_subidas': 0,
      'entradas_subidas': 0,
      'productos_subidos': 0,
      'ventas_descargadas': 0,
      'entradas_descargadas': 0,
      'productos_descargados': 0,
    };
    try {
      result['productos_subidos'] = await _sincronizarProductos();
      result['ventas_subidas'] = await _sincronizarVentas();
      result['entradas_subidas'] = await _sincronizarEntradas();

      result['productos_descargados'] = await _pullProductos();
      result['ventas_descargadas'] = await _pullVentas();
      result['entradas_descargadas'] = await _pullEntradas();

      final db = ref.read(appDatabaseProvider);
      await db.setSyncMeta('last_full_sync', DateTime.now().toIso8601String());

      state = ConectividadEstado.online;
    } catch (e) {
      if (kDebugMode) debugPrint('Sync completo error: $e');
      state = ConectividadEstado.offline;
      rethrow;
    }
    return result;
  }

  Future<int> _sincronizarProductos() async {
    final db = ref.read(appDatabaseProvider);
    final cola = await db.getProductosPendientes();
    if (cola.isEmpty) return 0;

    try {
      final dio = DioClient().dio;
      int synced = 0;
      for (final pendiente in cola) {
        try {
          final data = jsonDecode(pendiente.productoData) as Map<String, dynamic>;
          final resp = await dio.post('/productos', data: data);
          if (resp.statusCode == 200 || resp.statusCode == 201) {
            final nuevoId = resp.data['id'] as int?;
            if (nuevoId != null) {
              final allLocal = await db.getAllProductos();
              for (final local in allLocal) {
                if (local.id < 0 && local.nombre == data['nombre']) {
                  await db.reemplazarProductoProvisional(local.id, nuevoId);
                  break;
                }
              }
            }
            synced++;
          }
        } catch (_) {}
      }
      if (synced > 0) {
        await db.markProductosSynced(cola.map((e) => e.clientId).toList());
        if (kDebugMode) debugPrint('Sync productos: $synced/${cola.length}');
      }
      return synced;
    } catch (e) {
      if (kDebugMode) debugPrint('Sync productos error: $e');
    }
    return 0;
  }

  Future<int> _sincronizarVentas() async {
    final cache = ref.read(cacheServiceProvider);
    final cola = await cache.getColaVentas();
    if (cola.isEmpty) return 0;

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
        final resultados = (data['resultados'] as List<dynamic>?) ?? const [];
        final idsExito = <String>[];
        final db = ref.read(appDatabaseProvider);

        for (final r in resultados) {
          final m = r as Map<String, dynamic>;
          if (m['ok'] == true) {
            final clientId = m['client_id'] as String;
            idsExito.add(clientId);

            // Mover la venta de VentasPendientes a VentasLocal con el ID real
            final ventaPendiente = cola.firstWhere((v) => v.clientId == clientId);
            final serverId = m['id'] as int?;
            final serverFolio = m['folio'] as String?;

            if (serverId != null) {
              final ventaData = ventaPendiente.ventaData;
              final detallesJson = (ventaData['detalles'] as List?) ?? const [];

              final detallesCompanion = <VentasDetalleLocalCompanion>[];
              for (final d in detallesJson) {
                final dd = d as Map<String, dynamic>;
                detallesCompanion.add(VentasDetalleLocalCompanion(
                  ventaId: Value(serverId),
                  productoId: Value((dd['producto_id'] as num?)?.toInt() ?? 0),
                  nombreProducto: Value(''),
                  precioUnitario: Value((dd['precio_unitario'] as num?)?.toDouble() ?? 0),
                  cantidad: Value((dd['cantidad'] as num?)?.toInt() ?? 0),
                  subtotal: Value((dd['subtotal'] as num?)?.toDouble() ?? 0),
                ));
              }

              await db.upsertVentaConDetalle(
                VentasLocalCompanion(
                  id: Value(serverId),
                  folio: Value(serverFolio ?? 'VENT-$serverId'),
                  clientId: Value(clientId),
                  fecha: Value(ventaPendiente.createdAt),
                  subtotal: Value((ventaData['subtotal'] as num?)?.toDouble() ?? 0),
                  iva: Value((ventaData['iva'] as num?)?.toDouble() ?? 0),
                  total: Value(ventaPendiente.total),
                  metodoPago: Value((ventaData['metodo_pago'] as String?) ?? 'efectivo'),
                  montoRecibido: Value((ventaData['monto_recibido'] as num?)?.toDouble()),
                  cambio: Value((ventaData['cambio'] as num?)?.toDouble()),
                  synced: const Value(true),
                ),
                detallesCompanion,
              );

              // Si la venta tenía un ID temporal negativo en VentasLocal, actualizarlo
              final ventasLocales = await db.getAllVentas(limit: 5000);
              for (final vl in ventasLocales) {
                if (vl.clientId == clientId && vl.id < 0) {
                  // Reemplazar el ID temporal con el real del servidor
                  await db.reemplazarIdVentaLocal(vl.id, serverId);
                  break;
                }
              }
            }
          }
        }

        await cache.marcarSincronizadas(idsExito);
        ref.invalidate(colaVentasCountProvider);
        if (kDebugMode) debugPrint('Sync ventas: ${idsExito.length}/${cola.length}');
        return idsExito.length;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Sync ventas error: $e');
    }
    return 0;
  }

  Future<int> _sincronizarEntradas() async {
    final db = ref.read(appDatabaseProvider);
    final cola = await db.getEntradasPendientes();
    if (cola.isEmpty) return 0;

    try {
      final dio = DioClient().dio;
      int synced = 0;
      for (final entrada in cola) {
        try {
          final data = jsonDecode(entrada.entradaData) as Map<String, dynamic>;
          final resp = await dio.post('/entradas', data: data);
          if (resp.statusCode == 200 || resp.statusCode == 201) {
            synced++;
          }
        } catch (_) {}
      }
      if (synced > 0) {
        await db.markEntradasSynced(cola.map((e) => e.clientId).toList());
        if (kDebugMode) debugPrint('Sync entradas: $synced/${cola.length}');
      }
      return synced;
    } catch (e) {
      if (kDebugMode) debugPrint('Sync entradas error: $e');
    }
    return 0;
  }

  Future<int> _pullProductos() async {
    try {
      final api = ref.read(apiServiceProvider);
      final resp = await api.getProductos(pageSize: 1000);
      final db = ref.read(appDatabaseProvider);
      await db.clearProductos();
      await db.insertProductos(resp.data.map((p) => ProductosCompanion(
            id: Value(p.id),
            codigoBarras: Value(p.codigoBarras),
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
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          )).toList());
      final categorias = await api.getCategorias();
      await db.clearCategorias();
      await db.insertCategorias(categorias.map((c) => CategoriasCompanion(
            id: Value(c.id),
            nombre: Value(c.nombre),
            descripcion: Value(c.descripcion),
            activo: const Value(true),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          )).toList());
      if (kDebugMode) debugPrint('Pull productos: ${resp.data.length}');
      return resp.data.length;
    } catch (e) {
      if (kDebugMode) debugPrint('Pull productos error: $e');
      return 0;
    }
  }

  Future<int> _pullVentas() async {
    try {
      final config = await ref.read(configuracionProvider.future);
      final api = ref.read(apiServiceProvider);
      final db = ref.read(appDatabaseProvider);

      DateTime? desde;
      if (config.diasHistorialSync > 0) {
        desde = DateTime.now().subtract(Duration(days: config.diasHistorialSync));
      }

      final desdeStr = desde?.toIso8601String().substring(0, 10);
      final ventas = await api.getVentas(pageSize: 1000, desde: desdeStr);

      int count = 0;
      for (final v in ventas) {
        final detallesJson = (v.toJson()['detalles'] as List?) ?? const [];
        final detalles = <VentasDetalleLocalCompanion>[];
        for (final d in detallesJson) {
          final m = d as Map<String, dynamic>;
          detalles.add(VentasDetalleLocalCompanion(
            ventaId: Value(v.id ?? 0),
            productoId: Value(m['producto_id'] as int? ?? 0),
            nombreProducto: Value(m['nombre_producto'] as String? ?? ''),
            precioUnitario: Value((m['precio_unitario'] as num?)?.toDouble() ?? 0),
            cantidad: Value(m['cantidad'] as int? ?? 0),
            subtotal: Value((m['subtotal'] as num?)?.toDouble() ?? 0),
          ));
        }
        await db.upsertVentaConDetalle(
          VentasLocalCompanion(
            id: Value(v.id ?? 0),
            folio: Value(v.folio),
            fecha: Value(v.fecha ?? DateTime.now()),
            subtotal: Value(v.subtotal),
            iva: Value(v.iva),
            total: Value(v.total),
            metodoPago: Value(v.metodoPago),
            montoRecibido: Value(v.montoRecibido),
            cambio: Value(v.cambio),
            synced: const Value(true),
          ),
          detalles,
        );
        count++;
      }
      if (kDebugMode) debugPrint('Pull ventas: $count');
      return count;
    } catch (e) {
      if (kDebugMode) debugPrint('Pull ventas error: $e');
      return 0;
    }
  }

  Future<int> _pullEntradas() async {
    try {
      final config = await ref.read(configuracionProvider.future);
      final entradaService = ref.read(entradaServiceProvider);
      final db = ref.read(appDatabaseProvider);

      DateTime? desde;
      if (config.diasHistorialSync > 0) {
        desde = DateTime.now().subtract(Duration(days: config.diasHistorialSync));
      }
      final desdeStr = desde?.toIso8601String().substring(0, 10);

      final resp = await entradaService.getAll(pageSize: 1000, desde: desdeStr);
      int count = 0;
      for (final e in resp.items) {
        final detalles = <EntradasDetalleLocalCompanion>[];
        for (final d in e.detalles) {
          detalles.add(EntradasDetalleLocalCompanion(
            entradaId: Value(e.id),
            productoId: Value(d.productoId),
            nombreProducto: Value(d.nombreProducto),
            cantidad: Value(d.cantidad),
            costoUnitario: Value(d.costoUnitario),
          ));
        }
        await db.upsertEntradaConDetalle(
          EntradasLocalCompanion(
            id: Value(e.id),
            folio: Value(e.folio),
            proveedor: Value(e.proveedor),
            observaciones: Value(e.observaciones),
            total: Value(e.total),
            fecha: Value(e.fecha),
            synced: const Value(true),
          ),
          detalles,
        );
        count++;
      }
      if (kDebugMode) debugPrint('Pull entradas: $count');
      return count;
    } catch (e) {
      if (kDebugMode) debugPrint('Pull entradas error: $e');
      return 0;
    }
  }

  Future<void> encolarVenta(VentaPendiente venta) async {
    final cache = ref.read(cacheServiceProvider);
    await cache.encolarVenta(venta);
    ref.invalidate(colaVentasCountProvider);
  }

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

final conectividadProvider =
    NotifierProvider<ConectividadNotifier, ConectividadEstado>(
  ConectividadNotifier.new,
);

final totalPendientesProvider = FutureProvider.autoDispose<int>((ref) async {
  final cache = ref.read(cacheServiceProvider);
  final ventasCount = await cache.countCola();
  final db = ref.read(appDatabaseProvider);
  final entradas = await db.getEntradasPendientes();
  final productos = await db.getProductosPendientes();
  return ventasCount + entradas.length + productos.length;
});
