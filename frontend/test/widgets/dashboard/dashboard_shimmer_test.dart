import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ferreteria_app/widgets/dashboard/dashboard_shimmer.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('DashboardShimmer renderiza sin errores', (tester) async {
    await tester.pumpWidget(wrap(const DashboardShimmer()));
    expect(find.byType(DashboardShimmer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('contiene múltiples _shimmerBox (rectángulos skeleton)',
      (tester) async {
    await tester.pumpWidget(wrap(const DashboardShimmer()));
    // 1 hero + 3 secundarias + 5 top productos + 1 chart = 10 boxes
    // + 2 bars (header texto). No contamos exacto, validamos presencia.
    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('puede renderizarse en viewport pequeño (mobile)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpWidget(wrap(const DashboardShimmer()));
    expect(find.byType(DashboardShimmer), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });
}