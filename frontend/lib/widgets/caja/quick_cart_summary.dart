import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/constants/durations.dart';
import '../../core/format/money.dart';
import '../../database/app_database.dart';
import '../../models/venta.dart';
import '../../providers/producto_provider.dart';
import '../../providers/ia_provider.dart';
import '../../providers/venta_provider.dart';
import '../../services/sync_service.dart';
import '../../database/database_provider.dart';

/// Panel del carrito, simplificado. Aparece fijo en mobile y en el side
/// panel del desktop.
///
/// Estructura nueva (una sola vista):
/// ```
///  Header:    "CARRITO (N items) | TOTAL $XXX.XX"
///  Body:
///    - Lista de items (alt máx 120). Cada item: nombre, qty +/-, subtotal
///    - Empty state con icono
///  Footer:
///    - Row: IVA · Cambio · Método (segmented)
///    - TextField monto recibido
///    - Botón COBRAR full-width
/// ```
class QuickCartSummary extends ConsumerStatefulWidget {
  final VoidCallback onLimpiar;

  const QuickCartSummary({
    super.key,
    required this.onLimpiar,
  });

  @override
  ConsumerState<QuickCartSummary> createState() => QuickCartSummaryState();
}

class QuickCartSummaryState extends ConsumerState<QuickCartSummary> {
  final _montoController = TextEditingController();
  final _montoFocusNode = FocusNode();
  MetodoPago _metodoPago = MetodoPago.efectivo;
  bool _procesando = false;

  double get _montoRecibido => double.tryParse(_montoController.text) ?? 0.0;

  @override
  void dispose() {
    _montoController.dispose();
    _montoFocusNode.dispose();
    super.dispose();
  }

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

