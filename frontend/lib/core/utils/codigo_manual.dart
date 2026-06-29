import 'dart:math';

/// Genera un código interno aleatorio para alta rápida desde Caja.
///
/// Rango: **0–9999** (1-4 dígitos numéricos, sin padding forzado).
///
/// Ejemplos: `"42"`, `"789"`, `"1234"`, `"0"`.
///
/// Usado por:
/// - `AltaRapidaSheet` (B2): cuando el operador abre el alta rápida sin
///   haber escaneado un código (Ctrl+M, o banner post-scan sin código).
/// - En el futuro, `POST /productos/asignar-codigo` (B4) para asignar
///   un código interno a productos viejos que quedaron sin código de fábrica.
///
/// **Colisiones:** con 10000 valores posibles, para una tienda con <1000
/// productos la probabilidad de colisión por generación es <10%. Si el
/// backend rechaza con 409, `AltaRapidaSheet` regenera hasta 5 veces antes
/// de pedirle al operador que tipee un código manual.
///
/// **No usa `Random.secure()`** a propósito: el código no es un secreto
/// (cualquiera puede ver el código del producto en el carrito), y queremos
/// tests reproducibles con seeding cuando sea necesario.
String generarCodigoManualCaja() {
  return Random().nextInt(10000).toString();
}
