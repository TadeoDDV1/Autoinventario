import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'config/api_config.dart';
import 'core/platform/sqlite_workaround_stub.dart'
    if (dart.library.io) 'core/platform/sqlite_workaround_io.dart';
import 'database/database_initializer.dart';
import 'database/database_provider.dart';
import 'providers/venta_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Workaround para abrir sqlite3 en Android viejo
  await applySqliteWorkaround();

  // Cargar configuración del backend (host/puerto desde SharedPreferences)
  await initApiConfig();

  // Sembrar BD con datos iniciales si está vacía (primer arranque)
  final container = ProviderContainer();
  final db = container.read(appDatabaseProvider);
  await DatabaseInitializer(db).initializeIfNeeded();

  await container.read(carritoProvider.notifier).loadFromStorage();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FerreteriaApp(),
    ),
  );
}
