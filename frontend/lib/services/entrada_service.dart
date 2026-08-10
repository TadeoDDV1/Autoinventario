import 'package:dio/dio.dart';

import '../core/api/dio_client.dart';
import '../core/errors/api_exception.dart';
import '../models/entrada.dart';

class EntradaService {
  final Dio _dio;

  EntradaService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/entradas', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Devuelve entradas paginadas con sus detalles cargados.
  Future<PaginatedEntradas> getAll({
    String? proveedor,
    String? q,
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

      final response = await _dio.get('/entradas', queryParameters: params);
      return PaginatedEntradas.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
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
