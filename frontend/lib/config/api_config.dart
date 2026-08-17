import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _defaultBackendHost = '10.0.2.2';
const int _defaultBackendPort = 8080;

const String _prefsKeyHost = 'backend_host';
const String _prefsKeyPort = 'backend_port';

/// Obtiene el host del backend.
/// Primero intenta SharedPreferences; si no hay valor guardado, usa el default.
Future<String> _getHost() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKeyHost) ?? _defaultBackendHost;
  } catch (_) {
    return _defaultBackendHost;
  }
}

/// Obtiene el puerto del backend desde SharedPreferences.
Future<int> _getPort() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefsKeyPort) ?? _defaultBackendPort;
  } catch (_) {
    return _defaultBackendPort;
  }
}

/// URL base de la API (async — lee de SharedPreferences).
Future<String> get apiBaseUrl async {
  if (kIsWeb) {
    return 'http://localhost:$_defaultBackendPort/api/v1';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      final host = await _getHost();
      final port = await _getPort();
      return 'http://$host:$port/api/v1';
    default:
      return 'http://localhost:$_defaultBackendPort/api/v1';
  }
}

/// URL base síncrona que usa el valor cacheado en memoria.
/// Se debe llamar después de [initApiConfig].
late String apiBaseUrlSync;

/// Inicializa la URL base cacheada. Llamar al inicio de la app.
Future<void> initApiConfig() async {
  apiBaseUrlSync = await apiBaseUrl;
}

/// Guarda la configuración del backend y actualiza la URL cacheada.
Future<void> saveApiConfig({required String host, required int port}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_prefsKeyHost, host);
  await prefs.setInt(_prefsKeyPort, port);
  apiBaseUrlSync = 'http://$host:$port/api/v1';
}

/// Obtiene el host actual guardado (o el default).
Future<String> getSavedHost() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKeyHost) ?? _defaultBackendHost;
  } catch (_) {
    return _defaultBackendHost;
  }
}

/// Obtiene el puerto actual guardado (o el default).
Future<int> getSavedPort() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefsKeyPort) ?? _defaultBackendPort;
  } catch (_) {
    return _defaultBackendPort;
  }
}
