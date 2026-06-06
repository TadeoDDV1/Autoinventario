import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/api_config.dart';

/// Cliente HTTP configurado con:
/// - baseURL por plataforma (web, Android, iOS, desktop)
/// - timeouts (10s connect, 15s receive)
/// - reintentos con backoff exponencial en errores transitorios (5xx, timeout, network)
/// - logging solo en debug
class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(_RetryInterceptor(dio: dio, maxRetries: 3));
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: kDebugMode,
          responseBody: kDebugMode,
          request: kDebugMode,
          requestHeader: false,
          responseHeader: false,
          error: true,
        ),
      );
    }
  }
}

class _RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  _RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_shouldRetry(err) || err.requestOptions.extra['_retry'] == true) {
      return handler.next(err);
    }

    final attempt = (err.requestOptions.extra['_attempt'] as int?) ?? 0;
    if (attempt >= maxRetries) {
      return handler.next(err);
    }

    final delay = const Duration(milliseconds: 500) * (1 << attempt);
    await Future.delayed(delay);

    try {
      final response = await dio.fetch(
        err.requestOptions
          ..extra['_attempt'] = attempt + 1
          ..extra['_retry'] = true,
      );
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }
    final status = err.response?.statusCode ?? 0;
    return status >= 500 && status < 600;
  }
}
