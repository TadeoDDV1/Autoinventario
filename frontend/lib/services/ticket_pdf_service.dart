import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/venta.dart';
import '../providers/configuracion_provider.dart';
import 'ticket_file_saver_stub.dart'
    if (dart.library.io) 'ticket_file_saver_io.dart'
    if (dart.library.js_interop) 'ticket_file_saver_web.dart';

/// Servicio para generar e imprimir tickets en PDF para impresoras térmicas (58mm / 80mm).
class TicketPdfService {
  /// Imprime el ticket de venta.
  /// Si [config] tiene una impresora asignada (`impresoraNombre`), intenta imprimir directamente.
  /// En caso contrario o ante error, abre el diálogo de impresión del sistema.
  static Future<bool> imprimir(Venta venta, {ConfiguracionApp? config}) async {
    final doc = await buildDocument(venta, config: config);
    final nombreDoc = 'Ticket_${venta.folio ?? venta.id ?? 'sn'}';

    if (config?.impresoraNombre != null && config!.impresoraNombre!.isNotEmpty) {
      try {
        final printers = await Printing.listPrinters();
        final selected = printers.firstWhere(
          (p) =>
              p.name == config.impresoraNombre ||
              p.url == config.impresoraNombre,
        );
        final result = await Printing.directPrintPdf(
          printer: selected,
          onLayout: (format) async => doc.save(),
          name: nombreDoc,
        );
        if (kDebugMode) {
          debugPrint('TicketPdfService: directPrintPdf a ${selected.name} -> $result');
        }
        return result;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('TicketPdfService: fallback de impresión directa por: $e');
        }
      }
    }

