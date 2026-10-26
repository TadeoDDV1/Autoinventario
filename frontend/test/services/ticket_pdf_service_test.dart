import 'package:flutter_test/flutter_test.dart';
import 'package:ferreteria_app/models/venta.dart';
import 'package:ferreteria_app/providers/configuracion_provider.dart';
import 'package:ferreteria_app/services/ticket_pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TicketPdfService', () {
    final ventaEjemplo = Venta(
      id: 101,
      folio: 'VENT-101',
      subtotal: 258.62,
      iva: 41.38,
      total: 300.00,
      metodoPago: 'efectivo',
      montoRecibido: 500.00,
      cambio: 200.00,
      fecha: DateTime(2026, 10, 13, 14, 30),
      detalles: const [
        DetalleVenta(
          productoId: 1,
          nombreProducto: 'Tornillo para madera 2"',
          cantidad: 10,
          precioUnitario: 15.00,
          subtotal: 150.00,
        ),
        DetalleVenta(
          productoId: 2,
          nombreProducto: 'Destornillador Phillips',
          cantidad: 1,
          precioUnitario: 150.00,
          subtotal: 150.00,
        ),
      ],
    );

    test('buildDocument genera documento PDF válido de 80mm con bytes correctos', () async {
      const config80 = ConfiguracionApp(
        tieneImpresora: true,
        formatoPapel: '80mm',
        nombreNegocio: 'Ferretería El Tornillo',
        rfcNegocio: 'TOR990101XYZ',
        direccionNegocio: 'Av. Principal 123, Centro',
        telefonoNegocio: '555-123-4567',
        mensajePieTicket: '¡Gracias por su preferencia!',
      );

      final doc = await TicketPdfService.buildDocument(ventaEjemplo, config: config80);
      final bytes = await doc.save();

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(100));
    });

    test('buildDocument genera ticket en formato 58mm con bytes correctos', () async {
      const config58 = ConfiguracionApp(
        tieneImpresora: true,
        formatoPapel: '58mm',
        nombreNegocio: 'Mini Ferre',
      );

      final doc = await TicketPdfService.buildDocument(ventaEjemplo, config: config58);
      final bytes = await doc.save();

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(100));
    });

    test('buildDocument soporta venta offline con leyenda y folio provisional', () async {
      final ventaOffline = Venta(
        id: -1,
        folio: 'OFFLINE-1772635467',
        subtotal: 86.21,
        iva: 13.79,
        total: 100.00,
        metodoPago: 'efectivo',
        montoRecibido: 100.00,
        cambio: 0.00,
        detalles: const [
          DetalleVenta(
            productoId: 5,
            nombreProducto: 'Lija de agua #120',
            cantidad: 5,
            precioUnitario: 20.00,
            subtotal: 100.00,
          ),
        ],
      );

      const config = ConfiguracionApp(tieneImpresora: true);

      final doc = await TicketPdfService.buildDocument(ventaOffline, config: config);
      final bytes = await doc.save();

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(100));
    });
  });
}
