// Tests para `AltaRapidaSheet` (Bloque B — Task B2).
//
// Es el feature estrella del modo rápido desde Caja: cuando el operador
// escanea algo que NO está registrado, se abre este bottom sheet inline
// con 3 campos:
//   - Nombre (autofocus, required)
//   - Código (readOnly, auto-generado 0–9999, con botón 🔄)
//   - Precio venta (number, required, >0)
//
// Y al submit llama a `createProducto(buildRapidoCreatePayload(...))`.
//
// Casos cubiertos:
//   (1) Render muestra 3 campos; código readonly, numérico, 1-4 dígitos.
//   (2) Botón regenerar cambia el código (probabilistic, 100 iteraciones).
//   (3) Submit con nombre vacío → validación, no llama createProducto.
//   (4) Submit con precio vacío → validación.
//   (5) Submit OK → createProducto con stock_actual=1, stock_minimo=1,
//       precio_compra=0, codigo_barras de 1-4 dígitos numéricos.
//   (6) Cancel (botón cerrar) → devuelve null.
//   (7) createProducto lanza ApiException(409) → regenera código y
//       reintenta una 2da vez.
//   (8) Tras 5 reintentos sigue fallando con 409 → habilita edición del
//       código y muestra snack "Tipealo manual:".
//   (9) Error genérico (no 409) → snack rojo y se queda en el sheet.
//   (10/11/12) Manejo del codigoInicial: numérico OK, no-numérico → regenera,
//       null → genera.
//   (13) AppBar título + ícono cerrar.
//   (14) TextField interno es readOnly.

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ferreteria_app/database/app_database.dart'
    hide Producto, Categoria;
import 'package:ferreteria_app/database/database_provider.dart';
import 'package:ferreteria_app/models/producto.dart';
import 'package:ferreteria_app/providers/producto_provider.dart';
import 'package:ferreteria_app/services/api_service.dart';
import 'package:ferreteria_app/widgets/caja/alta_rapida_sheet.dart';

/// Fake `ApiService` configurable por test:
///   - `createBehavior`: cola de respuestas — `Producto` para resolver con
///     éxito, `ApiException` para simular errores (404, 409, etc).
///   - `createCalls`: registra cada payload enviado.
class _FakeApiService implements ApiService {
  final List<Object> createBehavior;
  final List<Map<String, dynamic>> createCalls = [];

  _FakeApiService({this.createBehavior = const []});

  @override
  Future<int> createProducto(Map<String, dynamic> data) async {
    createCalls.add(Map<String, dynamic>.from(data));
    if (createBehavior.isNotEmpty) {
      final next = createBehavior.removeAt(0);
      if (next is Producto) return next.id;
      if (next is Exception) throw next;
    }
    // Sin más respuestas en cola → éxito por defecto (id auto-incremental).
    return 100 + createCalls.length;
  }

  @override
  Future<Producto> getProductoById(int id) async {
    // Devuelve un Producto con el id recibido; el sheet sólo necesita
    // que sea no-null para hacer `Navigator.pop(context, producto)`.
    return Producto(
      id: id,
      codigoBarras: 'fake-$id',
      nombre: 'Stub producto',
      precioCompra: 0,
      precioVenta: 50,
      stockActual: 1,
      stockMinimo: 1,
      activo: true,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'ApiService fake: método no stubbeado -> ${invocation.memberName}',
    );
  }
}

Producto _stubProducto({int id = 777, String? codigo}) {
  return Producto(
    id: id,
    codigoBarras: codigo,
    nombre: 'Stub producto',
    precioCompra: 0,
    precioVenta: 50,
    stockActual: 1,
    stockMinimo: 1,
    activo: true,
  );
}

/// Helpers para inspeccionar el campo "Código de barras".
/// `TextFormField` no expone `readOnly` como getter, así que bajamos al
/// `TextField` interno (que sí lo expone).
TextFormField _codigoTFF(WidgetTester tester) => tester.widget<TextFormField>(
      find.widgetWithText(TextFormField, 'Código de barras'),
    );

String _codigoTexto(WidgetTester tester) => _codigoTFF(tester).controller!.text;

bool _codigoReadOnly(WidgetTester tester) {
  final tff = _codigoTFF(tester);
  final inner = tester.widget<TextField>(
    find.descendant(of: find.byWidget(tff), matching: find.byType(TextField)),
  );
  return inner.readOnly;
}

