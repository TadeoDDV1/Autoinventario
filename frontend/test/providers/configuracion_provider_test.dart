import 'package:flutter_test/flutter_test.dart';
import 'package:ferreteria_app/providers/configuracion_provider.dart';

void main() {
  group('ConfiguracionApp', () {
    test('Valores predeterminados correctos', () {
      const config = ConfiguracionApp();
      expect(config.tieneImpresora, false);
      expect(config.imprimirAutomatico, false);
      expect(config.formatoPapel, '80mm');
      expect(config.impresoraNombre, isNull);
      expect(config.nombreNegocio, 'FERRETERÍA');
      expect(config.rfcNegocio, '');
      expect(config.direccionNegocio, '');
      expect(config.telefonoNegocio, '');
      expect(config.mensajePieTicket, '¡Gracias por su compra!');
    });

    test('copyWith actualiza campos de impresora y negocio', () {
      const inicial = ConfiguracionApp();
      final modificado = inicial.copyWith(
        tieneImpresora: true,
        imprimirAutomatico: true,
        formatoPapel: '58mm',
        impresoraNombre: () => 'POS-58-Thermal',
        nombreNegocio: 'Ferretería Central',
        rfcNegocio: 'FC123456789',
        direccionNegocio: 'Calle 5 Sur',
        telefonoNegocio: '9611234567',
        mensajePieTicket: 'No se aceptan devoluciones sin ticket',
      );

      expect(modificado.tieneImpresora, true);
      expect(modificado.imprimirAutomatico, true);
      expect(modificado.formatoPapel, '58mm');
      expect(modificado.impresoraNombre, 'POS-58-Thermal');
      expect(modificado.nombreNegocio, 'Ferretería Central');
      expect(modificado.rfcNegocio, 'FC123456789');
      expect(modificado.direccionNegocio, 'Calle 5 Sur');
      expect(modificado.telefonoNegocio, '9611234567');
      expect(modificado.mensajePieTicket, 'No se aceptan devoluciones sin ticket');
    });

    test('copyWith permite desasignar impresoraNombre a null', () {
      const conImpresora = ConfiguracionApp(impresoraNombre: 'Impresora 1');
      final sinImpresora = conImpresora.copyWith(impresoraNombre: () => null);

      expect(sinImpresora.impresoraNombre, isNull);
    });
  });
}