    return await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: nombreDoc,
    );
  }

  /// Guarda el PDF en el sistema de archivos (descargas o documentos).
  static Future<String> guardarPdf(
    Venta venta, {
    ConfiguracionApp? config,
  }) async {
    final doc = await buildDocument(venta, config: config);
    final bytes = await doc.save();
    final filename =
        'ticket_${venta.folio ?? venta.id ?? DateTime.now().millisecondsSinceEpoch}.pdf';
    final savedPath = await saveTicketPdf(bytes, filename);
    if (kDebugMode) debugPrint('TicketPdfService: guardado en $savedPath');
    return savedPath;
  }

  /// Comparte el PDF usando el share-sheet nativo.
  static Future<void> compartir(Venta venta, {ConfiguracionApp? config}) async {
    final doc = await buildDocument(venta, config: config);
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'ticket_${venta.folio ?? venta.id ?? 'sn'}.pdf',
    );
  }

  /// Genera un ticket de prueba para validar tamaño de papel, datos de negocio y conexión.
  static Future<bool> imprimirTicketPrueba(ConfiguracionApp config) async {
    final testVenta = Venta(
      id: 999999,
      folio: 'PRUEBA-001',
      subtotal: 129.31,
      iva: 20.69,
      total: 150.00,
      metodoPago: 'efectivo',
      montoRecibido: 200.00,
      cambio: 50.00,
      fecha: DateTime.now(),
      detalles: const [
        DetalleVenta(
          productoId: 101,
          nombreProducto: 'Martillo Tubular 16oz',
          cantidad: 1,
          precioUnitario: 100.00,
          subtotal: 100.00,
        ),
        DetalleVenta(
          productoId: 102,
          nombreProducto: 'Cinta Métrica 5m',
          cantidad: 1,
          precioUnitario: 50.00,
          subtotal: 50.00,
        ),
      ],
    );
    return imprimir(testVenta, config: config);
  }

  /// Construye el documento PDF formateado según la venta y la configuración.
  static Future<pw.Document> buildDocument(
    Venta venta, {
    ConfiguracionApp? config,
  }) async {
    final doc = pw.Document();
    final dateFmt = venta.fecha ?? DateTime.now();
    final is58mm = config?.formatoPapel == '58mm';

    final pageFormat = is58mm
        ? const PdfPageFormat(
            58 * PdfPageFormat.mm,
            double.infinity,
            marginLeft: 2 * PdfPageFormat.mm,
            marginRight: 2 * PdfPageFormat.mm,
            marginTop: 3 * PdfPageFormat.mm,
            marginBottom: 3 * PdfPageFormat.mm,
          )
        : PdfPageFormat.roll80.copyWith(
            marginLeft: 5 * PdfPageFormat.mm,
            marginRight: 5 * PdfPageFormat.mm,
            marginTop: 4 * PdfPageFormat.mm,
            marginBottom: 4 * PdfPageFormat.mm,
          );

    final baseFontSize = is58mm ? 7.5 : 9.0;
    final titleFontSize = is58mm ? 11.0 : 13.0;

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _header(venta, dateFmt, config, titleFontSize, baseFontSize),
            pw.SizedBox(height: 4),
            pw.Divider(thickness: 0.5),
            _productos(venta, baseFontSize),
            pw.Divider(thickness: 0.5),
            _totales(venta, baseFontSize),
            pw.SizedBox(height: 4),
            if (venta.montoRecibido != null) _pago(venta, baseFontSize),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                config?.mensajePieTicket.isNotEmpty == true
                    ? config!.mensajePieTicket
                    : '¡Gracias por su compra!',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: baseFontSize + 1,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 6),
            // Código de barras con el folio de la venta
            if ((venta.folio ?? '').isNotEmpty)
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: venta.folio!,
                  width: is58mm ? 110 : 150,
                  height: is58mm ? 26 : 34,
                  drawText: false,
                ),
              ),
            pw.SizedBox(height: 3),
            pw.Center(
              child: pw.Text(
                '${config?.nombreNegocio.isNotEmpty == true ? config!.nombreNegocio : "Ferretería"} - ${dateFmt.toIso8601String().substring(0, 10)}',
                style: pw.TextStyle(
                  fontSize: baseFontSize - 1.5,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return doc;
  }

  static pw.Widget _header(
    Venta venta,
    DateTime fecha,
    ConfiguracionApp? config,
    double titleSize,
    double baseSize,
  ) {
    final nombre = (config?.nombreNegocio.isNotEmpty == true)
        ? config!.nombreNegocio
        : 'FERRETERÍA';
    final rfc = config?.rfcNegocio ?? '';
    final dir = config?.direccionNegocio ?? '';
    final tel = config?.telefonoNegocio ?? '';
    final esOffline = venta.folio?.startsWith('OFFLINE-') == true;

    return pw.Column(
      children: [
        pw.Text(
          nombre,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: titleSize, fontWeight: pw.FontWeight.bold),
        ),
        if (rfc.isNotEmpty) ...[
          pw.SizedBox(height: 1),
          pw.Text('RFC: $rfc', style: pw.TextStyle(fontSize: baseSize - 1)),
        ],
        if (dir.isNotEmpty) ...[
          pw.SizedBox(height: 1),
          pw.Text(
            dir,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: baseSize - 1.5),
          ),
        ],
        if (tel.isNotEmpty) ...[
          pw.SizedBox(height: 1),
          pw.Text('Tel: $tel', style: pw.TextStyle(fontSize: baseSize - 1)),
        ],
        pw.SizedBox(height: 3),
        if (esOffline) ...[
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 0.5, color: PdfColors.grey700),
            ),
            child: pw.Text(
              '*** COMPROBANTE LOCAL / OFFLINE ***',
              style: pw.TextStyle(
                fontSize: baseSize - 1.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 2),
        ],
        pw.Text(
          'Ticket: ${venta.folio ?? "S/N"}',
          style: pw.TextStyle(fontSize: baseSize, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Fecha: ${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} '
          '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}',
          style: pw.TextStyle(fontSize: baseSize - 1),
        ),
      ],
    );
  }

  static pw.Widget _productos(Venta venta, double baseSize) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.SizedBox(height: 2),
        for (final d in venta.detalles) ...[
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  d.nombreProducto,
                  style: pw.TextStyle(fontSize: baseSize),
                ),
              ),
              pw.SizedBox(width: 4),
              pw.Text(
                '\$${d.subtotal.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: baseSize),
              ),
            ],
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 4, bottom: 2),
            child: pw.Text(
              '  ${d.cantidad} x \$${d.precioUnitario.toStringAsFixed(2)}',
              style: pw.TextStyle(
                fontSize: baseSize - 1.5,
                color: PdfColors.grey700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _totales(Venta venta, double baseSize) {
    pw.TableRow fila(String l, String r, {bool bold = false, double? size}) {
      final s = size ?? baseSize;
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 1),
            child: pw.Text(
              l,
              style: pw.TextStyle(
                fontSize: s,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 1),
            child: pw.Text(
              r,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: s,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      );
    }

    return pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(1),
      },
      children: [
        fila('Subtotal', '\$${venta.subtotal.toStringAsFixed(2)}'),
        fila('IVA (16%)', '\$${venta.iva.toStringAsFixed(2)}'),
        fila(
          'TOTAL',
          '\$${venta.total.toStringAsFixed(2)}',
          bold: true,
          size: baseSize + 2,
        ),
      ],
    );
  }

  static pw.Widget _pago(Venta venta, double baseSize) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(3),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5, color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(2),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Método de pago',
                  style: pw.TextStyle(fontSize: baseSize - 1)),
              pw.Text(
                MetodoPago.fromString(venta.metodoPago).label,
                style: pw.TextStyle(
                  fontSize: baseSize - 1,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 1),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Recibido', style: pw.TextStyle(fontSize: baseSize - 1)),
              pw.Text('\$${venta.montoRecibido!.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: baseSize - 1)),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Cambio', style: pw.TextStyle(fontSize: baseSize - 1)),
              pw.Text(
                '\$${(venta.cambio ?? 0).toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: baseSize,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