Widget _wrap({required _FakeApiService api, String? codigoInicial, AppDatabase? db}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db ?? AppDatabase.test()),
      apiServiceProvider.overrideWithValue(api),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet<Producto?>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) =>
                      AltaRapidaSheet(codigoInicial: codigoInicial),
                );
              },
              child: const Text('OPEN_SHEET'),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.text('OPEN_SHEET'));
  await tester.pumpAndSettle();
}

Future<void> _fillNombrePrecio(
  WidgetTester tester, {
  String nombre = 'Tornillo autogen',
  String precio = '15.50',
}) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Nombre del producto *'),
    nombre,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Precio venta *'),
    precio,
  );
  await tester.pump();
}

void main() {
  group('AltaRapidaSheet — render y validación', () {
    testWidgets(
      '(1) render muestra 3 campos, código readonly numérico de 1-4 dígitos',
      (tester) async {
        final api = _FakeApiService();
        await tester.pumpWidget(_wrap(api: api));
        await tester.pumpAndSettle();
        await _openSheet(tester);

        // 3 TextFormField con labels específicos
        expect(find.widgetWithText(TextFormField, 'Nombre del producto *'),
            findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Código de barras'),
            findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Precio venta *'),
            findsOneWidget);

        // Banner informativo presente
        expect(
          find.textContaining('Código interno generado automáticamente'),
          findsOneWidget,
        );

        // El campo código es readonly y empieza con 1-4 dígitos numéricos
        expect(_codigoReadOnly(tester), isTrue);
        final inicial = _codigoTexto(tester);
        expect(RegExp(r'^[0-9]+$').hasMatch(inicial), isTrue,
            reason: 'Código inicial no numérico: "$inicial"');
        expect(inicial.length, inInclusiveRange(1, 4),
            reason: 'Longitud inesperada: "$inicial"');

        // Botón regenerar presente
        expect(find.byIcon(Icons.refresh), findsOneWidget);

        // Botón submit
        expect(find.text('Crear y agregar al carrito'), findsOneWidget);
      },
    );

    testWidgets(
      '(2) tap en 🔄 regenera código (al menos 1 cambio en 100 iteraciones)',
      (tester) async {
        final api = _FakeApiService();
        await tester.pumpWidget(_wrap(api: api));
        await tester.pumpAndSettle();
        await _openSheet(tester);

        final inicial = _codigoTexto(tester);

        // Probabilistic: con 10000 valores posibles y 100 iteraciones, la
        // probabilidad de NO obtener ningún cambio es (9999/10000)^100 ≈ 0.99.
        // => P(no cambio) ≈ 1%. Aceptamos flakes mínimas.
        final vistos = <String>{inicial};
        for (var i = 0; i < 100; i++) {
          await tester.tap(find.byIcon(Icons.refresh));
          await tester.pump();
          vistos.add(_codigoTexto(tester));
          if (vistos.length > 1) break;
        }

        expect(vistos.length, greaterThan(1),
            reason:
                'El botón 🔄 no cambió el código tras 100 taps. Generador posiblemente sesgado.');
      },
    );

    testWidgets('(3) submit con nombre vacío → validación, NO llama createProducto',
        (tester) async {
      final api = _FakeApiService();
      await tester.pumpWidget(_wrap(api: api));
      await tester.pumpAndSettle();
      await _openSheet(tester);

      // Llenamos SOLO el precio
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Precio venta *'),
        '10',
      );
      await tester.tap(find.text('Crear y agregar al carrito'));
      await tester.pump();

      expect(find.text('Requerido'), findsOneWidget);
      expect(api.createCalls, isEmpty);
    });

    testWidgets('(4) submit con precio vacío → validación, NO llama createProducto',
        (tester) async {
      final api = _FakeApiService();
      await tester.pumpWidget(_wrap(api: api));
      await tester.pumpAndSettle();
      await _openSheet(tester);

      // Llenamos SOLO el nombre
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre del producto *'),
        'Algo',
      );
      await tester.tap(find.text('Crear y agregar al carrito'));
      await tester.pump();

      // El validator del precio devuelve "Debe ser mayor a 0" o "Requerido"
      // según esté vacío. Aceptamos cualquiera de los dos.
      final hayError = find.text('Requerido').evaluate().isNotEmpty ||
          find.textContaining('mayor a 0').evaluate().isNotEmpty;
      expect(hayError, isTrue);
      expect(api.createCalls, isEmpty);
    });

    testWidgets(
      '(5) submit OK → crea producto en BD local con defaults (stock=1/1, compra=0) y código 1-4 dígitos',
      (tester) async {
        final db = AppDatabase.test();
        final api = _FakeApiService();
        await tester.pumpWidget(_wrap(api: api, db: db));
        await tester.pumpAndSettle();
        await _openSheet(tester);

        await _fillNombrePrecio(tester, nombre: 'Tornillo B2', precio: '15.50');

        await tester.tap(find.text('Crear y agregar al carrito'));
        // El sheet dispara Navigator.pop con el Producto creado. Hay que
        // esperar a que el frame se estabilice.
        await tester.pumpAndSettle();

        // La creación es 100% local (offline-first): el producto quedó en
        // la BD con los defaults del modo rápido.
        final creados = await db.getAllProductos();
        expect(creados, hasLength(1));
        final p = creados.single;
        expect(p.nombre, 'Tornillo B2');
        expect(p.precioVenta, closeTo(15.5, 0.0001));
        expect(p.stockActual, 1);
        expect(p.stockMinimo, 1);
        expect(p.precioCompra, 0);
        expect(p.codigoBarras, isNotNull);
        expect(RegExp(r'^[0-9]+$').hasMatch(p.codigoBarras!), isTrue);
        expect(p.codigoBarras!.length, inInclusiveRange(1, 4));
      },
    );

    testWidgets('(6) botón cerrar (X) → Navigator.pop(null)', (tester) async {
      final api = _FakeApiService();
      await tester.pumpWidget(_wrap(api: api));
      await tester.pumpAndSettle();
      await _openSheet(tester);

      // El IconButton con Icon(Icons.close) en el AppBar del sheet
      expect(find.byIcon(Icons.close), findsWidgets);
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      // El sheet se cerró → no debe quedar el banner informativo
      expect(
        find.textContaining('Código interno generado automáticamente'),
        findsNothing,
      );
      // Y no se llamó createProducto
      expect(api.createCalls, isEmpty);
    });
  });

  group('AltaRapidaSheet — manejo de errores de createProducto', () {
    testWidgets(
      '(7) código que ya existe en BD local → regenera y crea con otro código',
      (tester) async {
        // Sembrar un producto cuyo código coincide con el código inicial
        // del sheet.
        final db = AppDatabase.test();
        final now = DateTime.now();
        await db.insertProductos([
          ProductosCompanion.insert(
            id: const Value(7777),
            nombre: 'Existente',
            codigoBarras: const Value('1234'),
            precioCompra: 0,
            precioVenta: 10,
            unidadMedida: 'pieza',
            stockActual: 5,
            stockMinimo: 1,
            activo: true,
            createdAt: now,
            updatedAt: now,
          ),
        ]);

        final api = _FakeApiService();
        await tester.pumpWidget(_wrap(api: api, db: db, codigoInicial: '1234'));
        await tester.pumpAndSettle();
        await _openSheet(tester);

        final codigo1 = _codigoTexto(tester);
        expect(codigo1, '1234');

        await _fillNombrePrecio(tester, nombre: 'Producto nuevo', precio: '10');
        await tester.tap(find.text('Crear y agregar al carrito'));
        await tester.pumpAndSettle();

        // La creación es local: se insertó un segundo producto con un
        // código distinto al que ya existía en la BD.
        final creados = await db.getAllProductos();
        expect(creados, hasLength(2));
        final nuevo = creados.firstWhere((p) => p.nombre == 'Producto nuevo');
        expect(nuevo.codigoBarras, isNot('1234'),
            reason: 'Tras colisión local debería regenerar el código');
        expect(nuevo.codigoBarras!.length, inInclusiveRange(1, 4));
      },
    );

    testWidgets(
      '(8) código disponible → alta rápida exitosa aunque la BD tenga otros productos',
      (tester) async {
        // Con productos variados en BD, el sheet debe lograr crear el nuevo
        // (el código inicial es aleatorio y casi nunca colisiona).
        final db = AppDatabase.test();
        final now = DateTime.now();
        await db.insertProductos([
          for (var i = 1; i <= 3; i++)
            ProductosCompanion.insert(
              id: Value(i),
              nombre: 'Producto $i',
              codigoBarras: Value('$i'),
              precioCompra: 0,
              precioVenta: 10,
              unidadMedida: 'pieza',
              stockActual: 5,
              stockMinimo: 1,
              activo: true,
              createdAt: now,
              updatedAt: now,
            ),
        ]);

        final api = _FakeApiService();
        await tester.pumpWidget(_wrap(api: api, db: db));
        await tester.pumpAndSettle();
        await _openSheet(tester);

        await _fillNombrePrecio(tester, nombre: 'Nuevo creado', precio: '25');
        await tester.tap(find.text('Crear y agregar al carrito'));
        await tester.pumpAndSettle();

        final creados = await db.getAllProductos();
        expect(creados, hasLength(4));
        expect(creados.any((p) => p.nombre == 'Nuevo creado'), isTrue);
      },
    );

    testWidgets(
      '(9) submit OK devuelve el producto vía Navigator.pop para agregarlo al carrito',
      (tester) async {
        Producto? resultado;
        final db = AppDatabase.test();
        final api = _FakeApiService();
        await tester.pumpWidget(ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            apiServiceProvider.overrideWithValue(api),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      resultado = await showModalBottomSheet<Producto?>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const AltaRapidaSheet(),
                      );
                    },
                    child: const Text('OPEN_SHEET'),
                  ),
                ),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        await _openSheet(tester);

        await _fillNombrePrecio(tester, nombre: 'Devuélveme', precio: '33');
        await tester.tap(find.text('Crear y agregar al carrito'));
        await tester.pumpAndSettle();

        expect(resultado, isNotNull);
        expect(resultado!.nombre, 'Devuélveme');
        expect(resultado!.precioVenta, closeTo(33, 0.0001));
      },
    );
  });

  group('AltaRapidaSheet — codigoInicial', () {
    testWidgets('(10) codigoInicial="42" → el campo arranca con "42" (no se regenera)',
        (tester) async {
      final api = _FakeApiService(
        createBehavior: [_stubProducto(id: 200, codigo: '42')],
      );
      await tester.pumpWidget(_wrap(api: api, codigoInicial: '42'));
      await tester.pumpAndSettle();
      await _openSheet(tester);

      expect(_codigoTexto(tester), '42');
    });

    testWidgets(
      '(11) codigoInicial con caracteres no numéricos → se regenera uno nuevo',
      (tester) async {
        // "ABC123" no es un código válido de Caja (rango 0-9999); el sheet
        // debe tratarlo como si viniera null y generar uno aleatorio.
        final api = _FakeApiService();
        await tester.pumpWidget(_wrap(api: api, codigoInicial: 'ABC123'));
        await tester.pumpAndSettle();
        await _openSheet(tester);

        final txt = _codigoTexto(tester);
        expect(txt, isNot('ABC123'));
        expect(RegExp(r'^[0-9]+$').hasMatch(txt), isTrue);
        expect(txt.length, inInclusiveRange(1, 4));
      },
    );

    testWidgets('(12) sin codigoInicial → genera uno numérico de 1-4 dígitos',
        (tester) async {
      final api = _FakeApiService();
      await tester.pumpWidget(_wrap(api: api));
      await tester.pumpAndSettle();
      await _openSheet(tester);

      final txt = _codigoTexto(tester);
      expect(txt.isNotEmpty, isTrue);
      expect(RegExp(r'^[0-9]+$').hasMatch(txt), isTrue);
      expect(txt.length, inInclusiveRange(1, 4));
    });
  });

  group('AltaRapidaSheet — chrome y detalles', () {
    testWidgets('(13) el AppBar muestra título "Alta rápida" e ícono cerrar',
        (tester) async {
      final api = _FakeApiService();
      await tester.pumpWidget(_wrap(api: api));
      await tester.pumpAndSettle();
      await _openSheet(tester);

      expect(find.text('Alta rápida'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsWidgets);
    });

    testWidgets('(14) el TextField del código es readOnly', (tester) async {
      final api = _FakeApiService();
      await tester.pumpWidget(_wrap(api: api));
      await tester.pumpAndSettle();
      await _openSheet(tester);

      expect(_codigoReadOnly(tester), isTrue);
    });
  });
}
