import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ferreteria_app/models/venta.dart';
import 'package:ferreteria_app/screens/ventas/ticket_screen.dart';

/// Golden del ticket de venta (diseño "papel térmico").
///
/// Sirve como regresión visual: si alguien cambia el layout del ticket,
/// este test obliga a revisar el cambio con `flutter test --update-goldens`.
Venta _venta() => Venta(
      id: 42,
      folio: 'F-00042',
      detalles: const [
        DetalleVenta(
          productoId: 1,
          nombreProducto: 'Martillo Tubular 16oz',
          precioUnitario: 100.0,
          cantidad: 1,
          subtotal: 100.0,
        ),
        DetalleVenta(
          productoId: 2,
          nombreProducto: 'Cinta Métrica 5m',
          precioUnitario: 50.0,
          cantidad: 2,
          subtotal: 100.0,
        ),
      ],
      subtotal: 172.41,
      iva: 27.59,
      total: 200.00,
      metodoPago: 'efectivo',
      montoRecibido: 200.00,
      cambio: 0.0,
      fecha: DateTime(2026, 10, 23, 12, 30),
    );

Future<void> _pumpTicket(WidgetTester tester, {Brightness? brightness}) async {
  tester.view.physicalSize = const Size(900, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData(brightness: brightness ?? Brightness.light),
        home: TicketScreen(venta: _venta()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('golden del ticket (claro)', (tester) async {
    await _pumpTicket(tester);
    expect(find.byType(TicketScreen), findsOneWidget);
    await expectLater(
      find.byType(TicketScreen),
      matchesGoldenFile('goldens/ticket_claro.png'),
    );
  });

  testWidgets('golden del ticket (oscuro)', (tester) async {
    await _pumpTicket(tester, brightness: Brightness.dark);
    expect(find.byType(TicketScreen), findsOneWidget);
    await expectLater(
      find.byType(TicketScreen),
      matchesGoldenFile('goldens/ticket_oscuro.png'),
    );
  });
}
