// Tests para la lógica de búsqueda de descripciones en el JSON de conocimiento.
//
// El JSON tiene este formato:
// {
//   "productos": {
//     "taladro": { "descripcion": "...", "usos": [...], "compatibles": [...], "sustitutos": [...] },
//     "martillo": { ... },
//     ...
//   },
//   "categorias": { ... }
// }
//
// La búsqueda es difusa por palabras: si el nombre del producto contiene
// cualquiera de las claves del JSON (case-insensitive, sin acentos), devolvemos
// la descripción de esa clave.

import 'package:flutter_test/flutter_test.dart';
import 'package:ferreteria_app/widgets/inventario/uso_tooltip.dart';

void main() {
  group('ConocimientoFerreteria.buscarDescripcion', () {
    final json = {
      'productos': {
        'taladro': {
          'descripcion': 'Herramienta eléctrica para perforar o atornillar.',
          'usos': ['perforar concreto', 'atornillar'],
        },
        'martillo': {
          'descripcion': 'Herramienta manual para clavar.',
          'usos': ['clavar clavos'],
        },
        'cinta métrica': {
          'descripcion': 'Instrumento de medición flexible.',
        },
      },
    };

    test('devuelve descripción cuando el nombre coincide exacto', () {
      final r = ConocimientoFerreteria.buscarDescripcion('Taladro', json);
      expect(r, isNotNull);
      expect(r!.descripcion,
          'Herramienta eléctrica para perforar o atornillar.');
      expect(r.usos, contains('perforar concreto'));
    });

    test('es case-insensitive', () {
      final r = ConocimientoFerreteria.buscarDescripcion('TALADRO', json);
      expect(r, isNotNull);
      expect(r!.descripcion, contains('perforar'));
    });

    test('ignora acentos en el nombre del producto', () {
      // "Martillo" sin acento, "martillo" con acento en la clave
      final jsonConAcento = {
        'productos': {
          'martíllo': {'descripcion': 'Con acento'},
        },
      };
      final r = ConocimientoFerreteria.buscarDescripcion(
          'martillo', jsonConAcento);
      expect(r, isNotNull);
    });

    test('coincide por palabra contenida en el nombre', () {
      // "Taladro inalámbrico Makita" debe matchear con "taladro"
      final r = ConocimientoFerreteria.buscarDescripcion(
          'Taladro inalámbrico Makita 18V', json);
      expect(r, isNotNull);
      expect(r!.descripcion, contains('perforar'));
    });

    test('devuelve null si no hay coincidencia', () {
      final r = ConocimientoFerreteria.buscarDescripcion(
          'Aspersor de jardín', json);
      expect(r, isNull);
    });

    test('devuelve null si el JSON no tiene productos', () {
      final r = ConocimientoFerreteria.buscarDescripcion(
          'Taladro', {'categorias': {}});
      expect(r, isNull);
    });

    test('maneja nombre vacío sin crashear', () {
      final r = ConocimientoFerreteria.buscarDescripcion('', json);
      expect(r, isNull);
    });

    test('preferencia: match más largo gana (taladro vs taladro percutor)', () {
      final jsonConDos = {
        'productos': {
          'taladro': {'descripcion': 'Genérico'},
          'taladro percutor': {'descripcion': 'Con percusión'},
        },
      };
      final r = ConocimientoFerreteria.buscarDescripcion(
          'Taladro percutor Bosch', jsonConDos);
      expect(r, isNotNull);
      expect(r!.descripcion, 'Con percusión');
    });

    test('incluye compatibles y sustitutos cuando están en el JSON', () {
      final jsonCompleto = {
        'productos': {
          'taladro': {
            'descripcion': 'Perfora y atornilla.',
            'compatibles': ['broca', 'cinta métrica'],
            'sustitutos': ['rotomartillo'],
          },
        },
      };
      final r = ConocimientoFerreteria.buscarDescripcion(
          'Taladro', jsonCompleto);
      expect(r, isNotNull);
      expect(r!.compatibles, contains('broca'));
      expect(r.sustitutos, contains('rotomartillo'));
    });
  });
}
