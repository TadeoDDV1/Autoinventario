// Tests del helper buildRapidoCreatePayload.
//
// El helper arma el Map<String, dynamic> que se envía a createProducto desde el
// modo rápido del ProductoFormScreen (A1) y desde el AltaRapidaSheet (B2).
//
// Defaults del modo rápido:
//   - stock_actual = 1
//   - stock_minimo = 1
//   - precio_compra = 0
//
// El helper también debe normalizar el código de barras haciendo `.trim()` para
// que valores como ' 1234 ' no lleguen con espacios al backend (que los rechaza
// o genera duplicados en el índice único).

import 'package:flutter_test/flutter_test.dart';
import 'package:ferreteria_app/providers/producto_provider.dart';

void main() {
  group('buildRapidoCreatePayload', () {
    test(
      '(1) precio entero: payload contiene precio_venta numérico (no string) '
      'y defaults de stock/compras',
      () {
        final payload = buildRapidoCreatePayload(
          nombre: 'Tornillo',
          codigoBarras: '1234',
          precioVenta: 100,
        );

        // Campos explícitos del usuario
        expect(payload['nombre'], 'Tornillo');
        expect(payload['codigo_barras'], '1234');
        expect(payload['precio_venta'], 100);
        // Tipo: DEBE ser num, NO string
        expect(payload['precio_venta'], isA<num>());

        // Defaults del modo rápido
        expect(payload['precio_compra'], 0);
        expect(payload['stock_actual'], 1);
        expect(payload['stock_minimo'], 1);
      },
    );

    test(
      '(2) precio decimal: precio_venta se preserva como double (99.50), '
      'NO como string',
      () {
        final payload = buildRapidoCreatePayload(
          nombre: 'Tuerca',
          codigoBarras: '5678',
          precioVenta: 99.50,
        );

        expect(payload['precio_venta'], closeTo(99.50, 0.0001));
        expect(payload['precio_venta'], isA<num>());
        // Sanity: no debe llegar como string ni entero truncado
        expect(payload['precio_venta'], isNot('99.50'));
        expect(payload['precio_venta'], isNot(99));
      },
    );

    test(
      '(3) strip de espacios en codigoBarras: '
      "input ' 1234 ' → payload['codigo_barras'] == '1234'",
      () {
        final payload = buildRapidoCreatePayload(
          nombre: 'Arandela',
          codigoBarras: ' 1234 ',
          precioVenta: 5,
        );

        expect(payload['codigo_barras'], '1234');
        // No debe contener espacios
        expect((payload['codigo_barras'] as String).contains(' '), isFalse);
      },
    );
  });
}