    try {
      final ventaData = {
        'detalles': detallesJson,
        'subtotal': subtotal,
        'iva': iva,
        'total': total,
        'metodo_pago': _metodoPago.value,
        'monto_recibido':
            _metodoPago == MetodoPago.efectivo ? _montoRecibido : null,
        'cambio': cambio,
        '_client_id': _generateClientId(),
      };

      final sync = ref.read(conectividadProvider.notifier);
      final result = await sync.intentarVenta(ventaData);

      if (!mounted) return;

      if (result.ok) {
        // Guardar la venta en VentasLocal (siempre, online u offline)
        await _guardarVentaLocal(
          detallesJson: detallesJson,
          subtotal: subtotal,
          iva: iva,
          total: total,
          metodoPago: _metodoPago.value,
          montoRecibido:
              _metodoPago == MetodoPago.efectivo ? _montoRecibido : null,
          cambio: cambio,
          result: result,
          clientId: ventaData['_client_id'] as String,
        );

        ref.read(carritoProvider.notifier).vaciar();
        ref.invalidate(productosProvider);
        ref.invalidate(dashboardProvider);
        ref.invalidate(ventasHoyPorHoraProvider);
        ref.invalidate(ventasRecientesProvider);

        _montoController.clear();
        if (result.encolado) {
          // Decrementar stock localmente para cada producto de la venta
          await _decrementarStockLocal(detallesJson);
          _mostrarSnackOffline();
        } else {
          _mostrarSnackExito(
              folio: result.folio ?? '—', cambio: cambio, ventaId: result.id);
        }
      } else {
        _mostrarSnackError(result.mensaje ?? 'Error al registrar venta');
      }
    } catch (e) {
      if (mounted) {
        _mostrarSnackError('Error al registrar venta: $e');
      }
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  void _mostrarSnackExito({
    required String folio,
    double? cambio,
    int? ventaId,
  }) {
    HapticFeedback.heavyImpact();
    final cambioTxt = (cambio != null && cambio > 0)
        ? ' · Cambio ${money.format(cambio)}'
        : '';
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Venta registrada · Folio $folio$cambioTxt',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: (ventaId != null)
            ? SnackBarAction(
                label: 'Ver ticket',
                textColor: Colors.white,
                onPressed: () {
                  final carrito = <DetalleVenta>[];
                  // El ticket se muestra con los datos básicos
                  context.push('/caja/ticket', extra: Venta(
                    id: ventaId,
                    folio: folio,
                    detalles: carrito,
                    subtotal: 0,
                    iva: 0,
                    total: 0,
                    metodoPago: 'efectivo',
                  ));
                },
              )
            : null,
      ),
    );
  }

  void _mostrarSnackError(String mensaje) {
    HapticFeedback.vibrate();
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: AppDurations.snackbarLong,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarSnackOffline() {
    HapticFeedback.mediumImpact();
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.cloud_sync, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Venta guardada localmente. Se sincroniza con el botón Sincronizar.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.indigo.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _generateClientId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return 'venta-$now-${now.hashCode.toRadixString(16)}';
  }

  Future<void> _decrementarStockLocal(List<dynamic> detalles) async {
    try {
      final db = ref.read(appDatabaseProvider);
      for (final d in detalles) {
        final productoId = d['producto_id'] as int?;
        final cantidad = d['cantidad'] as int?;
        if (productoId != null && cantidad != null && cantidad > 0) {
          await db.decrementarStock(productoId, cantidad);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('decrementarStockLocal error: $e');
    }
  }

  /// Guarda la venta en la tabla local VentasLocal + VentasDetalleLocal.
  /// Funciona tanto para ventas online (con ID real del servidor) como
  /// offline (con ID temporal negativo).
  Future<void> _guardarVentaLocal({
    required List<dynamic> detallesJson,
    required double subtotal,
    required double iva,
    required double total,
    required String metodoPago,
    required double? montoRecibido,
    required double? cambio,
    required dynamic result,
    required String clientId,
  }) async {
    try {
      final db = ref.read(appDatabaseProvider);
      final ahora = DateTime.now();

      // ID de la venta: real del servidor (online) o temporal negativo (offline)
      final int ventaId;
      final String folio;
      final bool synced;

      if (result.encolado) {
        // Offline: ID temporal negativo, folio provisional
        ventaId = -(ahora.millisecondsSinceEpoch % 1000000);
        folio = 'OFFLINE-${ahora.millisecondsSinceEpoch}';
        synced = false;
      } else {
        // Online: ID real del servidor
        ventaId = result.id ?? -(ahora.millisecondsSinceEpoch % 1000000);
        folio = result.folio ?? 'VENT-$ventaId';
        synced = true;
      }

      // Construir detalles companion
      final detallesCompanion = <VentasDetalleLocalCompanion>[];
      for (final d in detallesJson) {
        detallesCompanion.add(VentasDetalleLocalCompanion(
          ventaId: Value(ventaId),
          productoId: Value(d['producto_id'] as int),
          nombreProducto: Value(''),
          precioUnitario: Value((d['precio_unitario'] as num).toDouble()),
          cantidad: Value(d['cantidad'] as int),
          subtotal: Value((d['subtotal'] as num).toDouble()),
        ));
      }

      // Insertar venta + detalles en una transacción atómica
      await db.insertVentaConDetalle(
        VentasLocalCompanion(
          id: Value(ventaId),
          folio: Value(folio),
          clientId: Value(clientId),
          fecha: Value(ahora),
          subtotal: Value(subtotal),
          iva: Value(iva),
          total: Value(total),
          metodoPago: Value(metodoPago),
          montoRecibido: Value(montoRecibido),
          cambio: Value(cambio),
          synced: Value(synced),
        ),
        detallesCompanion,
      );

      if (kDebugMode) debugPrint('Venta guardada localmente: id=$ventaId, folio=$folio, synced=$synced');
    } catch (e) {
      if (kDebugMode) debugPrint('guardarVentaLocal error: $e');
    }
  }

  /// Abre un bottom-sheet con el flujo de cobro rápido disparado por Ctrl+P.
  Future<void> abrirDialogoCobroRapido() async {
    final carrito = ref.read(carritoProvider);
    if (carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Carrito vacío'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _metodoPago = MetodoPago.efectivo);
    final montoRecibido = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) =>
          _CobroRapidoSheet(total: ref.read(carritoTotalProvider)),
    );
    if (montoRecibido == null) return;
    if (!mounted) return;
    setState(() => _montoController.text = montoRecibido.toStringAsFixed(2));
    await _onConfirmarPago();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, -3),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    final carrito = ref.watch(carritoProvider);
    final total = ref.watch(carritoTotalProvider);
    final iva = ref.watch(carritoIvaProvider);
    final formatter = money;
    final cantidad = carrito.fold(0, (s, i) => s + i.cantidad);
    final cambio = _montoRecibido - total;
    final puedeCobrar = _puedeCobrar;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header con TOTAL
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Icon(Icons.shopping_cart,
                  size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'CARRITO · $cantidad items',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                formatter.format(total),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),

        if (carrito.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 24, color: theme.colorScheme.outline),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Carrito vacío • escanea o toca un producto del grid',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                ),
              ],
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 140),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: carrito.length,
              itemBuilder: (context, index) {
                final item = carrito[index];
                return _ItemRow(
                  item: item,
                  onInc: () => ref
                      .read(carritoProvider.notifier)
                      .incrementarCantidad(item.producto.id),
                  onDec: () => ref
                      .read(carritoProvider.notifier)
                      .decrementarCantidad(item.producto.id),
                  onRemove: () => ref
                      .read(carritoProvider.notifier)
                      .quitarProducto(item.producto.id),
                );
              },
            ),
          ),

        if (carrito.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'IVA 16%',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                Text(
                  formatter.format(iva),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (_metodoPago == MetodoPago.efectivo && _montoRecibido > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cambio', style: theme.textTheme.bodyMedium),
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
        ],

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              _MetodoChip(
                label: 'Efectivo',
                icon: Icons.money,
                selected: _metodoPago == MetodoPago.efectivo,
                disabled: _procesando,
                onTap: () => setState(() {
                  _metodoPago = MetodoPago.efectivo;
                }),
              ),
              const SizedBox(width: 8),
              _MetodoChip(
                label: 'Tarjeta',
                icon: Icons.credit_card,
                selected: _metodoPago == MetodoPago.tarjeta,
                disabled: _procesando,
                onTap: () => setState(() {
                  _metodoPago = MetodoPago.tarjeta;
                  _montoController.clear();
                }),
              ),
            ],
          ),
        ),

        if (_metodoPago == MetodoPago.efectivo)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _montoController,
              focusNode: _montoFocusNode,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d{0,2}')),
              ],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Monto recibido',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
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
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  final CarritoItem item;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final VoidCallback onRemove;

  const _ItemRow({
    required this.item,
    required this.onInc,
    required this.onDec,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = money;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          IconButton(
            onPressed: onDec,
            icon: const Icon(Icons.remove_circle_outline),
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(
            width: 32,
            child: Text(
              '${item.cantidad}',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: onInc,
            icon: const Icon(Icons.add_circle_outline),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
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
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.close,
                size: 16, color: theme.colorScheme.outline),
            visualDensity: VisualDensity.compact,
            tooltip: 'Quitar',
          ),
        ],
      ),
    );
  }
}

