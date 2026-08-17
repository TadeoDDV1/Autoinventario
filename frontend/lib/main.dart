import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'app.dart';
import 'config/api_config.dart';
import 'database/app_database.dart';
import 'database/database_initializer.dart';
import 'providers/venta_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Workaround para abrir sqlite3 en Android viejo
  await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();

  // Cargar configuración del backend (host/puerto desde SharedPreferences)
  await initApiConfig();

  // Sembrar BD con datos iniciales si está vacía (primer arranque)
  final db = AppDatabase();
  await DatabaseInitializer(db).initializeIfNeeded();

  final container = ProviderContainer();
  await container.read(carritoProvider.notifier).loadFromStorage();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FerreteriaApp(),
    ),
  );
}
