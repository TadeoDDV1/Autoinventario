import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/durations.dart';
import '../../core/errors/api_exception.dart';
import '../../core/format/money.dart';
import '../../models/venta.dart';
import '../../providers/producto_provider.dart';
import '../../providers/venta_provider.dart';

enum CartPanelState { cart, completado }

class QuickCartSummary extends ConsumerStatefulWidget {
  final VoidCallback onLimpiar;

  const QuickCartSummary({
    super.key,
    required this.onLimpiar,
  });

  @override
  ConsumerState<QuickCartSummary> createState() => _QuickCartSummaryState();
}

class _QuickCartSummaryState extends ConsumerState<QuickCartSummary> {
  CartPanelState _panelState = CartPanelState.cart;
  final _montoController = TextEditingController();
  final _montoFocusNode = FocusNode();
  MetodoPago _metodoPago = MetodoPago.efectivo;
  Venta? _ultimaVenta;
  bool _procesando = false;

  double get _montoRecibido => double.tryParse(_montoController.text) ?? 0.0;

  @override
  void dispose() {
    _montoController.dispose();
    _montoFocusNode.dispose();
    super.dispose();
  }

  /// Determina si el botón COBRAR debe estar habilitado
  bool get _puedeCobrar {
    if (_procesando) return false;
    final carrito = ref.read(carritoProvider);
    if (carrito.isEmpty) return false;
    final total = ref.read(carritoTotalProvider);
    if (_metodoPago == MetodoPago.efectivo) {
      return _montoRecibido >= total && total > 0;
    }
    return true;
  }

  Future<void> _onConfirmarPago() async {
    if (_procesando || !_puedeCobrar) return;

    final carrito = ref.read(carritoProvider);
    if (carrito.isEmpty) return;

    final total = ref.read(carritoTotalProvider);
    final subtotal = ref.read(carritoSubtotalProvider);
    final iva = ref.read(carritoIvaProvider);

    double? cambio;
    if (_metodoPago == MetodoPago.efectivo && _montoRecibido > total) {
      cambio = _montoRecibido - total;
    }

    final detallesJson = carrito.map((item) {
      return {
        'producto_id': item.producto.id,
        'cantidad': item.cantidad,
        'precio_unitario': item.producto.precioVenta,
        'subtotal': item.subtotal,
      };
    }).toList();

    setState(() => _procesando = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _LoadingDialog(),
    );

    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.createVenta({
        'detalles': detallesJson,
        'subtotal': subtotal,
        'iva': iva,
        'total': total,
        'metodo_pago': _metodoPago.value,
        'monto_recibido':
            _metodoPago == MetodoPago.efectivo ? _montoRecibido : null,
        'cambio': cambio,
      });

      final ventaPersistida = Venta(
        id: response['id'] as int?,
        folio: response['folio'] as String?,
        detalles: carrito
            .map((item) => DetalleVenta(
                  productoId: item.producto.id,
                  nombreProducto: item.producto.nombre,
                  precioUnitario: item.producto.precioVenta,
                  cantidad: item.cantidad,
                  subtotal: item.subtotal,
                ))
            .toList(),
        subtotal: subtotal,
        iva: iva,
        total: total,
        metodoPago: _metodoPago.value,
        montoRecibido:
            _metodoPago == MetodoPago.efectivo ? _montoRecibido : null,
        cambio: cambio,
        fecha: DateTime.now(),
      );

      ref.read(carritoProvider.notifier).vaciar();
      ref.invalidate(productosProvider);

      if (mounted) {
        Navigator.of(context).pop();
        setState(() {
          _ultimaVenta = ventaPersistida;
          _panelState = CartPanelState.completado;
          _montoController.clear();
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        final msg = e.isStockInsuficiente
            ? 'Stock insuficiente para uno de los productos'
            : 'Error al registrar venta: ${e.message}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red.shade700,
            duration: AppDurations.snackbarLong,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar venta: $e'),
            backgroundColor: Colors.red.shade700,
            duration: AppDurations.snackbarLong,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _procesando = false);
      }
    }
  }

  void _onNuevaVenta() {
    setState(() {
      _panelState = CartPanelState.cart;
      _ultimaVenta = null;
      _metodoPago = MetodoPago.efectivo;
      _montoController.clear();
    });
  }

