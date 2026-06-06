import 'package:dio/dio.dart';

/// Excepción de API tipada para que la UI pueda reaccionar
/// de forma específica sin parsear strings de error.
class ApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  bool get isNotFound => statusCode == 404 || code == 'NOT_FOUND';
  bool get isStockInsuficiente =>
      statusCode == 409 || code == 'STOCK_INSUFICIENTE';
  bool get isValidationError =>
      statusCode == 400 || code == 'VALIDATION_ERROR' || code == 'BAD_REQUEST';
  bool get isNetwork => statusCode == null;

  factory ApiException.fromDio(DioException e) {
    final response = e.response;
    if (response != null && response.data is Map) {
      final data = response.data as Map;
      return ApiException(
        code: (data['error'] as String?) ?? 'UNKNOWN',
        message: (data['message'] as String?) ?? e.message ?? 'Error',
        statusCode: response.statusCode,
      );
    }
    return ApiException(
      code: 'NETWORK_ERROR',
      message: e.message ?? 'Sin conexión con el servidor',
      statusCode: null,
    );
  }

  @override
  String toString() => message;
}
