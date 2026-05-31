import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/venta.dart';
import '../../providers/venta_provider.dart';
import '../../widgets/ventas/metodo_pago_selector.dart';
import '../../widgets/ventas/numpad_widget.dart';

class CobrosScreen extends ConsumerStatefulWidget {
  const CobrosScreen({super.key});

  @override
  ConsumerState<CobrosScreen> createState() => _CobrosScreenState();
}

class _CobrosScreenState extends ConsumerState<CobrosScreen> {
  String _montoRecibidoStr = '';
  String _metodoPago = 'efectivo';

  double get _montoRecibido => double.tryParse(_montoRecibidoStr) ?? 0.0;

  void _setMonto(String monto) {
    setState(() => _montoRecibidoStr = monto);
  }

  void _appendToMonto(String digit) {
    setState(() {
      if (digit == '.' && _montoRecibidoStr.contains('.')) return;
      if (_montoRecibidoStr.contains('.') &&
          _montoRecibidoStr.split('.')[1].length >= 2) return;
      _montoRecibidoStr += digit;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = ref.watch(carritoTotalProvider);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final cambio = _montoRecibido - total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cobro'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: theme.colorScheme.primaryContainer,
            child: Column(
              children: [
                Text(
                  'Total a Pagar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatter.format(total),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MetodoPagoSelector(
                    selectedMethod: _metodoPago,
                    onMethodSelected: (method) {
                      setState(() => _metodoPago = method);
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_metodoPago == 'efectivo') ...[
                    _buildQuickAmounts(theme, total),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Monto Recibido',
                                style: theme.textTheme.bodyLarge,
                              ),
                              Text(
                                formatter.format(_montoRecibido),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Cambio',
                                style: theme.textTheme.bodyLarge,
                              ),
                              Text(
                                formatter.format(cambio > 0 ? cambio : 0),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cambio >= 0
                                      ? Colors.green
                                      : theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: NumpadWidget(
                        onNumberTap: _appendToMonto,
                        onClear: () => setState(() => _montoRecibidoStr = ''),
                        onDelete: () {
                          setState(() {
                            if (_montoRecibidoStr.isNotEmpty) {
                              _montoRecibidoStr = _montoRecibidoStr.substring(
                                  0, _montoRecibidoStr.length - 1);
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _montoRecibido >= total
                            ? () => _procesarVenta(
                                  context,
                                  ref,
                                  metodoPago: MetodoPago.efectivo,
                                  montoRecibido: _montoRecibido,
                                  cambio: cambio > 0 ? cambio : 0,
                                )
                            : null,
                        icon: const Icon(Icons.check),
                        label: const Text('Confirmar Pago'),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.credit_card,
                              size: 80,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Esperando tarjeta...',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'El cliente debe pasar su tarjeta',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () => _procesarVenta(
                                  context,
                                  ref,
                                  metodoPago: MetodoPago.tarjeta,
                                ),
                                icon: const Icon(Icons.check),
                                label: const Text('Confirmar Tarjeta'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmounts(ThemeData theme, double total) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final roundedUp = ((total / 10).ceil() * 10).toInt();

    final quickAmounts = <int>[];
    if (total <= 20) {
      quickAmounts.addAll([20, 50, 100]);
    } else if (total <= 50) {
      quickAmounts.addAll([50, 100, 200]);
    } else if (total <= 100) {
      quickAmounts.addAll([100, 200, 500]);
    } else {
      quickAmounts.addAll([roundedUp, roundedUp + 50, roundedUp + 100]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cantidades rápidas',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: quickAmounts.map((amount) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton(
                  onPressed: () => _setMonto(amount.toString()),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(formatter.format(amount)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _procesarVenta(
    BuildContext context,
    WidgetRef ref, {
    required MetodoPago metodoPago,
    double? montoRecibido,
    double? cambio,
  }) {
    final carrito = ref.read(carritoProvider);
    if (carrito.isEmpty) return;

    final detalles = carrito.map((item) => DetalleVenta(
      productoId: item.producto.id,
      nombreProducto: item.producto.nombre,
      precioUnitario: item.producto.precioVenta,
      cantidad: item.cantidad,
      subtotal: item.subtotal,
    )).toList();

    final total = ref.read(carritoTotalProvider);
    final subtotal = ref.read(carritoSubtotalProvider);
    final iva = ref.read(carritoIvaProvider);

    final venta = Venta(
      folio: 'V-${DateTime.now().millisecondsSinceEpoch}',
      detalles: detalles,
      subtotal: subtotal,
      iva: iva,
      total: total,
      metodoPago: metodoPago == MetodoPago.efectivo ? 'efectivo' : 'tarjeta',
      montoRecibido: montoRecibido,
      cambio: cambio,
      fecha: DateTime.now(),
    );

    ref.read(carritoProvider.notifier).vaciar();

    context.go('/ventas/ticket', extra: venta);
  }
}