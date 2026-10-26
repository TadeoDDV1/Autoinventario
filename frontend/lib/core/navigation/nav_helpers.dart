import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Helpers de navegación para convivir con el `ShellRoute`.
///
/// Regla de oro del proyecto (ver `config/routes.dart`):
///
/// * Las rutas **del shell** (`/caja`, `/dashboard`, `/inventario`,
///   `/inventario/predicciones`) se cambian con [goShell] — reemplazan el
///   contenido del shell y mantienen visible la navegación.
/// * Las rutas **overlay** (`/caja/ticket`, `/caja/historial`,
///   `/inventario/nuevo`, `/inventario/editar/:id`, `/configuracion`, ...)
///   son rutas raíz que cubren el shell: se abren con `context.push(...)` y
///   se cierran con [popOrGo].
///
/// Un error histórico: declarar los overlays como rutas HIJAS del ShellRoute
/// con `parentNavigatorKey: _rootNavigatorKey`. Con esa configuración, `go()`
/// montaba el widget dos veces (como `child` del shell y como página del
/// navigator raíz) y Flutter estallaba con
/// *"Multiple widgets used the same GlobalKey"*, dejando la pantalla en negro.

/// Cierra la página actual si fue abierta con `push`.
///
/// Si no hay nada que desapilar (la página es la raíz del stack, p. ej. al
/// recargar el navegador directamente en `/caja/historial`), cae a [fallback]
/// con `go` para no dejar al usuario atrapado.
void popOrGo(BuildContext context, String fallback) {
  final router = GoRouter.of(context);
  if (router.canPop()) {
    router.pop();
  } else {
    router.go(fallback);
  }
}

/// Reemplaza la página actual por [location] (útil para "siguiente paso"
/// dentro de un flujo overlay: escanear -> editar, nuevo -> nuevo-rapido).
///
/// Así el botón de regresar del destino vuelve al origen del flujo, no a la
/// pantalla intermedia que ya no aporta.
void replaceWith(BuildContext context, String location) {
  GoRouter.of(context).pushReplacement(location);
}

/// Navega al home del shell sin dejar pilas colgadas.
void goShell(BuildContext context, String location) {
  GoRouter.of(context).go(location);
}
