import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ferreteria_app/widgets/dashboard/variacion_badge.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('VariacionBadge — tres estados', () {
    testWidgets('positivo: pct > 0 → trending_up y prefijo +', (tester) async {
      await tester.pumpWidget(wrap(
        const VariacionBadge(variacionPct: 12.3),
      ));
      expect(find.text('+12.3% vs ayer'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsNothing);
    });

    testWidgets('negativo: pct < 0 → trending_down y sin prefijo', (tester) async {
      await tester.pumpWidget(wrap(
        const VariacionBadge(variacionPct: -5.7),
      ));
      expect(find.text('-5.7% vs ayer'), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
    });

    testWidgets('neutro: pct == 0 → trending_flat y label "Sin variación"',
        (tester) async {
      await tester.pumpWidget(wrap(
        const VariacionBadge(variacionPct: 0),
      ));
      expect(find.text('Sin variación vs ayer'), findsOneWidget);
      expect(find.byIcon(Icons.trending_flat), findsOneWidget);
    });
  });

  testWidgets('onTap dispara callback', (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(
      VariacionBadge(
        variacionPct: 10,
        onTap: () => taps++,
      ),
    ));
    await tester.tap(find.byType(VariacionBadge));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('formatea con 1 decimal', (tester) async {
    await tester.pumpWidget(wrap(
      const VariacionBadge(variacionPct: 7.456),
    ));
    expect(find.text('+7.5% vs ayer'), findsOneWidget);
  });
}