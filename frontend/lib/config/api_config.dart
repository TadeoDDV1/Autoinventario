import 'package:flutter/foundation.dart';

/// IP del backend en la red local.
/// El celular real NO puede usar 10.0.2.2 (eso es solo para emulador AVD).
/// Cambia esto si tu compu tiene otra IP en la red.
const String _backendHost = String.fromEnvironment(
  'BACKEND_HOST',
  defaultValue: '172.44.30.9',
);
const int _backendPort = 8080;

String get apiBaseUrl {
  if (kIsWeb) {
    return 'http://localhost:$_backendPort/api/v1';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://$_backendHost:$_backendPort/api/v1';
    case TargetPlatform.iOS:
      return 'http://localhost:$_backendPort/api/v1';
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
      return 'http://localhost:$_backendPort/api/v1';
    case TargetPlatform.fuchsia:
      return 'http://localhost:$_backendPort/api/v1';
  }
}
