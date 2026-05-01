import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ferreteria_app/app.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FerreteriaApp()));
    expect(find.text('Inventario'), findsOneWidget);
  });
}
