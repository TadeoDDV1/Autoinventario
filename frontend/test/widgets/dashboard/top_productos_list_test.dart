import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ferreteria_app/models/sugerencia.dart';
import 'package:ferreteria_app/widgets/dashboard/top_productos_list.dart';

List<TopProducto> _items(int n) {
  return List.generate(n, (i) {
    return TopProducto(
      productoId: i + 1,
      nombre: 'Producto ${i + 1}',
      cantidad: (i + 1) * 2,
      totalVenta: (n - i) * 1000.0,
    );
  });
}

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('muestra cada producto en orden', (tester) async {
    final items = _items(3);
    await tester.pumpWidget(wrap(TopProductosList(productos: items)));

    expect(find.text('Producto 1'), findsOneWidget);
    expect(find.text('Producto 2'), findsOneWidget);
    expect(find.text('Producto 3'), findsOneWidget);
  });

  testWidgets('trunca a maxItems (default 5)', (tester) async {
    final items = _items(10);
    await tester.pumpWidget(wrap(TopProductosList(productos: items)));

    expect(find.text('Producto 1'), findsOneWidget);
    expect(find.text('Producto 5'), findsOneWidget);
    expect(find.text('Producto 6'), findsNothing);
    expect(find.text('Producto 10'), findsNothing);
  });

  testWidgets('respeta maxItems custom', (tester) async {
    final items = _items(10);
    await tester.pumpWidget(wrap(
      TopProductosList(productos: items, maxItems: 3),
    ));

    expect(find.text('Producto 3'), findsOneWidget);
    expect(find.text('Producto 4'), findsNothing);
  });

  testWidgets('muestra empty state cuando lista vacía', (tester) async {
    await tester.pumpWidget(wrap(const TopProductosList(productos: [])));
    expect(find.text('Aún no hay ventas hoy'), findsOneWidget);
  });

  testWidgets('medallas 🥇🥈🥉 en los primeros 3', (tester) async {
    await tester.pumpWidget(wrap(TopProductosList(productos: _items(5))));

    expect(find.text('🥇'), findsOneWidget);
    expect(find.text('🥈'), findsOneWidget);
    expect(find.text('🥉'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('onTap se dispara con el producto correcto', (tester) async {
    TopProducto? tapped;
    final items = _items(2);
    await tester.pumpWidget(wrap(TopProductosList(
      productos: items,
      onTap: (p) => tapped = p,
    )));
    await tester.tap(find.text('Producto 2'));
    await tester.pump();
    expect(tapped?.productoId, 2);
  });
}