  Future<void> _onLimpiarCarrito() async {
    final carrito = ref.read(carritoProvider);
    if (carrito.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpiar carrito'),
        content: Text(
          'Vas a eliminar ${carrito.length} producto${carrito.length != 1 ? 's' : ''} del carrito. ¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    ref.read(carritoProvider.notifier).vaciar();
    _montoController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: switch (_panelState) {
        CartPanelState.cart => _buildCartView(theme),
        CartPanelState.completado => _buildCompletadoView(theme),
      },
    );
  }

  Widget _buildCartView(ThemeData theme) {
    final carrito = ref.watch(carritoProvider);
    final total = ref.watch(carritoTotalProvider);
    final iva = ref.watch(carritoIvaProvider);
    final formatter = money;
    final cambio = _montoRecibido - total;
    final puedeCobrar = _puedeCobrar;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header pequeño
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.shopping_cart,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'CARRITO (${carrito.fold(0, (sum, item) => sum + item.cantidad)} items)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),

        // Lista de productos del carrito
        if (carrito.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: carrito.length,
              itemBuilder: (context, index) {
                final item = carrito[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => ref
                            .read(carritoProvider.notifier)
                            .decrementarCantidad(item.producto.id),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.remove,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${item.cantidad}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => ref
                            .read(carritoProvider.notifier)
                            .incrementarCantidad(item.producto.id),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.add,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.producto.nombre,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        formatter.format(item.subtotal),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => ref
                            .read(carritoProvider.notifier)
                            .quitarProducto(item.producto.id),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        if (carrito.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 40,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 8),
                Text(
                  'Carrito vacío',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Escanea productos para agregarlos',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),

        const Divider(height: 1),

        // Totales
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'IVA (16%)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    formatter.format(iva),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formatter.format(total),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Método de pago
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              _buildMetodoChip(theme, MetodoPago.efectivo, Icons.money),
              const SizedBox(width: 8),
              _buildMetodoChip(theme, MetodoPago.tarjeta, Icons.credit_card),
            ],
          ),
        ),

        // Campo monto recibido (solo efectivo)
        if (_metodoPago == MetodoPago.efectivo) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monto recibido',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _montoController,
                  focusNode: _montoFocusNode,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  onChanged: (_) => setState(() {}),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    prefixStyle: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    hintText: '0.00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                // Botones de montos rápidos
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [20, 50, 100, 200, 500]
                      .where((m) => m >= total)
                      .take(4)
                      .map((m) => ActionChip(
                            label: Text('\$$m'),
                            onPressed: () {
                              _montoController.text = m.toStringAsFixed(0);
                              setState(() {});
                            },
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          if (_montoRecibido > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cambio', style: theme.textTheme.bodyLarge),
                  Text(
                    formatter.format(cambio > 0 ? cambio : 0),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cambio >= 0
                          ? Colors.green.shade700
                          : theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
        ] else ...[
          // Tarjeta
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Pago con tarjeta', style: theme.textTheme.titleMedium),
                ],
              ),
            ),
          ),
        ],

        // BOTÓN COBRAR (única forma de confirmar)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: puedeCobrar ? _onConfirmarPago : null,
              style: FilledButton.styleFrom(
                backgroundColor: puedeCobrar
                    ? Colors.green.shade700
                    : theme.colorScheme.surfaceContainerHighest,
                foregroundColor: puedeCobrar
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _procesando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle, size: 22),
              label: Text(
                _procesando
                    ? 'Procesando...'
                    : (puedeCobrar
                        ? 'COBRAR ${formatter.format(total)}'
                        : (_metodoPago == MetodoPago.efectivo &&
                                carrito.isNotEmpty
                            ? 'Falta \$${(total - _montoRecibido).toStringAsFixed(2)}'
                            : 'Agrega productos')),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),

        // Botón limpiar
        if (carrito.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _procesando ? null : _onLimpiarCarrito,
                icon: Icon(Icons.delete_sweep,
                    color: theme.colorScheme.error),
                label: Text(
                  'Limpiar carrito',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMetodoChip(
      ThemeData theme, MetodoPago value, IconData icon) {
    final selected = _metodoPago == value;
    return Expanded(
      child: GestureDetector(
        onTap: _procesando
            ? null
            : () => setState(() {
                  _metodoPago = value;
                  if (value == MetodoPago.tarjeta) _montoController.clear();
                }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: selected
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                value.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletadoView(ThemeData theme) {
    final formatter = money;
    final venta = _ultimaVenta!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.green.shade700,
                ),
                const SizedBox(height: 12),
                Text(
                  '¡Venta registrada!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Folio: ${venta.folio ?? "N/A"}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Guardada en el sistema ✓',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildTicketRow('Subtotal', formatter.format(venta.subtotal), theme),
          const SizedBox(height: 4),
          _buildTicketRow('IVA', formatter.format(venta.iva), theme),
          const SizedBox(height: 8),
          _buildTicketRow(
            'TOTAL',
            formatter.format(venta.total),
            theme,
            bold: true,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          _buildTicketRow(
            'Método',
            MetodoPago.fromString(venta.metodoPago).label,
            theme,
          ),
          if (venta.montoRecibido != null) ...[
            const SizedBox(height: 4),
            _buildTicketRow(
              'Recibido',
              formatter.format(venta.montoRecibido!),
              theme,
            ),
            const SizedBox(height: 4),
            _buildTicketRow(
              'Cambio',
              formatter.format(venta.cambio ?? 0),
              theme,
              color: Colors.green.shade700,
              bold: true,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _onNuevaVenta,
              icon: const Icon(Icons.add),
              label: const Text('Nueva Venta'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketRow(String label, String value, ThemeData theme,
      {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: bold
              ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
              : theme.textTheme.bodyMedium,
        ),
        Text(
          value,
          style: bold
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color ?? theme.colorScheme.onSurface,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  color: color ?? theme.colorScheme.onSurface,
                ),
        ),
      ],
    );
  }
}

class _LoadingDialog extends StatelessWidget {
  const _LoadingDialog();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            SizedBox(width: 20),
            Text('Procesando venta...'),
          ],
        ),
      ),
    );
  }
}
