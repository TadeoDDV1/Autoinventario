// Tests para el comportamiento de `BarcodeInput` cuando el código ingresado
// NO está registrado en el backend.
//
// Bloque B — Task B1: el input dejó de usar `/buscar` y pasó a usar
// `/productos/escanear`. El endpoint nuevo no devuelve 404 cuando el código
// no existe, sino `{existe: false, codigo: "..."}`. El widget debe distinguir
// dos casos:
//
//   1) existe == true  + producto != null → onProductoEncontrado(producto)
//      (comportamiento de siempre: agregar al carrito)
//   2) existe == false                  → onProductoNoRegistrado(codigo)
//      (nuevo callback para que CajaScreen abra el alta rápida)
//
// También cubrimos que NO se llame onError en el caso (2) — antes
// aparecía un SnackBar rojo diciendo "Producto no encontrado", pero ese
// camino será reemplazado por la apertura del alta inline (B2).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ferreteria_app/models/producto.dart';
import 'package:ferreteria_app/providers/producto_provider.dart';
import 'package:ferreteria_app/services/api_service.dart';
import 'package:ferreteria_app/widgets/caja/barcode_input.dart';

/// Fake mínimo de ApiService que sólo implementa los métodos que el
/// `BarcodeInput` toca cuando se hace submit (_onSubmit):
///   - getProductos (para el debounce de búsqueda por nombre, sólo si se
///                   dispara en el test — lo dejamos en noSuchMethod con
///                   tolerancia)
///   - escanearProducto (lo que vamos a stubbear explícitamente)
///
/// Cualquier otro método que el widget invoque accidentalmente hace throw
/// ruidoso para detectarlo.
class _FakeApiService implements ApiService {
  EscanearResult escanearStub;
  final List<String> escanearCalls = [];

  _FakeApiService({required this.escanearStub});

  @override
  Future<EscanearResult> escanearProducto(String codigo) async {
    escanearCalls.add(codigo);
    return escanearStub;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'ApiService fake: método no stubbeado -> ${invocation.memberName}',
    );
  }
}

void main() {
  group('BarcodeInput — submit contra /escanear (Bloque B / Task B1)', () {
    testWidgets(
      '(1) existe=false dispara onProductoNoRegistrado y NO onError',
      (tester) async {
        Producto? productoEncontrado;
        String? codigoNoRegistrado;
        int errorsCount = 0;

        final api = _FakeApiService(
          escanearStub: EscanearResult(
            existe: false,
            codigo: '1234',
            producto: null,
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              apiServiceProvider.overrideWithValue(api),
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

        // La API recibió el código (sin espacios extra).
        expect(api.escanearCalls, ['1234']);

        // El callback de "no registrado" se llamó con el código escaneado.
        expect(codigoNoRegistrado, '1234');

        // NO se llamó onProductoEncontrado.
        expect(productoEncontrado, isNull);

        // NO se llamó onError (no más "Producto no encontrado" en Caja).
        expect(errorsCount, 0);
      },
    );

    testWidgets(
      '(2) existe=true + producto!=null dispara onProductoEncontrado y NO onProductoNoRegistrado',
      (tester) async {
        Producto? productoEncontrado;
        String? codigoNoRegistrado;
        int errorsCount = 0;
        final fakeProducto = Producto(
          id: 42,
          nombre: 'Tornillo 1/4"',
          codigoBarras: '9999',
          precioCompra: 5,
          precioVenta: 10,
          stockActual: 100,
          stockMinimo: 10,
          activo: true,
        );

        final api = _FakeApiService(
          escanearStub: EscanearResult(
            existe: true,
            codigo: '9999',
            producto: fakeProducto,
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              apiServiceProvider.overrideWithValue(api),
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

        // El callback de encontrado se llamó con el producto del backend.
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
