import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/durations.dart';
import '../../core/format/money.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/widgets/atmospheric_background.dart';
import '../../models/producto.dart';
import '../../providers/producto_provider.dart';
import '../../providers/venta_provider.dart';
import '../../providers/ia_chat_bubble_provider.dart';
import '../../widgets/caja/alta_rapida_sheet.dart';
import '../../widgets/caja/product_tile.dart';
import '../../widgets/caja/quick_cart_summary.dart';
import '../../widgets/caja/sticky_search_bar.dart';
import '../../widgets/common/sync_button.dart';
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

  void _setUltimoCodigoNoRegistrado(String codigo) {
    _bannerTimer?.cancel();
    setState(() => _ultimoCodigoNoRegistrado = codigo);
    _bannerTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() => _ultimoCodigoNoRegistrado = null);
      }
    });
  }

  void _limpiarUltimoCodigoNoRegistrado() {
    _bannerTimer?.cancel();
    if (_ultimoCodigoNoRegistrado != null) {
      setState(() => _ultimoCodigoNoRegistrado = null);
    }
  }

  void _onProductoScan(dynamic producto) {
    _limpiarUltimoCodigoNoRegistrado();
    ref.read(carritoProvider.notifier).agregarProducto(producto);
    _showSnackBar('${producto.nombre} agregado ��', Colors.green);
  }

  void _onScanError(String mensaje) {
    _showSnackBar(mensaje, Colors.orange);
  }

  Future<void> _onProductoNoRegistrado(String codigo) async {
    _setUltimoCodigoNoRegistrado(codigo);
    final nuevo = await _abrirAltaRapida(codigo: codigo);
    if (nuevo != null && mounted) {
      _limpiarUltimoCodigoNoRegistrado();
    }
  }

  Future<Producto?> _abrirAltaRapida({String? codigo}) async {
    final nuevo = await showModalBottomSheet<Producto?>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AltaRapidaSheet(codigoInicial: codigo),
    );
    if (nuevo != null && mounted) {
      ref.read(carritoProvider.notifier).agregarProducto(nuevo);
      _showSnackBar('${nuevo.nombre} creado y agregado ��', Colors.green);
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
    // Ruta overlay: push, no go (ver nav_helpers.dart).
    context.push('/inventario/nuevo');
  }

  void _abrirCobroRapido() {
    _cartKey.currentState?.abrirDialogoCobroRapido();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productosAsync = ref.watch(productosProvider);

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
          child: _buildScaffold(theme, productosAsync),
        ),
      ),
    );
  }

  Widget _buildScaffold(
    ThemeData theme,
    AsyncValue productosAsync,
  ) {
    final posicion = ref.watch(burbujaPosicionProvider);
    final esActivo = ref.watch(burbujaActivaProvider);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          const AtmosphericBackground(),
          Column(
            children: [
              _buildHeader(theme),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = Breakpoints.isDesktop(constraints.maxWidth);

                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildProductAreaDesktop(
                              theme,
                              productosAsync,
                            ),
                          ),
                          Container(
                            width: 360,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHigh,
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
                    }
                    return _buildMobileLayout(theme, productosAsync);
                  },
                ),
              ),
            ],
          ),
          if (esActivo)
            Positioned(
              top: posicion.y,
              left: posicion.x,
              child: IaChatBubble(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.point_of_sale,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'MODO CAJA',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 12),
              const SyncChip(),
              const Spacer(),
Container(
                 padding: const EdgeInsets.symmetric(vertical: 4),
                 child: TextButton.icon(
                   // Ruta overlay: push, no go (ver nav_helpers.dart).
                   onPressed: () => context.push('/caja/historial'),
                   icon: const Icon(Icons.receipt_long, size: 20),
                   label: const Text('Historial'),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme, AsyncValue productosAsync) {
    // CustomScrollView: si la ventana es baja, searchbar + grid + carrito
    // hacen scroll en conjunto (evita RenderFlex overflow).
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: StickySearchBar(
            onProductoEncontrado: _onProductoScan,
            onError: _onScanError,
            onProductoNoRegistrado: _onProductoNoRegistrado,
            externalFocusNode: _inputFocus,
          ),
        ),
        if (_ultimoCodigoNoRegistrado != null)
          SliverToBoxAdapter(
            child: _NoRegistradoBanner(
              codigo: _ultimoCodigoNoRegistrado!,
              onTapAlta: () =>
                  _abrirAltaRapida(codigo: _ultimoCodigoNoRegistrado),
              onDismiss: _limpiarUltimoCodigoNoRegistrado,
            ),
          ),
        ..._buildProductGridSlivers(productosAsync),
        SliverToBoxAdapter(
          child: QuickCartSummary(
            key: _cartKey,
            onLimpiar: () => ref.read(carritoProvider.notifier).vaciar(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductAreaDesktop(
    ThemeData theme,
    AsyncValue productosAsync,
  ) {
    final carrito = ref.watch(carritoProvider);
    final formatter = money;
    return Column(
      children: [
        StickySearchBar(
          onProductoEncontrado: _onProductoScan,
          onError: _onScanError,
          onProductoNoRegistrado: _onProductoNoRegistrado,
          externalFocusNode: _inputFocus,
        ),
        if (_ultimoCodigoNoRegistrado != null)
          _NoRegistradoBanner(
            codigo: _ultimoCodigoNoRegistrado!,
            onTapAlta: () => _abrirAltaRapida(codigo: _ultimoCodigoNoRegistrado),
            onDismiss: _limpiarUltimoCodigoNoRegistrado,
          ),
        Expanded(
          child: carrito.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 64,
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.6),
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
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: carrito.length,
                  itemBuilder: (context, index) {
                    final item = carrito[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
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
                                  color: theme.colorScheme.onPrimaryContainer,
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
                                      color: theme.colorScheme.onSurfaceVariant,
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
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<Widget> _buildProductGridSlivers(AsyncValue productosAsync) {
    final theme = Theme.of(context);
    return [
      productosAsync.when(
        data: (paginated) {
          final productos = paginated.data;
          if (productos.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 40,
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escanea un producto',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Usa la cámara del celular,\nel lector de códigos, o escribe el código arriba',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 1.3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => ProductTile(producto: productos[index]),
                childCount: productos.length,
              ),
            ),
          );
        },
        loading: () => const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (e, _) => SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Error al cargar productos: $e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ];
  }
}

class _NoRegistradoBanner extends StatelessWidget {
  final String codigo;
  final VoidCallback onTapAlta;
  final VoidCallback onDismiss;

  const _NoRegistradoBanner({
    required this.codigo,
    required this.onTapAlta,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: theme.colorScheme.onErrorContainer,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Código "$codigo" no registrado',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            FilledButton.tonal(
              onPressed: onTapAlta,
              child: const Text('Alta rápida'),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              tooltip: 'Descartar',
              color: theme.colorScheme.onErrorContainer,
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
