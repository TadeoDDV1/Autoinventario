import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class DescripcionProducto {
  final String clave;
  final String descripcion;
  final List<String> usos;
  final List<String> compatibles;
  final List<String> sustitutos;

  const DescripcionProducto({
    required this.clave,
    required this.descripcion,
    this.usos = const [],
    this.compatibles = const [],
    this.sustitutos = const [],
  });
}

class ConocimientoFerreteria {
  static String _norm(String s) =>
      s.toLowerCase().replaceAllMapped(RegExp('[áéíóúñü]'), (m) {
        switch (m.group(0)) {
          case 'á': return 'a';
          case 'é': return 'e';
          case 'í': return 'i';
          case 'ó': return 'o';
          case 'ú': return 'u';
          case 'ñ': return 'n';
          case 'ü': return 'u';
        }
        return m.group(0)!;
      });

  static DescripcionProducto? buscarDescripcion(
      String nombreProducto, Map<String, dynamic> json) {
    if (nombreProducto.trim().isEmpty) return null;
    final productos = json['productos'];
    if (productos is! Map) return null;

    final nombreNorm = _norm(nombreProducto);
    String? mejorClave;
    int mejorLargo = 0;

    for (final entry in productos.entries) {
      final clave = entry.key;
      if (clave is! String) continue;
      final claveNorm = _norm(clave);
      if (nombreNorm.contains(claveNorm) && claveNorm.length > mejorLargo) {
        mejorClave = clave;
        mejorLargo = claveNorm.length;
      }
    }

    if (mejorClave == null) return null;
    final data = productos[mejorClave];
    if (data is! Map) return null;

    return DescripcionProducto(
      clave: mejorClave,
      descripcion: (data['descripcion'] as String?) ?? '',
      usos: ((data['usos'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(growable: false),
      compatibles: ((data['compatibles'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(growable: false),
      sustitutos: ((data['sustitutos'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(growable: false),
    );
  }

  static Future<Map<String, dynamic>> cargar() async {
    final raw =
        await rootBundle.loadString('assets/conocimiento_ferreteria.json');
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
