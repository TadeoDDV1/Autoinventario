import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../core/api/dio_client.dart';
import '../core/errors/api_exception.dart';
import '../database/app_database.dart';
import '../models/entrada.dart';

class EntradaService {
  final Dio _dio;

  EntradaService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/entradas', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout) {
        return _guardarOffline(data);
      }
      throw ApiException.fromDio(e);
    } catch (e) {
      return _guardarOffline(data);
    }
  }

  Future<Map<String, dynamic>> _guardarOffline(Map<String, dynamic> data) async {
    final clientId = 'entrada-${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().hashCode.toRadixString(16)}';
    final db = AppDatabase();
    await db.addEntradaPendiente(EntradasPendientesCompanion(
      clientId: Value(clientId),
      createdAt: Value(DateTime.now()),
      entradaData: Value(jsonEncode(data)),
      synced: const Value(false),
    ));
    if (kDebugMode) debugPrint('Entrada guardada offline: $clientId');
    return {'id': null, 'offline': true, 'client_id': clientId, 'mensaje': 'Guardada offline — sincronizará al reconectar'};
  }

  /// Devuelve entradas paginadas con sus detalles cargados.
  Future<PaginatedEntradas> getAll({
    String? proveedor,
    String? q,
    String? desde,
    String? hasta,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (proveedor != null && proveedor.isNotEmpty) {
        params['proveedor'] = proveedor;
      }
      if (q != null && q.isNotEmpty) params['q'] = q;
      if (desde != null) params['desde'] = desde;
      if (hasta != null) params['hasta'] = hasta;

      final response = await _dio.get('/entradas', queryParameters: params);
      return PaginatedEntradas.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        return const PaginatedEntradas(items: [], total: 0, page: 1, pageSize: 20, totalPages: 0);
      }
      throw ApiException.fromDio(e);
    }
  }

  /// Devuelve entradas filtradas con sus detalles cargados.
  Future<PaginatedEntradas> getHistorial(HistorialFiltro filtro) async {
    try {
      final response = await _dio.get(
        '/entradas/historial',
        queryParameters: filtro.toQueryParams(),
      );
      return PaginatedEntradas.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        return const PaginatedEntradas(items: [], total: 0, page: 1, pageSize: 20, totalPages: 0);
      }
      throw ApiException.fromDio(e);
    }
  }

  /// Devuelve una entrada por ID con todos sus detalles.
  Future<EntradaInventario> getById(int id) async {
    try {
      final response = await _dio.get('/entradas/$id');
      return EntradaInventario.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
