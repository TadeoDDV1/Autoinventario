import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/producto.dart';
import '../models/categoria.dart';
import '../models/paginated_response.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Future<PaginatedResponse<Producto>> getProductos({
    int page = 1,
    int pageSize = 20,
    String? search,
    int? categoriaId,
  }) async {
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
  }

  Future<Producto> getProductoById(int id) async {
    final response = await _dio.get('/productos/$id');
    return Producto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<int> createProducto(Map<String, dynamic> data) async {
    final response = await _dio.post('/productos', data: data);
    return response.data['id'] as int;
  }

  Future<void> updateProducto(int id, Map<String, dynamic> data) async {
    await _dio.put('/productos/$id', data: data);
  }

  Future<void> deleteProducto(int id) async {
    await _dio.delete('/productos/$id');
  }

  Future<List<Categoria>> getCategorias() async {
    final response = await _dio.get('/categorias');
    return (response.data as List)
        .map((e) => Categoria.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> createCategoria(Map<String, dynamic> data) async {
    final response = await _dio.post('/categorias', data: data);
    return response.data['id'] as int;
  }
}
