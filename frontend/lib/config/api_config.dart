import 'package:flutter/foundation.dart';

/// IP del backend en la red local.
/// - Emulador AVD:  usa 10.0.2.2 (default) → mapea a localhost del host.
/// - Celular real:  pasa `--dart-define=BACKEND_HOST=<IP-LAN>` al compilar.
///   Ej: `flutter run --dart-define=BACKEND_HOST=192.168.1.81`.
///   El script `dev.sh` lo hace automáticamente.
const String _backendHost = String.fromEnvironment(
  'BACKEND_HOST',
  defaultValue: '10.0.2.2',
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
