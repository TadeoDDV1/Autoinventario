import 'package:dio/dio.dart';

import '../core/api/dio_client.dart';
import '../core/errors/api_exception.dart';
import '../models/sugerencia.dart';

class IaService {
  final Dio _dio;

  IaService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  /// Devuelve hasta [limite] sugerencias basadas en el carrito actual.
  /// Funciona offline-first: si el backend tiene IA deshabilitada o falla,
  /// retorna lista vacía y el caller debe mostrar fallback UI.
  Future<SugerenciasResponse> getSugerencias({
    required List<int> carritoProductoIds,
    int limite = 3,
  }) async {
    try {
      if (carritoProductoIds.isEmpty) {
        return const SugerenciasResponse(
          sugerencias: [],
          fuente: 'vacio',
        );
      }
      final carritoStr = carritoProductoIds.join(',');
      final response = await _dio.get(
        '/ia/sugerencias',
        queryParameters: {'carrito': carritoStr, 'limite': limite},
      );
      return SugerenciasResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      // Si falla la IA, no rompemos el flujo del POS.
      throw ApiException.fromDio(e);
    }
  }

  Future<DashboardResumen> getDashboardResumen() async {
    try {
      final response = await _dio.get('/dashboard/resumen');
      return DashboardResumen.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<VentaHora>> getVentasHoyPorHora() async {
    try {
      final response = await _dio.get('/dashboard/ventas-hoy');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => VentaHora.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<VentaReciente>> getVentasRecientes({int limit = 5}) async {
    try {
      final response = await _dio.get('/dashboard/recientes',
          queryParameters: {'limit': limit});
      final list = response.data as List<dynamic>;
      return list
          .map((e) => VentaReciente.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<PrediccionesResumen> getPrediccionesInventario() async {
    try {
      final response = await _dio.get('/ia/inventario/predicciones');
      return PrediccionesResumen.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
