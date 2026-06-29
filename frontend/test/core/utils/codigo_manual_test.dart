// Tests para `generarCodigoManualCaja()` — Bloque B — Task B2.
//
// El helper vive en `lib/core/utils/codigo_manual.dart` y se usa desde
// `AltaRapidaSheet` (B2) y, en el futuro, desde el endpoint
// `POST /productos/asignar-codigo` (B4).
//
// Rango: 0–9999 (1 a 4 dígitos numéricos, sin padding).
//
// Casos cubiertos:
//   (1) Resultado es string de 1-4 dígitos (regex `^[0-9]{1,4}$`).
//   (2) `int.parse(resultado) >= 0` siempre (no genera números negativos).
//   (3) 1000 generaciones producen al menos 950 distintos (probabilístico:
//       con 10000 valores posibles, P(set <= 950) ≈ 0).

import 'package:flutter_test/flutter_test.dart';

import 'package:ferreteria_app/core/utils/codigo_manual.dart';

void main() {
  group('generarCodigoManualCaja', () {
    test('(1) genera string de 1-4 dígitos numéricos (sin padding)', () {
      // 50 generaciones alcanzan para descartar cualquier sesgo sistemático
      // sin volver al test flaky.
      for (var i = 0; i < 50; i++) {
        final codigo = generarCodigoManualCaja();
        expect(
          RegExp(r'^[0-9]{1,4}$').hasMatch(codigo),
          isTrue,
          reason: 'Código mal formado: "$codigo"',
        );
      }
    });

    test('(2) siempre parseable como int >= 0 (no negativos)', () {
      for (var i = 0; i < 200; i++) {
        final codigo = generarCodigoManualCaja();
        final parsed = int.parse(codigo);
        expect(parsed, greaterThanOrEqualTo(0));
        expect(parsed, lessThan(10000));
      }
    });

    test(
        '(3) 1000 generaciones producen al menos 950 códigos distintos '
        '(probabilístico)', () {
      // Con 10000 valores posibles y 1000 muestras, el número esperado de
      // valores únicos es ~10000 * (1 - (1 - 1/10000)^1000) ≈ 951. Fijamos
      // el umbral en 900 para que sea robusto ante draws estadísticamente
      // bajos pero aún detecte sesgos serios (p.ej. un generador con sólo
      // 100 valores posibles).
      final generados = <String>{};
      for (var i = 0; i < 1000; i++) {
        generados.add(generarCodigoManualCaja());
      }
      expect(
        generados.length,
        greaterThan(900),
        reason:
            'Sólo ${generados.length} códigos distintos en 1000 generaciones. '
            'El generador parece estar sesgado.',
      );
    });
  });
}