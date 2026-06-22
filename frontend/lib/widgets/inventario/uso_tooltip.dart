import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Resultado de buscar la descripción de un producto en el JSON de conocimiento.
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

/// Lógica de búsqueda en el JSON de conocimiento de ferretería.
///
/// Es **case-insensitive** y **sin acentos**: el nombre del producto
/// "Taladro Inalámbrico" matchea con la clave "taladro" del JSON.
class ConocimientoFerreteria {
  /// Quita acentos y pasa a minúsculas.
  static String _norm(String s) =>
      s.toLowerCase().replaceAllMapped(RegExp('[áéíóúñü]'), (m) {
        switch (m.group(0)) {
          case 'á':
            return 'a';
          case 'é':
            return 'e';
          case 'í':
            return 'i';
          case 'ó':
            return 'o';
          case 'ú':
            return 'u';
          case 'ñ':
            return 'n';
          case 'ü':
            return 'u';
        }
        return m.group(0)!;
      });

  /// Busca la mejor coincidencia para [nombreProducto] en el JSON.
  ///
  /// Estrategia: recorre todas las claves de `productos`, normaliza, y se queda
  /// con la coincidencia **más larga** (para que "taladro percutor" gane sobre
  /// "taladro" cuando ambas existen).
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

  /// Carga el JSON embebido en `assets/conocimiento_ferreteria.json`.
  static Future<Map<String, dynamic>> cargar() async {
    final raw =
        await rootBundle.loadString('assets/conocimiento_ferreteria.json');
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}

/// Botón con icono de "info" que al presionarlo muestra un bottom-sheet con la
/// descripción de uso del producto (lee del JSON de conocimiento).
///
/// Diseñado para colocarse en la lista de inventario junto a cada producto.
class UsoTooltipButton extends StatelessWidget {
  final String nombreProducto;
  final String? categoriaNombre;

  const UsoTooltipButton({
    super.key,
    required this.nombreProducto,
    this.categoriaNombre,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info_outline, size: 20),
      tooltip: 'Ver para qué sirve',
      onPressed: () => mostrar(context),
    );
  }

  Future<void> mostrar(BuildContext context) async {
    final json = await ConocimientoFerreteria.cargar();
    if (!context.mounted) return;
    final desc = ConocimientoFerreteria.buscarDescripcion(nombreProducto, json);
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: _ContenidoTooltip(
            nombreProducto: nombreProducto,
            categoriaNombre: categoriaNombre,
            descripcion: desc,
          ),
        ),
      ),
    );
  }
}

class _ContenidoTooltip extends StatelessWidget {
  final String nombreProducto;
  final String? categoriaNombre;
  final DescripcionProducto? descripcion;

  const _ContenidoTooltip({
    required this.nombreProducto,
    required this.categoriaNombre,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = descripcion;
    if (d == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(nombreProducto, style: theme.textTheme.titleLarge),
          if (categoriaNombre != null) ...[
            const SizedBox(height: 4),
            Text(
              categoriaNombre!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'No hay información de uso en el catálogo de ferretería para este producto. '
            'Pídele a tu supervisor que lo agregue al conocimiento o sigue con la venta.',
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(nombreProducto, style: theme.textTheme.titleLarge),
        if (categoriaNombre != null) ...[
          const SizedBox(height: 4),
          Text(
            categoriaNombre!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(d.descripcion, style: theme.textTheme.bodyLarge),
        if (d.usos.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Usos comunes',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          ...d.usos.map(
            (u) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(u)),
                ],
              ),
            ),
          ),
        ],
        if (d.compatibles.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Productos compatibles',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: d.compatibles
                .map(
                  (c) => Chip(
                    label: Text(c),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
        ],
        if (d.sustitutos.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Sustitutos',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: d.sustitutos
                .map(
                  (s) => Chip(
                    label: Text(s),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
