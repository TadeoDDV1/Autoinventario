import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/format/money.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/navigation/nav_helpers.dart';
import '../../core/widgets/atmospheric_background.dart';
import '../../models/venta.dart';
import '../../providers/configuracion_provider.dart';
import '../../services/ticket_pdf_service.dart';

/// Pantalla de ticket de venta.
///
/// Diseño: réplica de un ticket térmico (papel con bordes dentados y cortes
/// punteados) presentada sobre el fondo de la app. En pantallas anchas el
/// ticket vive en una columna fija a la izquierda y las acciones de
/// impresión/compartir en un panel a la derecha.
class TicketScreen extends ConsumerWidget {
  final Venta venta;

  const TicketScreen({super.key, required this.venta});

  Future<void> _imprimir(BuildContext context, WidgetRef ref, Venta v) async {
    final config = ref.read(configuracionProvider).value;
    try {
      await TicketPdfService.imprimir(v, config: config);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al imprimir: $e')),
        );
      }
    }
  }

  Future<void> _compartir(BuildContext context, WidgetRef ref, Venta v) async {
    final config = ref.read(configuracionProvider).value;
    try {
      await TicketPdfService.compartir(v, config: config);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al compartir: $e')),
        );
      }
    }
  }

  Future<void> _guardar(BuildContext context, WidgetRef ref, Venta v) async {
    final config = ref.read(configuracionProvider).value;
    try {
      final savedPath = await TicketPdfService.guardarPdf(v, config: config);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF guardado: $savedPath')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configuracionProvider).value;
    final width = MediaQuery.of(context).size.width;
    final esAncho = Breakpoints.isDesktop(width);

    final ticket = _TicketPaper(venta: venta, config: config);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket ${venta.folio ?? ''}'.trim()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
          onPressed: () => popOrGo(context, '/caja'),
        ),
        actions: [
          IconButton(
            tooltip: 'Imprimir ticket',
            icon: const Icon(Icons.print),
            onPressed: () => _imprimir(context, ref, venta),
          ),
          IconButton(
            tooltip: 'Compartir PDF',
            icon: const Icon(Icons.share),
            onPressed: () => _compartir(context, ref, venta),
          ),
          IconButton(
            tooltip: 'Guardar PDF',
            icon: const Icon(Icons.save_alt),
            onPressed: () => _guardar(context, ref, venta),
          ),
        ],
      ),
      body: Stack(
        children: [
          const AtmosphericBackground(),
          SingleChildScrollView(
            padding: EdgeInsets.all(esAncho ? 32 : 16),
            child: Center(
              child: esAncho
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: ticket,
                        ),
                        const SizedBox(width: 24),
                        SizedBox(
                          width: 320,
                          child: _ActionsPanel(
                            venta: venta,
                            onImprimir: () => _imprimir(context, ref, venta),
                            onCompartir: () => _compartir(context, ref, venta),
                            onGuardar: () => _guardar(context, ref, venta),
                            onNuevoTicket: () => _nuevoTicket(context),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ticket,
                        const SizedBox(height: 16),
                        _ActionsPanel(
                          venta: venta,
                          onImprimir: () => _imprimir(context, ref, venta),
                          onCompartir: () => _compartir(context, ref, venta),
                          onGuardar: () => _guardar(context, ref, venta),
                          onNuevoTicket: () => _nuevoTicket(context),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _nuevoTicket(BuildContext context) {
    // Cierra el stack overlay y vuelve a Caja a empezar de cero.
    GoRouter.of(context).go('/caja');
  }
}

// ───────────────────────────────────────────────────────────────────────────
//  Panel de acciones
// ───────────────────────────────────────────────────────────────────────────

class _ActionsPanel extends StatelessWidget {
  final Venta venta;
  final VoidCallback onImprimir;
  final VoidCallback onCompartir;
  final VoidCallback onGuardar;
  final VoidCallback onNuevoTicket;

  const _ActionsPanel({
    required this.venta,
    required this.onImprimir,
    required this.onCompartir,
    required this.onGuardar,
    required this.onNuevoTicket,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metodo = MetodoPago.fromString(venta.metodoPago);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Resumen',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.shopping_bag_outlined,
            label: 'Productos',
            value:
                '${venta.detalles.fold<int>(0, (sum, d) => sum + d.cantidad)} artículos',
          ),
          _SummaryRow(
            icon: metodo == MetodoPago.efectivo
                ? Icons.payments_outlined
                : Icons.credit_card,
            label: 'Pago',
            value: metodo.label,
          ),
          _SummaryRow(
            icon: Icons.savings_outlined,
            label: 'Total',
            value: money.format(venta.total),
            destacado: true,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onImprimir,
              icon: const Icon(Icons.print),
              label: const Text('Imprimir'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCompartir,
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGuardar,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('PDF'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onNuevoTicket,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Nuevo ticket'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool destacado;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: style)),
          Text(
            value,
            style: style?.copyWith(
              fontWeight: destacado ? FontWeight.bold : FontWeight.w500,
              fontSize: destacado ? 16 : null,
              color: destacado ? theme.colorScheme.primary : null,
              fontFeatures: const [FontFeature('tnum')],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//  Papel del ticket
// ───────────────────────────────────────────────────────────────────────────

class _TicketPaper extends StatelessWidget {
  final Venta venta;
  final ConfiguracionApp? config;

  const _TicketPaper({required this.venta, this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fecha = venta.fecha ?? DateTime.now();
    final papel = theme.brightness == Brightness.dark
        ? const Color(0xFF1C1B22)
        : Colors.white;
    final tinta = theme.brightness == Brightness.dark
        ? const Color(0xFFE8E6F0)
        : const Color(0xFF1B1A22);
    final tenue = theme.brightness == Brightness.dark
        ? const Color(0xFF9C99AD)
        : const Color(0xFF6B6878);
    final esOffline = venta.folio?.startsWith('OFFLINE-') == true;
    final metodo = MetodoPago.fromString(venta.metodoPago);

    return ClipPath(
      clipper: const _TicketClipper(),
      child: Container(
        width: double.infinity,
        color: papel,
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
        child: DefaultTextStyle(
          style: theme.textTheme.bodyMedium!.copyWith(color: tinta),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Encabezado del negocio ──
              Text(
                (config?.nombreNegocio.isNotEmpty == true)
                    ? config!.nombreNegocio
                    : 'FERRETERÍA',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: tinta,
                  letterSpacing: 1.5,
                ),
              ),
              if (config?.rfcNegocio.isNotEmpty == true) ...[
                const SizedBox(height: 2),
                Text(
                  'RFC ${config!.rfcNegocio}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: tenue),
                ),
              ],
              if (config?.direccionNegocio.isNotEmpty == true) ...[
                const SizedBox(height: 2),
                Text(
                  config!.direccionNegocio,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: tenue),
                ),
              ],
              if (config?.telefonoNegocio.isNotEmpty == true) ...[
                const SizedBox(height: 2),
                Text(
                  'Tel. ${config!.telefonoNegocio}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: tenue),
                ),
              ],
              const SizedBox(height: 16),
              _TicketDivider(color: tenue),
              const SizedBox(height: 14),

              // ── Folio + fecha + estado ──
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'TICKET',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 2,
                        color: tenue,
                      ),
                    ),
                  ),
                  Text(
                    venta.folio ?? 'S/N',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      fontFeatures: [FontFeature('tnum')],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fecha',
                      style: TextStyle(fontSize: 11, color: tenue),
                    ),
                  ),
                  Text(
                    _fmtFecha(fecha),
                    style: TextStyle(
                      fontSize: 12,
                      color: tinta,
                      fontFeatures: const [FontFeature('tnum')],
                    ),
                  ),
                ],
              ),
              if (esOffline) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: tenue),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'COMPROBANTE LOCAL / PENDIENTE DE SYNC',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ],

              // ── Productos ──
              const SizedBox(height: 16),
              _TicketDivider(color: tenue),
              const SizedBox(height: 12),
              Text(
                'PRODUCTOS',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  color: tenue,
                ),
              ),
              const SizedBox(height: 8),
              if (venta.detalles.isEmpty)
                Text(
                  'Sin productos registrados',
                  style: TextStyle(fontSize: 12, color: tenue),
                )
              else
                ...venta.detalles.map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 34,
                          child: Text(
                            '${d.cantidad}×',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFeatures: [FontFeature('tnum')],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.nombreProducto,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${money.format(d.precioUnitario)} c/u',
                                style:
                                    TextStyle(fontSize: 11, color: tenue),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          money.format(d.subtotal),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFeatures: [FontFeature('tnum')],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Totales ──
              const SizedBox(height: 4),
              _TicketDivider(color: tenue),
              const SizedBox(height: 10),
              _LineaImporte(label: 'Subtotal', valor: money.format(venta.subtotal)),
              _LineaImporte(label: 'IVA (16%)', valor: money.format(venta.iva)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 13,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                        color: tinta,
                      ),
                    ),
                  ),
                  Text(
                    money.format(venta.total),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      fontFeatures: [FontFeature('tnum')],
                    ),
                  ),
                ],
              ),

              // ── Pago ──
              const SizedBox(height: 12),
              _TicketDivider(color: tenue),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Método de pago',
                      style: TextStyle(fontSize: 12, color: tenue),
                    ),
                  ),
                  Text(
                    metodo.label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (venta.montoRecibido != null) ...[
                const SizedBox(height: 4),
                _LineaImporte(
                  label: 'Recibido',
                  valor: money.format(venta.montoRecibido!),
                  tenue: tenue,
                ),
                if (venta.cambio != null)
                  _LineaImporte(
                    label: 'Cambio',
                    valor: money.format(venta.cambio!),
                    color: const Color(0xFF1B8A4B),
                    resaltado: true,
                  ),
              ],

              // ── Pie: código de barras + mensaje ──
              const SizedBox(height: 16),
              _TicketDivider(color: tenue),
              const SizedBox(height: 14),
              if ((venta.folio ?? '').isNotEmpty) ...[
                Center(
                  child: BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: venta.folio!,
                    width: 190,
                    height: 44,
                    drawText: false,
                    color: tinta,
                    errorBuilder: (_, _) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    venta.folio!,
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 2,
                      color: tenue,
                      fontFeatures: const [FontFeature('tnum')],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Center(
                child: Text(
                  config?.mensajePieTicket.isNotEmpty == true
                      ? config!.mensajePieTicket
                      : '¡Gracias por su compra!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  '${(config?.nombreNegocio.isNotEmpty == true) ? config!.nombreNegocio : 'Ferretería'} · ${DateFormat('dd/MM/yyyy').format(fecha)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: tenue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtFecha(DateTime f) {
    final hora = f.hour.toString().padLeft(2, '0');
    final min = f.minute.toString().padLeft(2, '0');
    final d = f.day.toString().padLeft(2, '0');
    final m = f.month.toString().padLeft(2, '0');
    return '$d/$m/${f.year} $hora:$min';
  }
}

class _LineaImporte extends StatelessWidget {
  final String label;
  final String valor;
  final Color? color;
  final bool resaltado;
  final Color? tenue;

  const _LineaImporte({
    required this.label,
    required this.valor,
    this.color,
    this.resaltado = false,
    this.tenue,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: resaltado ? 14 : 13,
      fontWeight: resaltado ? FontWeight.w800 : FontWeight.w500,
      color: color,
      fontFeatures: const [FontFeature('tnum')],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: tenue),
            ),
          ),
          Text(valor, style: style),
        ],
      ),
    );
  }
}

/// Línea de corte punteada tipo ticket térmico.
class _TicketDivider extends StatelessWidget {
  final Color color;

  const _TicketDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: CustomPaint(painter: _DashedPainter(color)),
    );
  }
}

class _DashedPainter extends CustomPainter {
  final Color color;

  _DashedPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    const dash = 4.0;
    const gap = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedPainter oldDelegate) => oldDelegate.color != color;
}

/// Recorta el papel con bordes dentados arriba y abajo (efecto ticket).
class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper();

  static const double _tooth = 14;
  static const double _depth = 8;

  @override
  Path getClip(Size size) {
    final path = Path();

    // Borde superior dentado (triángulos regulares hacia arriba).
    path.moveTo(0, _depth);
    double x = 0;
    while (x < size.width) {
      final mid = (x + _tooth / 2).clamp(0.0, size.width);
      final end = (x + _tooth).clamp(0.0, size.width);
      path.lineTo(mid, 0);
      path.lineTo(end, _depth);
      x = end;
    }

    // Lado derecho.
    path.lineTo(size.width, size.height - _depth);

    // Borde inferior dentado (triángulos regulares hacia abajo).
    x = size.width;
    while (x > 0) {
      final mid = (x - _tooth / 2).clamp(0.0, size.width);
      final end = (x - _tooth).clamp(0.0, size.width);
      path.lineTo(mid, size.height);
      path.lineTo(end, size.height - _depth);
      x = end;
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _TicketClipper oldClipper) => false;
}
