import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_provider.dart';
import '../models/sugerencia.dart';
import '../services/ia_service.dart';
import 'venta_provider.dart';

const String _dashboardCacheKey = 'dashboard_cache';
const String _ventasHoraCacheKey = 'ventas_hora_cache';
const String _ventasRecientesCacheKey = 'ventas_recientes_cache';
const String _prediccionesCacheKey = 'predicciones_cache';

final iaServiceProvider = Provider<IaService>((ref) => IaService());

/// Provider de sugerencias del copilot. Se reevalúa cuando cambia el carrito.
/// Tiene debounce interno (300ms) para evitar spam durante el escaneo.
final copilotSugerenciasProvider =
    FutureProvider.autoDispose<SugerenciasResponse>((ref) async {
  final carrito = ref.watch(carritoProvider);
  final ids = carrito.map((item) => item.producto.id).toList();

  final completer = Completer<SugerenciasResponse>();
  final timer = Timer(const Duration(milliseconds: 350), () async {
    try {
      final ia = ref.read(iaServiceProvider);
      final result = await ia.getSugerencias(carritoProductoIds: ids);
      completer.complete(result);
    } catch (e) {
      completer.complete(
        const SugerenciasResponse(sugerencias: [], fuente: 'error'),
      );
    }
  });

  ref.onDispose(() {
    timer.cancel();
    if (!completer.isCompleted) completer.completeError(StateError('cancelled'));
  });

  return completer.future;
});

/// Ventas del día agregadas por hora (24 entradas, 0..23).
/// Calculado desde la BD local (offline-first).
final ventasHoyPorHoraProvider =
    FutureProvider.autoDispose<List<VentaHora>>((ref) async {
  try {
    final db = ref.read(appDatabaseProvider);
    final ventas = await db.getAllVentas(limit: 1000);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final porHora = List<VentaHora>.generate(24, (h) =>
        VentaHora(hora: h, totalVentas: 0, transacciones: 0));

    for (final v in ventas) {
      final vDate = DateTime(v.fecha.year, v.fecha.month, v.fecha.day);
      if (vDate.isAtSameMomentAs(today)) {
        final h = v.fecha.hour;
        if (h >= 0 && h < 24) {
          porHora[h] = VentaHora(
            hora: h,
            totalVentas: porHora[h].totalVentas + v.total,
            transacciones: porHora[h].transacciones + 1,
          );
        }
      }
    }
    return porHora;
  } catch (e) {
    if (kDebugMode) debugPrint('ventasHoyPorHora local error: $e');
    // Fallback: cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_ventasHoraCacheKey);
      if (cached != null) {
        final list = jsonDecode(cached) as List<dynamic>;
        return list.map((e) => VentaHora(
          hora: (e['hora'] as num).toInt(),
          totalVentas: (e['total_ventas'] as num).toDouble(),
          transacciones: (e['transacciones'] as num).toInt(),
        )).toList();
      }
    } catch (_) {}
    return const [];
  }
});

/// Últimas N ventas del día (default 5).
/// Calculado desde la BD local (offline-first).
final ventasRecientesProvider =
    FutureProvider.autoDispose<List<VentaReciente>>((ref) async {
  try {
    final db = ref.read(appDatabaseProvider);
    final ventas = await db.getAllVentas(limit: 5);
    if (ventas.isEmpty) return const [];

    final result = <VentaReciente>[];
    for (final v in ventas) {
      final detalles = await db.getDetallesByVenta(v.id);
      result.add(VentaReciente(
        id: v.id,
        folio: v.folio ?? '',
        total: v.total,
        metodoPago: v.metodoPago,
        fecha: v.fecha,
        numProductos: detalles.length,
      ));
    }
    return result;
  } catch (e) {
    if (kDebugMode) debugPrint('ventasRecientes local error: $e');
    // Fallback: cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_ventasRecientesCacheKey);
      if (cached != null) {
        final list = jsonDecode(cached) as List<dynamic>;
        return list.map((e) => VentaReciente(
          id: (e['id'] as num?)?.toInt() ?? 0,
          folio: e['folio'] as String? ?? '',
          total: (e['total'] as num?)?.toDouble() ?? 0,
          metodoPago: e['metodo_pago'] as String? ?? '',
          fecha: e['fecha'] != null ? DateTime.parse(e['fecha'] as String) : DateTime.now(),
          numProductos: (e['num_productos'] as num?)?.toInt() ?? 0,
        )).toList();
      }
    } catch (_) {}
    return const [];
  }
});

