import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/durations.dart';
import '../../core/format/money.dart';
import '../../core/layout/breakpoints.dart';
import '../../providers/producto_provider.dart';
import '../../providers/venta_provider.dart';
import '../../widgets/caja/barcode_input.dart';
import '../../widgets/caja/quick_cart_summary.dart';
import '../../widgets/ia/copilot_panel.dart';

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

class CajaScreen extends ConsumerStatefulWidget {
  const CajaScreen({super.key});

  @override
  ConsumerState<CajaScreen> createState() => _CajaScreenState();
}

class _CajaScreenState extends ConsumerState<CajaScreen> {
  final FocusNode _shortcutFocus = FocusNode(debugLabel: 'CajaShortcuts');
  final FocusNode _inputFocus = FocusNode(debugLabel: 'CajaBarcodeInput');

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
    super.dispose();
  }

  void _onProductoScan(dynamic producto) {
    ref.read(carritoProvider.notifier).agregarProducto(producto);
    _showSnackBar('${producto.nombre} agregado ✓', Colors.green);
  }

  void _onScanError(String mensaje) {
    _showSnackBar(mensaje, Colors.orange);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productosAsync = ref.watch(productosProvider);
    final carritoCantidad = ref.watch(carritoCantidadProvider);

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): _ClearCartIntent(),
        SingleActivator(LogicalKeyboardKey.keyI, control: true):
            _GoInventarioIntent(),
        SingleActivator(LogicalKeyboardKey.keyC, control: true):
            _GoCajaIntent(),
        SingleActivator(LogicalKeyboardKey.f1): _FocusInputIntent(),
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
    return Scaffold(
      body: Column(
        children: [
          // Header con modo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
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
                      // Área izquierda: búsqueda + grid
                      Expanded(
                        flex: 3,
                        child: _buildProductArea(
                          theme,
                          productosAsync,
                        ),
                      ),
                      // Área derecha: carrito resumido
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
                          onLimpiar: () =>
                              ref.read(carritoProvider.notifier).vaciar(),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Móvil: productos arriba, carrito abajo
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
        // Input de código de barras — STICKY en la parte superior
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: BarcodeInput(
            onProductoEncontrado: _onProductoScan,
            onError: _onScanError,
            externalFocusNode: _inputFocus,
          ),
        ),

        // Panel de sugerencias IA — aparece cuando hay items en el carrito
        const CopilotPanel(),

        // Lista de productos escaneados en esta sesión
        Expanded(
          child: carrito.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 80,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Escanea un producto',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Usa la cámara del celular,\nel lector de códigos, o escribe el código arriba',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
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
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.3),
                        ),
                      ),
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