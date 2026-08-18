// Tests para el modo rápido de ProductoFormScreen (Bloque A — Task A1).
//
// Cuando se invoca con `mode: ProductoFormMode.rapido` y NO se está editando
// (sin `productoId`), el form debe mostrar sólo 3 campos:
//   - Nombre del producto
//   - Código de barras (readonly, regenerable)
//   - Precio venta
//
// Y al hacer submit debe enviar a `createProducto` los defaults:
//   - stock_actual = 1
//   - stock_minimo = 1
//   - precio_compra = 0
//   - codigo_barras auto-generado (placeholder; el helper real vive en A2)
//
// Si se está editando (productoId != null), el `mode` se IGNORA y se muestra
// el form completo (no tiene sentido editar en modo rápido).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ferreteria_app/models/categoria.dart';
import 'package:ferreteria_app/models/producto.dart';
import 'package:ferreteria_app/providers/producto_provider.dart';
import 'package:ferreteria_app/screens/inventario/producto_form_screen.dart';
import 'package:ferreteria_app/services/api_service.dart';
import 'package:ferreteria_app/database/app_database.dart' show AppDatabase;
import 'package:ferreteria_app/database/database_provider.dart';

/// Fake mínimo de ApiService: registra llamadas a createProducto/updateProducto
/// y devuelve datos stub. NO toca la red.
class _FakeApiService implements ApiService {
  final List<Map<String, dynamic>> createCalls = [];
  final List<Map<String, dynamic>> updateCalls = [];
  Producto? productoById;
  final List<Categoria> categorias;

  _FakeApiService({
    this.productoById,
    this.categorias = const [],
  });

  @override
  Future<Producto> getProductoById(int id) async {
    return productoById ??
        Producto(
          id: id,
          nombre: 'Stub',
          precioCompra: 10,
          precioVenta: 20,
          stockActual: 100,
          stockMinimo: 5,
          activo: true,
        );
  }

  @override
  Future<int> createProducto(Map<String, dynamic> data) async {
    createCalls.add(Map<String, dynamic>.from(data));
    return 999;
  }

  @override
  Future<void> updateProducto(int id, Map<String, dynamic> data) async {
    updateCalls.add(Map<String, dynamic>.from(data));
  }

  // El resto de la API no se usa en estos tests; lanzamos para detectar
  // invocaciones accidentales.
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'ApiService fake: método no stubbeado -> ${invocation.memberName}',
    );
  }
}

/// Notifier fake para categorías: devuelve la lista inyectada sin tocar la red.
class _FakeCategoriasNotifier extends CategoriasNotifier {
  final List<Categoria> _value;
  _FakeCategoriasNotifier(this._value);
  @override
  Future<List<Categoria>> build() async => _value;
}

