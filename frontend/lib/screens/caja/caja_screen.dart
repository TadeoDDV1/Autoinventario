import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/durations.dart';
import '../../core/format/money.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/widgets/atmospheric_background.dart';
import '../../core/widgets/glass_container.dart';
import '../../models/producto.dart';
import '../../providers/producto_provider.dart';
import '../../providers/venta_provider.dart';
import '../../providers/ia_chat_bubble_provider.dart';
import '../../widgets/caja/alta_rapida_sheet.dart';
import '../../widgets/caja/barcode_input.dart';
import '../../widgets/caja/quick_cart_summary.dart';
import '../../widgets/ia/ia_chat_bubble.dart';

class _ClearCartIntent extends Intent {
  const _ClearCartIntent();
}

class _GoInventarioIntent extends Intent {
  const _GoInventarioIntent();
}

class _GoCajaIntent extends Intent {
  const _GoCajaIntent();
}

class _FocusInputIntent extends Intent {
  const _FocusInputIntent();
}

class _ToggleBubbleIntent extends Intent {
  const _ToggleBubbleIntent();
}

class _NuevoProductoIntent extends Intent {
  const _NuevoProductoIntent();
}

class _OpenPagoIntent extends Intent {
  const _OpenPagoIntent();
}

class _AltaRapidaIntent extends Intent {
  const _AltaRapidaIntent();
}

class CajaScreen extends ConsumerStatefulWidget {
  const CajaScreen({super.key});

  @override
  ConsumerState<CajaScreen> createState() => _CajaScreenState();
}

class _CajaScreenState extends ConsumerState<CajaScreen> {
  final FocusNode _shortcutFocus = FocusNode(debugLabel: 'CajaShortcuts');
  final FocusNode _inputFocus = FocusNode(debugLabel: 'CajaBarcodeInput');
  final GlobalKey<QuickCartSummaryState> _cartKey =
      GlobalKey<QuickCartSummaryState>();

