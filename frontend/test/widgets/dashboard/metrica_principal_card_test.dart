import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ferreteria_app/widgets/dashboard/metrica_principal_card.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('muestra título, valor, subtítulo y meta', (tester) async {
    await tester.pumpWidget(wrap(
      const MetricaPrincipalCard(
        titulo: 'Ventas hoy',
        valor: '\$12,450.00',
        subtitulo: '42 transacciones',
        meta: 'Ticket prom \$298',
        icon: Icons.payments,
        colorPrimario: Colors.green,
      ),
    ));

    expect(find.text('VENTAS HOY'), findsOneWidget);
    expect(find.text('\$12,450.00'), findsOneWidget);
    expect(find.text('42 transacciones'), findsOneWidget);
    expect(find.text('Ticket prom \$298'), findsOneWidget);
  });

  testWidgets('renderiza el trailing widget si se pasa', (tester) async {
    await tester.pumpWidget(wrap(
      MetricaPrincipalCard(
        titulo: 'Ventas hoy',
        valor: '\$0',
        subtitulo: '',
        icon: Icons.payments,
        colorPrimario: Colors.green,
        trailing: const Chip(label: Text('TRAILING')),
      ),
    ));

    expect(find.text('TRAILING'), findsOneWidget);
  });

  testWidgets('no rompe si meta es null', (tester) async {
    await tester.pumpWidget(wrap(
      const MetricaPrincipalCard(
        titulo: 'Ventas hoy',
        valor: '\$0',
        subtitulo: '',
        icon: Icons.payments,
        colorPrimario: Colors.green,
      ),
    ));

    expect(find.text('VENTAS HOY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}