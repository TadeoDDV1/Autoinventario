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

  Future<List<EntradaInventario>> getAll({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _dio.get('/entradas', queryParameters: {
        'page': page,
        'page_size': pageSize,
      });
      final body = response.data as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>;
      return list
          .map((e) => EntradaInventario.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<EntradaInventario>> getHistorial({
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
      if (desde != null && desde.isNotEmpty) params['desde'] = desde;
      if (hasta != null && hasta.isNotEmpty) params['hasta'] = hasta;

      final response = await _dio.get('/entradas/historial', queryParameters: params);
      final body = response.data as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>;
      return list
          .map((e) => EntradaInventario.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}