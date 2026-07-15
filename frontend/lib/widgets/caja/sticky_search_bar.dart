import 'package:flutter/material.dart';
import '../../models/producto.dart';
import 'barcode_input.dart';

/// Sección sticky superior con el input de búsqueda.
///
/// Layout:
/// ```text
/// ┌──────────────────────────────────────────┐
/// │ [icono qr]  [TextField    ] [scan][close]│  ← surfaceContainerLow
/// └──────────────────────────────────────────┘  ← border-bottom outlineVariant
/// ```
///
/// Apoyado sobre `BarcodeInput` (sin glass, sin blur). Misma API:
///   - `onProductoEncontrado` cuando un código/nombre matchea.
///   - `onProductoNoRegistrado` cuando el código no existe (abre Alta rápida).
///   - `onError` para feedback genérico.
class StickySearchBar extends StatelessWidget {
  final void Function(Producto producto) onProductoEncontrado;
  final void Function(String mensaje) onError;
  final void Function(String codigo) onProductoNoRegistrado;
  final FocusNode? externalFocusNode;

  const StickySearchBar({
    super.key,
    required this.onProductoEncontrado,
    required this.onError,
    required this.onProductoNoRegistrado,
    this.externalFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: BarcodeInput(
            onProductoEncontrado: onProductoEncontrado,
            onError: onError,
            onProductoNoRegistrado: onProductoNoRegistrado,
            externalFocusNode: externalFocusNode,
          ),
        ),
      ),
    );
  }
}
