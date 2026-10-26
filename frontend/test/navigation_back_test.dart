import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ferreteria_app/app.dart';
import 'package:ferreteria_app/config/routes.dart';
import 'package:ferreteria_app/core/navigation/route_not_found_screen.dart';
import 'package:ferreteria_app/database/app_database.dart'
    hide Producto, Categoria;
import 'package:ferreteria_app/database/database_provider.dart';
import 'package:ferreteria_app/models/categoria.dart';
import 'package:ferreteria_app/models/paginated_response.dart';
import 'package:ferreteria_app/models/producto.dart';
import 'package:ferreteria_app/models/venta.dart';
import 'package:ferreteria_app/providers/producto_provider.dart';
import 'package:ferreteria_app/screens/caja/caja_screen.dart';
import 'package:ferreteria_app/screens/ventas/historial_ventas_screen.dart';
import 'package:ferreteria_app/screens/ventas/ticket_screen.dart';
import 'package:ferreteria_app/services/api_service.dart';

/// Regresión de navegación.
///
/// El bug original: las rutas overlay (`parentNavigatorKey: _rootNavigatorKey`)
/// se abrían con `context.go()`, lo que montaba el widget dos veces (dentro
/// del shell y en el navigator raíz) y al volver estallaba con
/// "Multiple widgets used the same GlobalKey", dejando la pantalla en negro.
///
/// Ahora se abren con `push` y se cierran con `popOrGo`.
class FakeApi implements ApiService {
  @override
  Future<PaginatedResponse<Producto>> getProductos(
          {int page = 1,
          int pageSize = 20,
          String? search,
          int? categoriaId}) async =>
      PaginatedResponse<Producto>(
          data: const [], total: 0, page: 1, pageSize: 20, totalPages: 0);
  @override
  Future<List<Categoria>> getCategorias() async => const <Categoria>[];
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

Venta _ventaDePrueba() => Venta(
      id: 1,
      folio: 'F-0001',
      detalles: const [
        DetalleVenta(
          productoId: 1,
          nombreProducto: 'Tornillo 1/4"',
          precioUnitario: 2.5,
          cantidad: 4,
          subtotal: 10.0,
        ),
      ],
      subtotal: 10.0,
      iva: 1.6,
      total: 11.6,
      metodoPago: 'efectivo',
      montoRecibido: 20.0,
      cambio: 8.4,
      fecha: DateTime(2026, 10, 23, 12, 30),
    );

Future<GoRouter> _routerOf(WidgetTester tester) async {
  final context = tester.element(find.byType(MaterialApp));
  final container = ProviderScope.containerOf(context, listen: false);
  return container.read(routerProvider);
}

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(AppDatabase.test()),
        apiServiceProvider.overrideWithValue(FakeApi()),
      ],
      child: const FerreteriaApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _backButton() => find.descendant(
      of: find.byType(AppBar),
      matching: find.byIcon(Icons.arrow_back),
    );

void main() {
  testWidgets('abrir Historial con push y regresar deja Caja viva', (tester) async {
    await _pumpApp(tester);
    expect(find.byType(CajaScreen), findsOneWidget);

    final router = await _routerOf(tester);
    router.push('/caja/historial');
    await tester.pumpAndSettle();
    expect(find.byType(HistorialVentasScreen), findsOneWidget);

    await tester.tap(_backButton());
    await tester.pumpAndSettle();

    expect(find.byType(CajaScreen), findsOneWidget,
        reason: 'Tras regresar, Caja debe seguir renderizada');
    expect(tester.takeException(), isNull);
  });

  testWidgets('varios overlays apilados se cierran en orden', (tester) async {
    await _pumpApp(tester);
    final router = await _routerOf(tester);

    router.push('/caja/historial');
    await tester.pumpAndSettle();
    router.push('/caja/ticket', extra: _ventaDePrueba());
    await tester.pumpAndSettle();
    expect(find.byType(TicketScreen), findsOneWidget);

    // Cerrar el ticket vuelve al historial...
    await tester.tap(_backButton());
    await tester.pumpAndSettle();
    expect(find.byType(HistorialVentasScreen), findsOneWidget);

    // ...y cerrar el historial vuelve a Caja.
    await tester.tap(_backButton());
    await tester.pumpAndSettle();
    expect(find.byType(CajaScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el Ticket muestra el diseño nuevo y navega a Caja', (tester) async {
    await _pumpApp(tester);
    final router = await _routerOf(tester);

    router.push('/caja/ticket', extra: _ventaDePrueba());
    await tester.pumpAndSettle();
    expect(find.byType(TicketScreen), findsOneWidget);

    // Contenido del nuevo diseño.
    expect(find.text('TICKET'), findsWidgets);
    expect(find.text('F-0001'), findsWidgets);
    expect(find.text('TOTAL'), findsOneWidget);
    expect(find.textContaining(r'$11.60'), findsWidgets);
    expect(find.text('Tornillo 1/4"'), findsOneWidget);
    expect(find.text('¡Gracias por su compra!'), findsOneWidget);

    // "Nuevo ticket" cierra el overlay y vuelve a Caja.
    await tester.scrollUntilVisible(
      find.text('Nuevo ticket'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Nuevo ticket'));
    await tester.pumpAndSettle();

    expect(find.byType(TicketScreen), findsNothing);
    expect(find.byType(CajaScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el botón "atrás" del navegador (hashchange) también vuelve a Caja',
      (tester) async {
    await _pumpApp(tester);
    final router = await _routerOf(tester);

    // El navegador no hace `pop`: cambia el hash, que GoRouter traduce en `go`.
    router.go('/caja/historial');
    await tester.pumpAndSettle();
    expect(find.byType(HistorialVentasScreen), findsOneWidget);

    router.go('/caja');
    await tester.pumpAndSettle();

    expect(find.byType(CajaScreen), findsOneWidget,
        reason: 'Tras el "atrás" del navegador, Caja debe seguir renderizada');
    expect(find.byType(HistorialVentasScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('una ruta inexistente muestra la pantalla de error, no pantalla en blanco',
      (tester) async {
    await _pumpApp(tester);
    final router = await _routerOf(tester);

    // Regresión: antes esto era context.go('/ventas') (ruta inexistente) y
    // la app se quedaba en blanco con "No routes for location".
    router.go('/ventas');
    await tester.pumpAndSettle();

    expect(find.byType(RouteNotFoundScreen), findsOneWidget);

    await tester.tap(find.text('Ir a Caja'));
    await tester.pumpAndSettle();
    expect(find.byType(CajaScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