class _MetodoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  const _MetodoChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: selected
                ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                : Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
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
}

/// Bottom-sheet de cobro rápido disparado por Ctrl+P desde la pantalla Caja.
class _CobroRapidoSheet extends StatefulWidget {
  final double total;

  const _CobroRapidoSheet({required this.total});

  @override
  State<_CobroRapidoSheet> createState() => _CobroRapidoSheetState();
}

class _CobroRapidoSheetState extends State<_CobroRapidoSheet> {
  late final TextEditingController _montoCtrl;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _montoCtrl = TextEditingController(
      text: widget.total.toStringAsFixed(2),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
      _montoCtrl.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _montoCtrl.text.length,
      );
    });
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = money;
    final monto = double.tryParse(_montoCtrl.text) ?? 0.0;
    final cambio = monto - widget.total;
    final puedeCobrar = monto >= widget.total;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Cobro rápido',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Efectivo · Total ${formatter.format(widget.total)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _montoCtrl,
              focusNode: _focus,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {
                if (puedeCobrar) Navigator.of(context).pop(monto);
              },
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Monto recibido',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (monto > 0) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cambio', style: theme.textTheme.titleMedium),
                  Text(
                    formatter.format(cambio > 0 ? cambio : 0),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cambio >= 0
                          ? Colors.green.shade700
                          : theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed:
                  puedeCobrar ? () => Navigator.of(context).pop(monto) : null,
              icon: const Icon(Icons.check_circle),
              label: Text(
                puedeCobrar
                    ? 'COBRAR ${formatter.format(widget.total)}'
                    : 'Falta ${formatter.format(widget.total - monto)}',
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                    puedeCobrar ? Colors.green.shade700 : null,
                foregroundColor: puedeCobrar ? Colors.white : null,
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