/// Helpers para envolver la pantalla con un ProviderScope que override los
/// providers que el widget lee (api + categorías).
Widget _wrap({
  required Widget child,
  required _FakeApiService api,
  List<Categoria>? categorias,
  AppDatabase? db,
}) {
  return ProviderScope(
    overrides: [
      apiServiceProvider.overrideWithValue(api),
      categoriasProvider.overrideWith(
        () => _FakeCategoriasNotifier(categorias ?? const <Categoria>[]),
      ),
      appDatabaseProvider.overrideWithValue(db ?? AppDatabase.test()),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('ProductoFormScreen — modo rápido', () {
    testWidgets(
      '(1) render con mode=rapido muestra sólo 3 campos visibles',
      (tester) async {
        final api = _FakeApiService();
        await tester.pumpWidget(
          _wrap(
            api: api,
            child: const ProductoFormScreen(
              mode: ProductoFormMode.rapido,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Campos visibles en modo rápido
        expect(find.widgetWithText(TextFormField, 'Nombre del producto *'),
            findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Código de barras'),
            findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Precio venta *'),
            findsOneWidget);

        // Campos OCULTOS en modo rápido
        expect(find.widgetWithText(TextFormField, 'Descripción'),
            findsNothing);
        expect(find.widgetWithText(TextFormField, 'Uso / Aplicaciones'),
            findsNothing);
        expect(find.widgetWithText(TextFormField, 'Precio compra *'),
            findsNothing);
        expect(find.widgetWithText(TextFormField, 'Stock actual'),
            findsNothing);
        expect(find.widgetWithText(TextFormField, 'Stock mínimo'),
            findsNothing);
        expect(find.byType(DropdownButtonFormField<int>), findsNothing);

        // Banner informativo presente
        expect(
          find.textContaining('Código interno generado automáticamente'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '(2) submit con nombre vacío → validation error, no llama createProducto',
      (tester) async {
        final api = _FakeApiService();
        await tester.pumpWidget(
          _wrap(
            api: api,
            child: const ProductoFormScreen(
              mode: ProductoFormMode.rapido,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Dejar precio OK para aislar la validación de nombre
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Precio venta *'),
          '100',
        );

        // Tap submit SIN nombre
        await tester.tap(find.text('Crear y agregar al carrito'));
        await tester.pump();

        expect(find.text('Requerido'), findsOneWidget);
        expect(api.createCalls, isEmpty);
      },
    );

    testWidgets(
      '(3) submit con precio vacío → validation error, no llama createProducto',
      (tester) async {
        final api = _FakeApiService();
        await tester.pumpWidget(
          _wrap(
            api: api,
            child: const ProductoFormScreen(
              mode: ProductoFormMode.rapido,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Poner nombre OK, dejar precio vacío
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nombre del producto *'),
          'Tornillo',
        );

        await tester.tap(find.text('Crear y agregar al carrito'));
        await tester.pump();

        // El validator del precio venta dice "Debe ser mayor a 0"
        expect(find.text('Requerido'), findsOneWidget);
        expect(api.createCalls, isEmpty);
      },
    );

    testWidgets(
      '(4) submit OK → crea producto en BD local con defaults (stock=1/1, compra=0)',
      (tester) async {
        final db = AppDatabase.test();
        final api = _FakeApiService();
        await tester.pumpWidget(
          _wrap(
            api: api,
            db: db,
            child: const ProductoFormScreen(
              mode: ProductoFormMode.rapido,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nombre del producto *'),
          'Tornillo autogen',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Precio venta *'),
          '15.50',
        );

        await tester.tap(find.text('Crear y agregar al carrito'));
        await tester.pumpAndSettle();

        // Offline-first: el producto se guarda en la BD local (no se llama
        // a la API).
        final creados = await db.getAllProductos();
        expect(creados, hasLength(1));
        final p = creados.single;

        // Campos explícitos del usuario
        expect(p.nombre, 'Tornillo autogen');
        expect(p.precioVenta, closeTo(15.5, 0.0001));

        // Defaults del modo rápido
        expect(p.stockActual, 1);
        expect(p.stockMinimo, 1);
        expect(p.precioCompra, 0);

        // El código de barras debe estar presente (generado)
        expect(p.codigoBarras, isNotNull);
        expect(p.codigoBarras!.isNotEmpty, isTrue);

        // El producto quedó encolado para sincronizar
        final pendientes = await db.getProductosPendientes();
        expect(pendientes, hasLength(1));
      },
    );

    testWidgets(
      '(5) editar (productoId != null) ignora mode=rapido y muestra form completo',
      (tester) async {
        final api = _FakeApiService(
          productoById: Producto(
            id: 42,
            nombre: 'Producto existente',
            codigoBarras: '7501',
            descripcion: 'desc',
            precioCompra: 8,
            precioVenta: 16,
            stockActual: 50,
            stockMinimo: 10,
            categoriaId: 1,
            activo: true,
          ),
          categorias: const [Categoria(id: 1, nombre: 'Herramientas')],
        );
        await tester.pumpWidget(
          _wrap(
            api: api,
            child: const ProductoFormScreen(
              productoId: 42,
              // Ignorado cuando productoId != null
              mode: ProductoFormMode.rapido,
            ),
          ),
        );
        // Esperar carga async del producto y categorías
        await tester.pumpAndSettle();

        // El form completo debe estar visible: aparecen los campos ocultos
        expect(find.widgetWithText(TextFormField, 'Descripción'),
            findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Uso / Aplicaciones'),
            findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Precio compra *'),
            findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Stock actual'),
            findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Stock mínimo'),
            findsOneWidget);
        expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);

        // Y el banner de modo rápido NO debe estar
        expect(
          find.textContaining('Código interno generado automáticamente'),
          findsNothing,
        );

        // El botón debe ser el de editar (no el de "crear y agregar")
        expect(find.text('Actualizar Producto'), findsOneWidget);
        expect(find.text('Crear y agregar al carrito'), findsNothing);
      },
    );

    testWidgets(
      '(6) form full (crear) muestra IconButton flash_on → navega a /inventario/nuevo-rapido',
      (tester) async {
        final api = _FakeApiService();
        final router = GoRouter(
          initialLocation: '/inventario/nuevo',
          routes: [
            GoRoute(
              path: '/inventario/nuevo',
              builder: (context, state) => const ProductoFormScreen(),
            ),
            GoRoute(
              path: '/inventario/nuevo-rapido',
              builder: (context, state) => const Scaffold(
                body: Text('RAPIDO_DESTINO'),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              apiServiceProvider.overrideWithValue(api),
              categoriasProvider.overrideWith(
                () => _FakeCategoriasNotifier(const <Categoria>[]),
              ),
              appDatabaseProvider.overrideWithValue(AppDatabase.test()),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // El form debe estar en pantalla (default full, sin productoId)
        expect(find.text('Nuevo Producto'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Descripción'),
            findsOneWidget);

        // El IconButton de "Cambiar a modo rápido" debe estar presente
        final flashBtn = find.widgetWithIcon(IconButton, Icons.flash_on);
        expect(flashBtn, findsOneWidget);

        // Tap → debe navegar a /inventario/nuevo-rapido
        await tester.tap(flashBtn);
        await tester.pumpAndSettle();

        expect(find.text('RAPIDO_DESTINO'), findsOneWidget);
        expect(router.routerDelegate.currentConfiguration.uri.path,
            '/inventario/nuevo-rapido');
      },
    );
  });
}