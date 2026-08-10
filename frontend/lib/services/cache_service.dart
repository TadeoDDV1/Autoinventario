import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/app_database.dart' hide Producto, Categoria;
import '../database/database_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/producto.dart';

/// CacheService maneja dos cosas:
/// 1. Cache de productos (para que la app abra rápido y funcione offline).
/// 2. Cola de ventas pendientes (cuando no hay red, se encolan localmente
///    y se sincronizan al reconectar).
class CacheService {
  static const _productosKey = 'cache_productos';
  static const _productosTimeKey = 'cache_productos_time';
  static const _colaVentasKey = 'cola_ventas_pendientes';
  static const _lastSyncKey = 'last_sync_time';

  // --- PRODUCTOS ---

  /// Guarda la lista de productos en cache. Limita a 500 para no
  /// explotar shared_preferences.
  Future<void> cacheProductos(List<Producto> productos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = productos.take(500).map((p) => p.toJson()).toList();
      await prefs.setString(_productosKey, jsonEncode(data));
      await prefs.setInt(_productosTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      if (kDebugMode) debugPrint('CacheService.cacheProductos error: $e');
    }
  }

  /// Devuelve la lista cacheada de productos, o null si no hay cache.
  Future<List<Producto>?> getProductos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_productosKey);
      if (raw == null) return null;
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Producto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('CacheService.getProductos error: $e');
      return null;
    }
  }

  Future<DateTime?> getProductosTime() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_productosTimeKey);
    return ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : null;
  }

  // --- COLA DE VENTAS OFFLINE ---

  /// Encola una venta pendiente. La venta lleva un clientId generado en
  /// el cliente para que el backend pueda reconciliar.
  Future<void> encolarVenta(VentaPendiente venta) async {
    // Guardamos la venta pendiente en la tabla SQLite
    final db = AppDatabase();
    await db.addVentaPendiente(VentasPendientesCompanion(
      clientId: Value(venta.clientId),
      createdAt: Value(venta.createdAt),
      ventaData: Value(jsonEncode(venta.ventaData)),
      total: Value(venta.total),
      synced: const Value(false),
    ));
  }

  Future<List<VentaPendiente>> getColaVentas() async {
    final db = AppDatabase();
    final rows = await db.getVentasPendientes();
    return rows
        .map((row) => VentaPendiente(
              clientId: row.clientId,
              createdAt: row.createdAt,
              ventaData: jsonDecode(row.ventaData) as Map<String, dynamic>,
              total: row.total,
            ))
        .toList();
  }

  /// Marca como sincronizadas (elimina de la cola) las ventas cuyos
  /// clientIds estén en la lista.
  Future<void> marcarSincronizadas(List<String> clientIds) async {
    if (clientIds.isEmpty) return;
    // Marca en la DB como sincronizada
    final db = AppDatabase();
    await db.markVentasSynced(clientIds);
    // Actualiza la marca de tiempo de última sincronización
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<DateTime?> getLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_lastSyncKey);
    return ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : null;
  }

  Future<int> countCola() async {
    final cola = await getColaVentas();
    return cola.length;
  }
}

/// VentaPendiente es una venta generada offline, lista para sincronizar.
class VentaPendiente {
  final String clientId;
  final DateTime createdAt;
  final Map<String, dynamic> ventaData; // payload que se enviará al backend
  final double total;

  const VentaPendiente({
    required this.clientId,
    required this.createdAt,
    required this.ventaData,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'client_id': clientId,
        'created_at': createdAt.toIso8601String(),
        'venta_data': ventaData,
        'total': total,
      };

  factory VentaPendiente.fromJson(Map<String, dynamic> json) {
    return VentaPendiente(
      clientId: json['client_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      ventaData: json['venta_data'] as Map<String, dynamic>,
      total: (json['total'] as num).toDouble(),
    );
  }
}

final cacheServiceProvider = Provider<CacheService>((ref) => CacheService());

/// Provider reactivo para el conteo de ventas pendientes en cola.
final colaVentasCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final cache = ref.read(cacheServiceProvider);
  return cache.countCola();
});
