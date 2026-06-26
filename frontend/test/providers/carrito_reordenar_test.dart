// Tests del método CarritoNotifier.reordenar.
//
// El algoritmo sigue la convención de ReorderableListView:
// - oldIndex: posición actual del item.
// - newIndex: posición destino DESPUÉS de remover el item del array original.
//   Cuando newIndex > oldIndex, el framework de Flutter ya decrementa 1.
//   El notifier detecta esto y resta 1 internamente para reinsertar en la
//   posición lógica correcta.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ferreteria_app/models/producto.dart';
import 'package:ferreteria_app/providers/venta_provider.dart';

Producto _prod(int id, String nombre) => Producto(
      id: id,
      nombre: nombre,
      precioCompra: 10,
      precioVenta: 20,
      stockActual: 100,
      stockMinimo: 5,
      activo: true,
    );

void main() {
  group('CarritoNotifier.reordenar', () {
    test('mueve item de posición 0 al final (hacia adelante)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(carritoProvider.notifier);
      notifier.agregarProducto(_prod(1, 'Tornillo'));
      notifier.agregarProducto(_prod(2, 'Martillo'));
      notifier.agregarProducto(_prod(3, 'Taladro'));

      notifier.reordenar(0, 3);

      final carrito = container.read(carritoProvider);
      expect(carrito.map((i) => i.producto.id).toList(), [2, 3, 1]);
    });

    test('mueve item de posición 2 a posición 0 (hacia atrás)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(carritoProvider.notifier);
      notifier.agregarProducto(_prod(1, 'Tornillo'));
      notifier.agregarProducto(_prod(2, 'Martillo'));
      notifier.agregarProducto(_prod(3, 'Taladro'));

      notifier.reordenar(2, 0);

      final carrito = container.read(carritoProvider);
      expect(carrito.map((i) => i.producto.id).toList(), [3, 1, 2]);
    });

    test('swap de dos items consecutivos', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(carritoProvider.notifier);
      notifier.agregarProducto(_prod(1, 'A'));
      notifier.agregarProducto(_prod(2, 'B'));
      notifier.agregarProducto(_prod(3, 'C'));

      notifier.reordenar(0, 2);

      final carrito = container.read(carritoProvider);
      expect(carrito.map((i) => i.producto.id).toList(), [2, 1, 3]);
    });

    test('oldIndex == newIndex no hace nada (no-op)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(carritoProvider.notifier);
      notifier.agregarProducto(_prod(1, 'A'));
      notifier.agregarProducto(_prod(2, 'B'));

      notifier.reordenar(1, 1);

      final carrito = container.read(carritoProvider);
      expect(carrito.map((i) => i.producto.id).toList(), [1, 2]);
    });

    test('índices fuera de rango son no-op (no lanzan)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(carritoProvider.notifier);
      notifier.agregarProducto(_prod(1, 'A'));

      expect(() => notifier.reordenar(5, 0), returnsNormally);
      expect(() => notifier.reordenar(-1, 0), returnsNormally);
      expect(container.read(carritoProvider).length, 1);
    });
  });
}