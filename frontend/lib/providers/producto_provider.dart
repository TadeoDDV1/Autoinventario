import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/producto.dart';
import '../models/categoria.dart';
import '../models/paginated_response.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final productoSearchProvider = NotifierProvider<ProductoSearchNotifier, String>(
  ProductoSearchNotifier.new,
);
final productoCategoriaFilterProvider =
    NotifierProvider<ProductoCategoriaFilterNotifier, int?>(
      ProductoCategoriaFilterNotifier.new,
    );
final productoPageProvider = NotifierProvider<ProductoPageNotifier, int>(
  ProductoPageNotifier.new,
);

class ProductoSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) {
    state = value;
  }
}

class ProductoCategoriaFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void update(int? value) {
    state = value;
  }
}

class ProductoPageNotifier extends Notifier<int> {
  @override
  int build() => 1;

  void update(int value) {
    state = value;
  }
}

final productosProvider =
    AsyncNotifierProvider<ProductosNotifier, PaginatedResponse<Producto>>(
      ProductosNotifier.new,
    );

class ProductosNotifier extends AsyncNotifier<PaginatedResponse<Producto>> {
  @override
  Future<PaginatedResponse<Producto>> build() async {
    final api = ref.watch(apiServiceProvider);
    final search = ref.watch(productoSearchProvider);
    final categoriaId = ref.watch(productoCategoriaFilterProvider);
    final page = ref.watch(productoPageProvider);

    return api.getProductos(
      page: page,
      search: search.isEmpty ? null : search,
      categoriaId: categoriaId,
    );
  }

  /// Crea un producto vía POST /productos y devuelve el `Producto`
  /// completo (refetch vía GET /productos/:id para tener `categoriaNombre`
  /// y demás campos que el POST no incluye en la respuesta).
  ///
  /// Devuelve `Future<Producto>` (no `void`) para que callers como
  /// `AltaRapidaSheet` (B2) puedan hacer `Navigator.pop(context, producto)`
  /// con la entidad completa sin un round-trip extra al backend.
  ///
  /// El refetch es responsabilidad de este método — fuera de aquí nadie
  /// debería llamar a `api.createProducto` + `api.getProductoById` por
  /// separado.
  Future<Producto> createProducto(Map<String, dynamic> data) async {
    final api = ref.read(apiServiceProvider);
    final id = await api.createProducto(data);
    final creado = await api.getProductoById(id);
    ref.invalidateSelf();
    return creado;
  }

  Future<void> updateProducto(int id, Map<String, dynamic> data) async {
    final api = ref.read(apiServiceProvider);
    await api.updateProducto(id, data);
    ref.invalidateSelf();
  }

  Future<void> deleteProducto(int id) async {
    final api = ref.read(apiServiceProvider);
    await api.deleteProducto(id);
    ref.invalidateSelf();
  }

  void refresh() {
    ref.invalidateSelf();
  }
}

final categoriasProvider =
    AsyncNotifierProvider<CategoriasNotifier, List<Categoria>>(
      CategoriasNotifier.new,
    );

class CategoriasNotifier extends AsyncNotifier<List<Categoria>> {
  @override
  Future<List<Categoria>> build() async {
    final api = ref.watch(apiServiceProvider);
    return api.getCategorias();
  }
}

/// Construye el payload `Map<String, dynamic>` para crear un producto en modo
/// rápido.
///
/// Usado por:
/// - `ProductoFormScreen` con `ProductoFormMode.rapido` (alta inline desde Caja).
/// - `AltaRapidaSheet` (B2, alta desde la grilla de inventario).
///
/// Defaults del modo rápido:
/// - `stock_actual = 1` (la unidad que el operador está por vender).
/// - `stock_minimo = 1` (umbral de reorden, igual al stock actual).
/// - `precio_compra = 0` (desconocido al alta rápida; se completa luego).
///
/// El `codigo_barras` se normaliza con `.trim()` para evitar que valores como
/// `' 1234 '` lleguen al backend con espacios y rompan el índice único.
Map<String, dynamic> buildRapidoCreatePayload({
  required String nombre,
  required String codigoBarras,
  required double precioVenta,
}) {
  return {
    'nombre': nombre,
    'codigo_barras': codigoBarras.trim(),
    'precio_venta': precioVenta,
    'precio_compra': 0,
    'stock_actual': 1,
    'stock_minimo': 1,
  };
}
