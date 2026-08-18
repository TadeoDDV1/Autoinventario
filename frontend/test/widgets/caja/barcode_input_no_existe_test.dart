// Tests para el comportamiento de `BarcodeInput` cuando el código ingresado
// NO está registrado en la BD local.
//
// Offline-first estricto: el input ya no llama a `/productos/escanear` del
// servidor. La búsqueda se hace contra la BD local (Drift). El widget debe
// distinguir dos casos:
//
//   1) producto encontrado → onProductoEncontrado(producto)
//      (comportamiento de siempre: agregar al carrito)
//   2) NO encontrado       → onProductoNoRegistrado(codigo)
//      (nuevo callback para que CajaScreen abra el alta rápida)
//
// También cubrimos que NO se llame onError en el caso (2) — antes
// aparecía un SnackBar rojo diciendo "Producto no encontrado", pero ese
// camino será reemplazado por la apertura del alta inline (B2).

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ferreteria_app/database/app_database.dart'
    hide Producto, Categoria;
import 'package:ferreteria_app/database/database_provider.dart';
import 'package:ferreteria_app/models/producto.dart';
import 'package:ferreteria_app/widgets/caja/barcode_input.dart';

void main() {
  group('BarcodeInput — submit contra la BD local (offline-first)', () {
    testWidgets(
      '(1) código no existente dispara onProductoNoRegistrado y NO onError',
      (tester) async {
        Producto? productoEncontrado;
        String? codigoNoRegistrado;
        int errorsCount = 0;

        final db = AppDatabase.test();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: BarcodeInput(
                  onProductoEncontrado: (p) => productoEncontrado = p,
                  onError: (_) => errorsCount++,
                  onProductoNoRegistrado: (c) => codigoNoRegistrado = c,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Escribimos '1234' en el TextField y disparamos submit (mismo
        // path que usa la pistola HID al mandar Enter).
        await tester.enterText(find.byType(TextField), '1234');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        // El callback de "no registrado" se llamó con el código escaneado.
        expect(codigoNoRegistrado, '1234');

        // NO se llamó onProductoEncontrado.
        expect(productoEncontrado, isNull);

        // NO se llamó onError (no más "Producto no encontrado" en Caja).
        expect(errorsCount, 0);
      },
    );

    testWidgets(
      '(2) producto existente en BD dispara onProductoEncontrado y NO onProductoNoRegistrado',
      (tester) async {
        Producto? productoEncontrado;
        String? codigoNoRegistrado;
        int errorsCount = 0;

        final db = AppDatabase.test();
        final now = DateTime.now();
        await db.insertProductos([
          ProductosCompanion.insert(
            id: const Value(42),
            nombre: 'Tornillo 1/4"',
            codigoBarras: const Value('9999'),
            precioCompra: 5,
            precioVenta: 10,
            unidadMedida: 'pieza',
            stockActual: 100,
            stockMinimo: 10,
            activo: true,
            createdAt: now,
            updatedAt: now,
          ),
        ]);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: BarcodeInput(
                  onProductoEncontrado: (p) => productoEncontrado = p,
                  onError: (_) => errorsCount++,
                  onProductoNoRegistrado: (c) => codigoNoRegistrado = c,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '9999');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        // onProductoEncontrado se llamó con el producto de la BD local.
        expect(productoEncontrado, isNotNull);
        expect(productoEncontrado!.id, 42);
        expect(productoEncontrado!.nombre, 'Tornillo 1/4"');

        // onProductoNoRegistrado NO se llamó.
        expect(codigoNoRegistrado, isNull);

        // onError NO se llamó.
        expect(errorsCount, 0);

        // Y el input se limpió (UX de "escaneo exitoso").
        expect(find.widgetWithText(TextField, ''), findsOneWidget);
      },
    );
  });
}