/// Dashboard ejecutivo calculado desde la BD local (offline-first).
/// Todas las métricas se derivan de la tabla VentasLocal + Productos.
final dashboardProvider = FutureProvider.autoDispose<DashboardResumen>((ref) async {
  try {
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Obtener todas las ventas (suficiente para 7 días)
    final ventas = await db.getAllVentas(limit: 5000);

    // Filtrar ventas de hoy
    final ventasHoy = ventas.where((v) {
      final d = DateTime(v.fecha.year, v.fecha.month, v.fecha.day);
      return d.isAtSameMomentAs(today);
    }).toList();

    final ventasAyer = ventas.where((v) {
      final d = DateTime(v.fecha.year, v.fecha.month, v.fecha.day);
      return d.isAtSameMomentAs(yesterday);
    }).toList();

    final totalHoy = ventasHoy.fold<double>(0, (s, v) => s + v.total);
    final totalAyer = ventasAyer.fold<double>(0, (s, v) => s + v.total);
    final transaccionesHoy = ventasHoy.length;
    final ticketPromedio = transaccionesHoy > 0 ? totalHoy / transaccionesHoy : 0.0;
    final variacionPct = totalAyer > 0
        ? ((totalHoy - totalAyer) / totalAyer * 100)
        : 0.0;

    // Ventas por método de pago
    final ventasEfectivo = ventasHoy
        .where((v) => v.metodoPago == 'efectivo')
        .fold<double>(0, (s, v) => s + v.total);
    final ventasTarjeta = ventasHoy
        .where((v) => v.metodoPago == 'tarjeta')
        .fold<double>(0, (s, v) => s + v.total);

    // Top productos de hoy
    final topProductosMap = <int, ({int cantidad, double total, String nombre})>{};
    for (final v in ventasHoy) {
      final detalles = await db.getDetallesByVenta(v.id);
      for (final d in detalles) {
        final existing = topProductosMap[d.productoId];
        if (existing != null) {
          topProductosMap[d.productoId] = (
            cantidad: existing.cantidad + d.cantidad,
            total: existing.total + d.subtotal,
            nombre: d.nombreProducto,
          );
        } else {
          topProductosMap[d.productoId] = (
            cantidad: d.cantidad,
            total: d.subtotal,
            nombre: d.nombreProducto,
          );
        }
      }
    }
    final topProductos = topProductosMap.entries
        .map((e) => TopProducto(
              productoId: e.key,
              nombre: e.value.nombre,
              cantidad: e.value.cantidad,
              totalVenta: e.value.total,
            ))
        .toList()
      ..sort((a, b) => b.cantidad.compareTo(a.cantidad));
    final top5 = topProductos.take(5).toList();

    // Stock bajo desde Productos
    final allProductos = await db.getAllProductos();
    final stockBajo = allProductos
        .where((p) => p.stockActual < p.stockMinimo)
        .map((p) => StockBajoItem(
              productoId: p.id,
              nombre: p.nombre,
              stockActual: p.stockActual,
              stockMin: p.stockMinimo,
            ))
        .toList();

    // Ventas últimos 7 días
    final ventasUltimos7Dias = <VentasDia>[];
    for (var i = 6; i >= 0; i--) {
      final dia = today.subtract(Duration(days: i));
      final ventasDia = ventas.where((v) {
        final d = DateTime(v.fecha.year, v.fecha.month, v.fecha.day);
        return d.isAtSameMomentAs(dia);
      }).toList();
      final totalDia = ventasDia.fold<double>(0, (s, v) => s + v.total);
      ventasUltimos7Dias.add(VentasDia(
        fecha: '${dia.day.toString().padLeft(2, '0')}/${dia.month.toString().padLeft(2, '0')}',
        totalVentas: totalDia,
        transacciones: ventasDia.length,
      ));
    }

    return DashboardResumen(
      fecha: '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}',
      ventasHoy: totalHoy,
      transaccionesHoy: transaccionesHoy,
      ticketPromedio: ticketPromedio,
      ventasAyer: totalAyer,
      variacionPct: variacionPct,
      ventasEfectivo: ventasEfectivo,
      ventasTarjeta: ventasTarjeta,
      topProductos: top5,
      stockBajo: stockBajo,
      ventasUltimos7Dias: ventasUltimos7Dias,
    );
  } catch (e) {
    if (kDebugMode) debugPrint('dashboardProvider local error: $e');
    // Fallback: cache del servidor
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_dashboardCacheKey);
      if (cached != null) {
        final data = jsonDecode(cached) as Map<String, dynamic>;
        return DashboardResumen.fromJson(data);
      }
    } catch (_) {}
    return const DashboardResumen(
      fecha: '',
      ventasHoy: 0,
      transaccionesHoy: 0,
      ticketPromedio: 0,
      ventasAyer: 0,
      variacionPct: 0,
      ventasEfectivo: 0,
      ventasTarjeta: 0,
      topProductos: [],
      stockBajo: [],
      ventasUltimos7Dias: [],
    );
  }
});

/// Predicciones de inventario. Offline-first: intenta API, cachea, fallback a cache.
final prediccionesInventarioProvider =
    FutureProvider.autoDispose<PrediccionesResumen>((ref) async {
  final ia = ref.read(iaServiceProvider);
  try {
    final result = await ia.getPrediccionesInventario();
    // Guardar en cache
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prediccionesCacheKey, jsonEncode({
        'fecha_analisis': result.fechaAnalisis,
        'total_productos': result.totalProductos,
        'productos_criticos': result.productosCriticos,
        'productos_urgentes': result.productosUrgentes,
        'productos_sin_ventas': result.productosSinVentas,
        'productos_dormidos': result.productosDormidos,
        'valor_inventario': result.valorInventario,
        'valor_critico': result.valorCritico,
      }));
    } catch (_) {}
    return result;
  } catch (_) {
    // Fallback: cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_prediccionesCacheKey);
      if (cached != null) {
        final data = jsonDecode(cached) as Map<String, dynamic>;
        return PrediccionesResumen.fromJson(data);
      }
    } catch (_) {}
    return const PrediccionesResumen(
      fechaAnalisis: '',
      totalProductos: 0,
      productosCriticos: 0,
      productosUrgentes: 0,
      productosSinVentas: 0,
      productosDormidos: 0,
      valorInventario: 0,
      valorCritico: 0,
      topCriticos: [],
      recomendaciones: [],
    );
  }
});
