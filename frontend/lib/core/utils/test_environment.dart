import 'package:flutter/material.dart';

/// Detecta si la app está corriendo bajo `flutter test`.
///
/// Bajo tests, `WidgetsBinding.instance` es un binding cuyo runtimeType
/// contiene "Test" (p.ej. `AutomatedTestWidgetsFlutterBinding`). Esto
/// permite omitir comportamientos que intentan ganar foco/solicitar el
/// teclado (p.ej. autofocus del BarcodeInput) que dejan pendiente el
/// cursor parpadeante y hacen que `pumpAndSettle` nunca termine.
bool get isRunningTests =>
    WidgetsBinding.instance.runtimeType.toString().contains('Test');