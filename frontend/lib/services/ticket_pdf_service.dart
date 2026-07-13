import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/venta.dart';

/// Servicio para generar e imprimir tickets en PDF.
/// Usa la librería `pdf` para generar y `printing` para imprimir/compartir.
class TicketPdfService {
  /// Genera un PDF del ticket y lo muestra en el diálogo de impresión.
  /// El usuario puede imprimir, guardar como PDF o compartir.
  static Future<void> imprimir(Venta venta) async {
    final doc = await _buildDocument(venta);
    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: 'Ticket_${venta.folio ?? venta.id ?? 'sn'}',
    );
  }

  /// Guarda el PDF en el sistema de archivos (descargas) sin abrir diálogo.
  /// Útil para backup automático.
  static Future<File> guardarPdf(Venta venta) async {
    final doc = await _buildDocument(venta);
    final bytes = await doc.save();

    Directory dir;
    if (Platform.isAndroid) {
      dir = (await getExternalStorageDirectory()) ??
            await getApplicationDocumentsDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }
    final filename =
        'ticket_${venta.folio ?? venta.id ?? DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    if (kDebugMode) debugPrint('TicketPdfService: guardado en ${file.path}');
    return file;
  }

  /// Comparte el PDF usando el share-sheet nativo.
  static Future<void> compartir(Venta venta) async {
    final doc = await _buildDocument(venta);
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'ticket_${venta.folio ?? venta.id ?? 'sn'}.pdf',
    );
  }

  static Future<pw.Document> _buildDocument(Venta venta) async {
    final doc = pw.Document();
    final dateFmt = venta.fecha ?? DateTime.now();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80.copyWith(
          marginLeft: 6 * PdfPageFormat.mm,
          marginRight: 6 * PdfPageFormat.mm,
          marginTop: 4 * PdfPageFormat.mm,
          marginBottom: 4 * PdfPageFormat.mm,
        ),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _header(venta, dateFmt),
            pw.SizedBox(height: 6),
            pw.Divider(thickness: 0.5),
            _productos(venta),
            pw.Divider(thickness: 0.5),
            _totales(venta),
            pw.SizedBox(height: 6),
            if (venta.montoRecibido != null) _pago(venta),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                '¡Gracias por su compra!',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Center(
              child: pw.Text(
                'Ferretería — ${dateFmt.toIso8601String().substring(0, 10)}',
                style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
              ),
            ),
          ],
        ),
      ),
    );
    return doc;
  }

  static pw.Widget _header(Venta venta, DateTime fecha) {
    return pw.Column(
      children: [
        pw.Text(
          'FERRETERÍA',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Ticket: ${venta.folio ?? "S/N"}',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.Text(
          'Fecha: ${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} '
          '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}',
          style: const pw.TextStyle(fontSize: 8),
        ),
      ],
    );
  }

  static pw.Widget _productos(Venta venta) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.SizedBox(height: 4),
        for (final d in venta.detalles) ...[
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  d.nombreProducto,
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              pw.SizedBox(width: 4),
              pw.Text(
                '\$${d.subtotal.toStringAsFixed(2)}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 6, bottom: 2),
            child: pw.Text(
              '  ${d.cantidad} x \$${d.precioUnitario.toStringAsFixed(2)}',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _totales(Venta venta) {
    pw.TableRow fila(String l, String r, {bool bold = false, double size = 9}) {
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 1),
            child: pw.Text(
              l,
              style: pw.TextStyle(
                fontSize: size,
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
                fontSize: size,
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
        fila('TOTAL', '\$${venta.total.toStringAsFixed(2)}', bold: true, size: 11),
      ],
    );
  }

  static pw.Widget _pago(Venta venta) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
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
                  style: const pw.TextStyle(fontSize: 8)),
              pw.Text(
                MetodoPago.fromString(venta.metodoPago).label,
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Recibido', style: const pw.TextStyle(fontSize: 8)),
              pw.Text('\$${venta.montoRecibido!.toStringAsFixed(2)}',
                  style: const pw.TextStyle(fontSize: 8)),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Cambio', style: const pw.TextStyle(fontSize: 8)),
              pw.Text(
                '\$${(venta.cambio ?? 0).toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 9,
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
