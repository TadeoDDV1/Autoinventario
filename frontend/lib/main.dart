import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'providers/venta_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  // Cargar carrito desde storage ANTES de runApp para evitar race conditions
  // donde el usuario agrega items antes de que se hidrate el storage.
  await container.read(carritoProvider.notifier).loadFromStorage();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FerreteriaApp(),
    ),
  );
}