  /// Bloque B — Task B3: código del último scan que NO se encontró. Mientras
  /// esté seteado, mostramos un banner arriba del BarcodeInput con CTA
  /// "Alta rápida" para que el operador pueda reintentar sin re-escanear.
  String? _ultimoCodigoNoRegistrado;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shortcutFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _shortcutFocus.dispose();
    _inputFocus.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  /// Bloque B — Task B3: setea el banner y arma un timer de auto-clear a 30s.
  void _setUltimoCodigoNoRegistrado(String codigo) {
    _bannerTimer?.cancel();
    setState(() => _ultimoCodigoNoRegistrado = codigo);
    _bannerTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() => _ultimoCodigoNoRegistrado = null);
      }
    });
  }

  /// Bloque B — Task B3: descarta el banner manualmente.
  void _limpiarUltimoCodigoNoRegistrado() {
    _bannerTimer?.cancel();
    if (_ultimoCodigoNoRegistrado != null) {
      setState(() => _ultimoCodigoNoRegistrado = null);
    }
  }

  void _onProductoScan(dynamic producto) {
    // B3: un scan exitoso limpia el banner de "no registrado".
    _limpiarUltimoCodigoNoRegistrado();
    ref.read(carritoProvider.notifier).agregarProducto(producto);
    _showSnackBar('${producto.nombre} agregado ✓', Colors.green);
  }

  void _onScanError(String mensaje) {
    _showSnackBar(mensaje, Colors.orange);
  }

  /// Bloque B — Task B1/B2/B3: el usuario escaneó/escribió un código que NO
  /// existe en el backend. Abre el `AltaRapidaSheet` como bottom sheet Y
  /// muestra un banner persistente por si el operador quiere reintentar
  /// el alta más tarde sin re-escanear.
  Future<void> _onProductoNoRegistrado(String codigo) async {
    _setUltimoCodigoNoRegistrado(codigo);
    final nuevo = await _abrirAltaRapida(codigo: codigo);
    if (nuevo != null && mounted) {
      // Alta exitosa → limpia el banner.
      _limpiarUltimoCodigoNoRegistrado();
    }
    // Si canceló, el banner persiste (Timer de 30s lo limpia solo).
  }

  /// Abre el sheet de alta rápida con un código inicial opcional.
  ///
  /// Usado por:
  /// - `_onProductoNoRegistrado(codigo)` cuando el barcode no encuentra
  ///   el producto (B1).
  /// - El atajo `Ctrl+M` para crear un producto nuevo sin escaneo previo.
  ///
  /// Devuelve el `Producto` creado si el alta fue exitosa, o `null` si el
  /// operador canceló el sheet (B3 usa esto para limpiar el banner).
  Future<Producto?> _abrirAltaRapida({String? codigo}) async {
    final nuevo = await showModalBottomSheet<Producto?>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AltaRapidaSheet(codigoInicial: codigo),
    );
    if (nuevo != null && mounted) {
      ref.read(carritoProvider.notifier).agregarProducto(nuevo);
      _showSnackBar('${nuevo.nombre} creado y agregado ✓', Colors.green);
    }
    return nuevo;
  }

  void _showSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        duration: AppDurations.snackbarMedium,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _nuevoProducto() {
    context.go('/inventario/nuevo');
  }

  void _abrirCobroRapido() {
    _cartKey.currentState?.abrirDialogoCobroRapido();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productosAsync = ref.watch(productosProvider);
    final carritoCantidad = ref.watch(carritoCantidadProvider);

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.escape): _ClearCartIntent(),
        const SingleActivator(LogicalKeyboardKey.keyI, control: true):
            _GoInventarioIntent(),
        const SingleActivator(LogicalKeyboardKey.keyC, control: true):
            _GoCajaIntent(),
        const SingleActivator(LogicalKeyboardKey.f1): _FocusInputIntent(),
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _ToggleBubbleIntent(),
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
            _NuevoProductoIntent(),
        const SingleActivator(LogicalKeyboardKey.keyP, control: true):
            _OpenPagoIntent(),
        // Bloque B — Task B2: alta rápida inline (3 campos) sin escanear.
        const SingleActivator(LogicalKeyboardKey.keyM, control: true):
            _AltaRapidaIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _ClearCartIntent: CallbackAction<_ClearCartIntent>(
            onInvoke: (_) {
              final carrito = ref.read(carritoProvider);
              if (carrito.isNotEmpty) {
                ref.read(carritoProvider.notifier).vaciar();
                _showSnackBar('Carrito limpiado', Colors.orange);
              }
              return null;
            },
          ),
          _GoInventarioIntent: CallbackAction<_GoInventarioIntent>(
            onInvoke: (_) {
              context.go('/inventario');
              return null;
            },
          ),
          _GoCajaIntent: CallbackAction<_GoCajaIntent>(
            onInvoke: (_) {
              context.go('/caja');
              return null;
            },
          ),
          _FocusInputIntent: CallbackAction<_FocusInputIntent>(
            onInvoke: (_) {
              _inputFocus.requestFocus();
              return null;
            },
          ),
          _ToggleBubbleIntent: CallbackAction<_ToggleBubbleIntent>(
            onInvoke: (_) {
              ref.read(burbujaExpandidaProvider.notifier).toggle();
              return null;
            },
          ),
          _NuevoProductoIntent: CallbackAction<_NuevoProductoIntent>(
            onInvoke: (_) {
              _nuevoProducto();
              return null;
            },
          ),
          _OpenPagoIntent: CallbackAction<_OpenPagoIntent>(
            onInvoke: (_) {
              _abrirCobroRapido();
              return null;
            },
          ),
          _AltaRapidaIntent: CallbackAction<_AltaRapidaIntent>(
            onInvoke: (_) {
              _abrirAltaRapida();
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _shortcutFocus,
          autofocus: true,
          child: _buildScaffold(theme, productosAsync, carritoCantidad),
        ),
      ),
    );
  }

  Widget _buildScaffold(
    ThemeData theme,
    AsyncValue productosAsync,
    int carritoCantidad,
  ) {
    final posicion = ref.watch(burbujaPosicionProvider);
    return Scaffold(
      body: Stack(
        children: [
          const AtmosphericBackground(),
          Column(
            children: [
              // Header con modo — glass
              GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                borderRadius: 0,
                blur: GlassTokens.blurSmall,
                child: Row(
                  children: [
                    Icon(
                      Icons.point_of_sale,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'MODO CAJA',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => context.go('/caja/historial'),
                      icon: Icon(
                        Icons.receipt_long,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                      label: Text(
                        'Historial',
                        style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
              // Contenido principal
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = Breakpoints.isDesktop(constraints.maxWidth);

                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildProductArea(
                              theme,
                              productosAsync,
                            ),
                          ),
                          Container(
                            width: 360,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              border: Border(
                                left: BorderSide(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                            ),
                            child: QuickCartSummary(
                              key: _cartKey,
                              onLimpiar: () =>
                                  ref.read(carritoProvider.notifier).vaciar(),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          Expanded(
                            child: _buildProductArea(
                              theme,
                              productosAsync,
                            ),
                          ),
                          if (carritoCantidad > 0)
                            QuickCartSummary(
                              key: _cartKey,
                              onLimpiar: () =>
                                  ref.read(carritoProvider.notifier).vaciar(),
                            ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          // Burbuja de IA flotante estilo Messenger
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            right: posicion == BurbujaPosicion.bottomRight ? 16 : null,
            left: posicion == BurbujaPosicion.bottomLeft ? 16 : null,
            child: const IaChatBubble(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductArea(
    ThemeData theme,
    AsyncValue productosAsync,
  ) {
    final carrito = ref.watch(carritoProvider);
    final formatter = money;

    return Column(
      children: [
        // Input de código de barras — STICKY en la parte superior (glass)
        GlassContainer(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          borderRadius: 0,
          blur: GlassTokens.blurSmall,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bloque B — Task B3: banner persistente tras scan fallido.
              if (_ultimoCodigoNoRegistrado != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
                  child: Material(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _abrirAltaRapida(codigo: _ultimoCodigoNoRegistrado),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Último código "${_ultimoCodigoNoRegistrado}" no registrado. ¿Agregarlo ahora?',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            FilledButton.tonal(
                              onPressed: () => _abrirAltaRapida(codigo: _ultimoCodigoNoRegistrado),
                              child: const Text('Alta rápida'),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              tooltip: 'Descartar',
                              onPressed: _limpiarUltimoCodigoNoRegistrado,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              BarcodeInput(
                onProductoEncontrado: _onProductoScan,
                onError: _onScanError,
                onProductoNoRegistrado: _onProductoNoRegistrado,
                externalFocusNode: _inputFocus,
              ),
            ],
          ),
        ),

        // Lista de productos escaneados en esta sesión
          Expanded(
            child: carrito.isEmpty
                ? Center(
                    child: GlassContainer(
                      padding: const EdgeInsets.all(32),
                      blur: GlassTokens.blurMedium,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 64,
                            color: theme.colorScheme.primary.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Escanea un producto',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Usa la cámara del celular,\nel lector de códigos, o escribe el código arriba',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => context.go('/inventario/escanear'),
                                icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                                label: const Text('Escanear nuevo'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => context.go('/inventario/nuevo'),
                                icon: const Icon(Icons.edit_note, size: 18),
                                label: const Text('Manual'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: carrito.length,
                  itemBuilder: (context, index) {
                    final item = carrito[index];
                    return GlassContainer(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      borderRadius: GlassTokens.borderRadiusSmall,
                      blur: GlassTokens.blurSmall,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${item.cantidad}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.producto.nombre,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  formatter.format(item.producto.precioVenta),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatter.format(item.subtotal),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
