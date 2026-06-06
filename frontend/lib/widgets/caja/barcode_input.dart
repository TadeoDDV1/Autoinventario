import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/durations.dart';
import '../../core/errors/api_exception.dart';
import '../../core/format/money.dart';
import '../../models/producto.dart';
import '../../providers/producto_provider.dart';
import 'barcode_scanner_button.dart';

/// Input para buscar productos por código de barras o nombre.
/// Compatible con:
///   - Pistola escáner HID (desktop) → caracteres rápidos + Enter
///   - Teclado virtual (móvil) → escribir + tap lupa
///   - Cámara (móvil) → botón scanner que abre bottom-sheet
class BarcodeInput extends ConsumerStatefulWidget {
  final Function(Producto producto) onProductoEncontrado;
  final Function(String mensaje) onError;

  const BarcodeInput({
    super.key,
    required this.onProductoEncontrado,
    required this.onError,
  });

  @override
  ConsumerState<BarcodeInput> createState() => _BarcodeInputState();
}

class _BarcodeInputState extends ConsumerState<BarcodeInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  bool _isLoading = false;
  List<Producto> _results = [];
  bool _showResults = false;

  // Estado para la "pestaña pequeña" de escaneo en móvil.
  // Cuando el usuario escanea, mostramos un toast flotante con la última captura.
  Producto? _ultimoEscaneo;
  Timer? _hideTimer;

  bool get _esMovil {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    // Solo autofocus en desktop (en móvil abre el teclado y estorba)
    if (!_esMovil) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _hideTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();

    if (value.trim().length < 2) {
      setState(() {
        _results = [];
        _showResults = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showResults = true;
    });

    _debounce = Timer(AppDurations.debounceSearch, () {
      _buscarCoincidencias(value.trim());
    });
  }

  Future<void> _buscarCoincidencias(String query) async {
    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.getProductos(
        search: query,
        pageSize: ApiConstants.searchPageSize,
      );
      if (mounted) {
        setState(() {
          _results = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _results = [];
        });
      }
    }
  }

  Future<void> _onSubmit(String codigo) async {
    if (codigo.trim().isEmpty) return;

    _debounce?.cancel();
    setState(() {
      _showResults = false;
      _isLoading = true;
    });

    try {
      final api = ref.read(apiServiceProvider);
      final producto = await api.buscarPorCodigo(codigo.trim());

      if (producto != null) {
        _onProductoEncontradoConFeedback(producto);
      } else {
        widget.onError('Producto no encontrado: $codigo');
        setState(() => _isLoading = false);
      }
    } on ApiException catch (e) {
      widget.onError('Error al buscar: ${e.message}');
      setState(() => _isLoading = false);
    } catch (e) {
      widget.onError('Error al buscar: $e');
      setState(() => _isLoading = false);
    }

    if (mounted && !_esMovil) {
      _focusNode.requestFocus();
    }
  }

  void _onProductoEncontradoConFeedback(Producto producto) {
    widget.onProductoEncontrado(producto);
    _controller.clear();
    setState(() {
      _results = [];
      _showResults = false;
      _isLoading = false;
      _ultimoEscaneo = producto;
    });
    _hideTimer?.cancel();
    _hideTimer = Timer(AppDurations.feedbackToast, () {
      if (mounted) {
        setState(() => _ultimoEscaneo = null);
      }
    });
  }

  void _onSelectProducto(Producto producto) {
    _onProductoEncontradoConFeedback(producto);
  }

  /// Handler cuando se escanea con la cámara
  void _onScanCamara(Producto producto) {
    if (mounted) {
      _focusNode.unfocus();
    }
    _onProductoEncontradoConFeedback(producto);
  }

  void _onScanCamaraError(String mensaje) {
    widget.onError(mensaje);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Fila principal: input + botón cámara (en móvil)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.qr_code_scanner,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: _esMovil
                            ? 'Toca el ícono de cámara o escribe...'
                            : 'Escanea o escribe el código/nombre...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textInputAction: TextInputAction.search,
                      onChanged: _onTextChanged,
                      onSubmitted: _onSubmit,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (_controller.text.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _results = [];
                          _showResults = false;
                        });
                      },
                      icon: const Icon(Icons.close, size: 20),
                      tooltip: 'Limpiar',
                    )
                  else
                    IconButton(
                      onPressed: () => _onSubmit(_controller.text),
                      icon: Icon(
                        Icons.search,
                        color: theme.colorScheme.primary,
                      ),
                      tooltip: 'Buscar',
                    ),
                  // Botón cámara (solo móvil)
                  if (_esMovil) ...[
                    const SizedBox(width: 4),
                    BarcodeScannerButton(
                      onProductoEncontrado: _onScanCamara,
                      onError: _onScanCamaraError,
                    ),
                  ],
                ],
              ),
            ),

            // Resultados de búsqueda (debajo del input)
            if (_showResults && (_results.isNotEmpty || _isLoading))
              Container(
                margin: const EdgeInsets.only(top: 4),
                constraints: const BoxConstraints(maxHeight: 280),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: theme.colorScheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _results.isEmpty && _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final producto = _results[index];
                          return InkWell(
                            onTap: () => _onSelectProducto(producto),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.inventory_2,
                                      size: 20,
                                      color: theme
                                          .colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          producto.nombre,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          producto.codigoBarras ?? '',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    money.format(producto.precioVenta),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),

        // PESTAÑA PEQUEÑA FLOTANTE — feedback del último escaneo
        if (_ultimoEscaneo != null)
          Positioned(
            top: -8,
            right: 0,
            child: _MiniScanToast(
              producto: _ultimoEscaneo!,
              onDismiss: () {
                _hideTimer?.cancel();
                setState(() => _ultimoEscaneo = null);
              },
            ),
          ),
      ],
    );
  }
}

/// Mini tarjeta flotante que aparece tras un escaneo exitoso.
/// Muestra: ✓ + nombre del producto + precio, en una pill compacta.
class _MiniScanToast extends StatelessWidget {
  final Producto producto;
  final VoidCallback onDismiss;

  const _MiniScanToast({required this.producto, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '${producto.nombre} • ${money.format(producto.precioVenta)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onDismiss,
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
