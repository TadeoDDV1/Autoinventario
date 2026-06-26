import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ferreteria_app/widgets/dashboard/metrica_secundaria_card.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('muestra título, valor y subtítulo', (tester) async {
    await tester.pumpWidget(wrap(
      const MetricaSecundariaCard(
        titulo: 'Efectivo',
        valor: r'$7,200.00',
        subtitulo: 'recaudado',
        icon: Icons.money,
        colorIcono: Colors.green,
      ),
    ));

    expect(find.text('Efectivo'), findsOneWidget);
    expect(find.text(r'$7,200.00'), findsOneWidget);
    expect(find.text('recaudado'), findsOneWidget);
    expect(find.byIcon(Icons.money), findsOneWidget);
  });

  testWidgets('respeta la altura fija del card', (tester) async {
    await tester.pumpWidget(wrap(
      const MetricaSecundariaCard(
        titulo: 'Tarjeta',
        valor: r'$0',
        subtitulo: 'x',
        icon: Icons.credit_card,
        colorIcono: Colors.purple,
      ),
    ));

    final box = tester.getSize(find.byType(MetricaSecundariaCard));
    expect(box.height, 116);
  });

  testWidgets('trunca títulos largos con ellipsis', (tester) async {
    await tester.pumpWidget(wrap(
      SizedBox(
        width: 80,
        child: const MetricaSecundariaCard(
          titulo: 'Título extremadamente largo que no cabe',
          valor: r'$0',
          subtitulo: 'x',
          icon: Icons.abc,
          colorIcono: Colors.blue,
        ),
      ),
    ));

    final textWidget = tester.widget<Text>(find.text(
        'Título extremadamente largo que no cabe'));
    expect(textWidget.overflow, TextOverflow.ellipsis);
  });
}