import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ferreteria_app/app.dart';
import 'package:ferreteria_app/core/format/money.dart';
import 'package:ferreteria_app/core/layout/breakpoints.dart';
import 'package:ferreteria_app/domain/enums.dart';
import 'package:ferreteria_app/models/paginated_response.dart';
import 'package:ferreteria_app/models/producto.dart';
import 'package:ferreteria_app/models/categoria.dart';
import 'package:ferreteria_app/providers/producto_provider.dart';

void main() {
  group('Core utilities', () {
    test('money formatter is configured for MXN-style currency', () {
      expect(money.currencySymbol, r'$');
      expect(money.minimumFractionDigits, 2);
    });

    test('Breakpoints classify widths correctly', () {
      expect(Breakpoints.isMobile(400), isTrue);
      expect(Breakpoints.isTablet(700), isTrue);
      expect(Breakpoints.isDesktop(1024), isTrue);
      expect(Breakpoints.isDesktop(900), isTrue);
      expect(Breakpoints.isDesktop(500), isFalse);
    });

    test('MetodoPago parses backend string', () {
      expect(MetodoPago.fromString('efectivo'), MetodoPago.efectivo);
      expect(MetodoPago.fromString('tarjeta'), MetodoPago.tarjeta);
      expect(MetodoPago.fromString('desconocido'), MetodoPago.efectivo);
    });
  });

  testWidgets('App renders MaterialApp shell', (WidgetTester tester) async {
    final emptyProductos = PaginatedResponse<Producto>(
      data: const [],
      total: 0,
      page: 1,
      pageSize: 20,
      totalPages: 0,
    );
    final emptyCategorias = <Categoria>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productosProvider.overrideWith(() => _FakeProductosNotifier(emptyProductos)),
          categoriasProvider.overrideWith(() => _FakeCategoriasNotifier(emptyCategorias)),
        ],
        child: const FerreteriaApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

class _FakeProductosNotifier extends ProductosNotifier {
  final PaginatedResponse<Producto> _value;
  _FakeProductosNotifier(this._value);
  @override
  Future<PaginatedResponse<Producto>> build() async => _value;
}

class _FakeCategoriasNotifier extends CategoriasNotifier {
  final List<Categoria> _value;
  _FakeCategoriasNotifier(this._value);
  @override
  Future<List<Categoria>> build() async => _value;
}
