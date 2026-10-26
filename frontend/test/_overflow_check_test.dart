import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ferreteria_app/database/app_database.dart'
    hide Producto, Categoria;
import 'package:ferreteria_app/database/database_provider.dart';
import 'package:ferreteria_app/models/categoria.dart';
import 'package:ferreteria_app/models/paginated_response.dart';
import 'package:ferreteria_app/models/producto.dart';
import 'package:ferreteria_app/models/sugerencia.dart';
import 'package:ferreteria_app/providers/ia_provider.dart';
import 'package:ferreteria_app/providers/producto_provider.dart';
import 'package:ferreteria_app/services/api_service.dart';
import 'package:ferreteria_app/screens/caja/caja_screen.dart';

class FakeApi implements ApiService {
  @override
  Future<EscanearResult> escanearProducto(String codigo) async {
    return EscanearResult(existe: true, codigo: codigo, producto: Producto(id: 42, nombre: 'T', codigoBarras: '9999', precioCompra: 0, precioVenta: 10, stockActual: 100, stockMinimo: 10, activo: true));
  }
  @override
  Future<int> createProducto(Map<String, dynamic> data) async => 1;
  @override
  Future<Producto> getProductoById(int id) async => Producto(id: id, codigoBarras: 'x', nombre: 'X', precioCompra: 0, precioVenta: 1, stockActual: 1, stockMinimo: 1, activo: true);
  @override
  Future<PaginatedResponse<Producto>> getProductos({int page = 1, int pageSize = 20, String? search, int? categoriaId}) async => PaginatedResponse<Producto>(data: const [], total: 0, page: 1, pageSize: 20, totalPages: 0);
  @override
  Future<List<Categoria>> getCategorias() async => const <Categoria>[];
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError('${i.memberName}');
}

void main() {
  testWidgets('overflow check on master', (tester) async {
    final api = FakeApi();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(AppDatabase.test()),
        apiServiceProvider.overrideWithValue(api),
        copilotSugerenciasProvider.overrideWith((ref) async => const SugerenciasResponse(sugerencias: [], fuente: 't')),
      ],
      child: const MaterialApp(home: CajaScreen()),
    ));
    await tester.pumpAndSettle();
    // Add a product by simulating a scan
    // (skipping — just verify no overflow at empty state)
  });

  testWidgets('no overflow con ventana angosta y baja (móvil corto)', (tester) async {
    tester.view.physicalSize = const Size(660, 300);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final api = FakeApi();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(AppDatabase.test()),
        apiServiceProvider.overrideWithValue(api),
        copilotSugerenciasProvider.overrideWith((ref) async => const SugerenciasResponse(sugerencias: [], fuente: 't')),
      ],
      child: const MaterialApp(home: CajaScreen()),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
