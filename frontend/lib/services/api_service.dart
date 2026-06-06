import 'package:dio/dio.dart';

import '../core/api/dio_client.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/api_exception.dart';
import '../models/categoria.dart';
import '../models/paginated_response.dart';
import '../models/producto.dart';
import '../models/venta.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  // -------- Productos --------

  Future<PaginatedResponse<Producto>> getProductos({
    int page = 1,
    int pageSize = ApiConstants.defaultPageSize,
    String? search,
    int? categoriaId,
  }) async {
    return _request(() async {
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (categoriaId != null) {
        queryParameters['categoria'] = categoriaId;
      }
      final response = await _dio.get(
        '/productos',
        queryParameters: queryParameters,
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        Producto.fromJson,
      );
    });
  }

  Future<Producto> getProductoById(int id) async {
    return _request(() async {
      final response = await _dio.get('/productos/$id');
      return Producto.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<int> createProducto(Map<String, dynamic> data) async {
    return _request(() async {
      final response = await _dio.post('/productos', data: data);
      return response.data['id'] as int;
    });
  }

  Future<void> updateProducto(int id, Map<String, dynamic> data) async {
    return _request(() async {
      await _dio.put('/productos/$id', data: data);
    });
  }

  Future<void> deleteProducto(int id) async {
    return _request(() async {
      await _dio.delete('/productos/$id');
    });
  }

  Future<Producto?> buscarPorCodigo(String codigo) async {
    return _request(() async {
      try {
        final response = await _dio.get(
          '/productos/buscar',
          queryParameters: {'codigo': codigo},
        );
        if (response.data == null) return null;
        return Producto.fromJson(response.data as Map<String, dynamic>);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) return null;
        rethrow;
      }
    });
  }

  Future<void> ajustarStock(int id, int cantidad) async {
    return _request(() async {
      await _dio.patch(
        '/productos/$id/stock',
        data: {'cantidad': cantidad},
      );
    });
  }

  // -------- Categorías --------

  Future<List<Categoria>> getCategorias() async {
    return _request(() async {
      final response = await _dio.get('/categorias');
      return (response.data as List)
          .map((e) => Categoria.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<int> createCategoria(Map<String, dynamic> data) async {
    return _request(() async {
      final response = await _dio.post('/categorias', data: data);
      return response.data['id'] as int;
    });
  }

  // -------- Ventas --------

  Future<List<Venta>> getVentas({
    int page = 1,
    int pageSize = ApiConstants.maxPageSize,
  }) async {
    return _request(() async {
      final response = await _dio.get(
        '/ventas',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>;
      return list
          .map((e) => Venta.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Venta> getVentaById(int id) async {
    return _request(() async {
      final response = await _dio.get('/ventas/$id');
      return Venta.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<Map<String, dynamic>> createVenta(Map<String, dynamic> data) async {
    return _request(() async {
      final response = await _dio.post('/ventas', data: data);
      return response.data as Map<String, dynamic>;
    });
  }

  // -------- Helper --------

  Future<T> _request<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
