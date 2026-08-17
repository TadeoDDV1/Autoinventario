import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracionApp {
  final int diasHistorialSync;
  final bool autoSyncOnConnect;

  const ConfiguracionApp({
    this.diasHistorialSync = 30,
    this.autoSyncOnConnect = true,
  });

  ConfiguracionApp copyWith({
    int? diasHistorialSync,
    bool? autoSyncOnConnect,
  }) {
    return ConfiguracionApp(
      diasHistorialSync: diasHistorialSync ?? this.diasHistorialSync,
      autoSyncOnConnect: autoSyncOnConnect ?? this.autoSyncOnConnect,
    );
  }
}

class ConfiguracionNotifier extends AsyncNotifier<ConfiguracionApp> {
  static const _kDiasHistorial = 'dias_historial_sync';
  static const _kAutoSync = 'auto_sync_on_connect';

  @override
  Future<ConfiguracionApp> build() async {
    final prefs = await SharedPreferences.getInstance();
    final dias = prefs.getInt(_kDiasHistorial) ?? 30;
    final autoSync = prefs.getBool(_kAutoSync) ?? true;
    return ConfiguracionApp(
      diasHistorialSync: dias,
      autoSyncOnConnect: autoSync,
    );
  }

  Future<void> setDiasHistorial(int dias) async {
    final current = state.value ?? const ConfiguracionApp();
    final updated = current.copyWith(diasHistorialSync: dias);
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDiasHistorial, dias);
  }

  Future<void> setAutoSync(bool value) async {
    final current = state.value ?? const ConfiguracionApp();
    final updated = current.copyWith(autoSyncOnConnect: value);
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoSync, value);
  }
}

final configuracionProvider =
    AsyncNotifierProvider<ConfiguracionNotifier, ConfiguracionApp>(
  ConfiguracionNotifier.new,
);
