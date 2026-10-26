import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracionApp {
  final int diasHistorialSync;
  final bool autoSyncOnConnect;

  // Configuración de impresora de tickets
  final bool tieneImpresora;
  final bool imprimirAutomatico;
  final String formatoPapel; // '80mm' | '58mm'
  final String? impresoraNombre;

  // Datos del negocio en tickets
  final String nombreNegocio;
  final String rfcNegocio;
  final String direccionNegocio;
  final String telefonoNegocio;
  final String mensajePieTicket;

  const ConfiguracionApp({
    this.diasHistorialSync = 30,
    this.autoSyncOnConnect = true,
    this.tieneImpresora = false,
    this.imprimirAutomatico = false,
    this.formatoPapel = '80mm',
    this.impresoraNombre,
    this.nombreNegocio = 'FERRETERÍA',
    this.rfcNegocio = '',
    this.direccionNegocio = '',
    this.telefonoNegocio = '',
    this.mensajePieTicket = '¡Gracias por su compra!',
  });

  ConfiguracionApp copyWith({
    int? diasHistorialSync,
    bool? autoSyncOnConnect,
    bool? tieneImpresora,
    bool? imprimirAutomatico,
    String? formatoPapel,
    String? Function()? impresoraNombre,
    String? nombreNegocio,
    String? rfcNegocio,
    String? direccionNegocio,
    String? telefonoNegocio,
    String? mensajePieTicket,
  }) {
    return ConfiguracionApp(
      diasHistorialSync: diasHistorialSync ?? this.diasHistorialSync,
      autoSyncOnConnect: autoSyncOnConnect ?? this.autoSyncOnConnect,
      tieneImpresora: tieneImpresora ?? this.tieneImpresora,
      imprimirAutomatico: imprimirAutomatico ?? this.imprimirAutomatico,
      formatoPapel: formatoPapel ?? this.formatoPapel,
      impresoraNombre:
          impresoraNombre != null ? impresoraNombre() : this.impresoraNombre,
      nombreNegocio: nombreNegocio ?? this.nombreNegocio,
      rfcNegocio: rfcNegocio ?? this.rfcNegocio,
      direccionNegocio: direccionNegocio ?? this.direccionNegocio,
      telefonoNegocio: telefonoNegocio ?? this.telefonoNegocio,
      mensajePieTicket: mensajePieTicket ?? this.mensajePieTicket,
    );
  }
}

class ConfiguracionNotifier extends AsyncNotifier<ConfiguracionApp> {
  static const _kDiasHistorial = 'dias_historial_sync';
  static const _kAutoSync = 'auto_sync_on_connect';
  static const _kTieneImpresora = 'tiene_impresora';
  static const _kImprimirAutomatico = 'imprimir_automatico';
  static const _kFormatoPapel = 'formato_papel';
  static const _kImpresoraNombre = 'impresora_nombre';
  static const _kNombreNegocio = 'nombre_negocio';
  static const _kRfcNegocio = 'rfc_negocio';
  static const _kDireccionNegocio = 'direccion_negocio';
  static const _kTelefonoNegocio = 'telefono_negocio';
  static const _kMensajePieTicket = 'mensaje_pie_ticket';

  @override
  Future<ConfiguracionApp> build() async {
    final prefs = await SharedPreferences.getInstance();
    final dias = prefs.getInt(_kDiasHistorial) ?? 30;
    final autoSync = prefs.getBool(_kAutoSync) ?? true;
    final tieneImp = prefs.getBool(_kTieneImpresora) ?? false;
    final impAuto = prefs.getBool(_kImprimirAutomatico) ?? false;
    final formato = prefs.getString(_kFormatoPapel) ?? '80mm';
    final impNombre = prefs.getString(_kImpresoraNombre);
    final nombreNeg = prefs.getString(_kNombreNegocio) ?? 'FERRETERÍA';
    final rfc = prefs.getString(_kRfcNegocio) ?? '';
    final dir = prefs.getString(_kDireccionNegocio) ?? '';
    final tel = prefs.getString(_kTelefonoNegocio) ?? '';
    final pie = prefs.getString(_kMensajePieTicket) ?? '¡Gracias por su compra!';

    return ConfiguracionApp(
      diasHistorialSync: dias,
      autoSyncOnConnect: autoSync,
      tieneImpresora: tieneImp,
      imprimirAutomatico: impAuto,
      formatoPapel: formato,
      impresoraNombre: impNombre,
      nombreNegocio: nombreNeg,
      rfcNegocio: rfc,
      direccionNegocio: dir,
      telefonoNegocio: tel,
      mensajePieTicket: pie,
    );
  }

  Future<void> setDiasHistorial(int dias) async {
    final current = state.value ?? const ConfiguracionApp();
    final updated = current.copyWith(diasHistorialSync: dias);
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDiasHistorial, dias);
  }

  Future<void> setAutoSync(bool value) async {
    final current = state.value ?? const ConfiguracionApp();
    final updated = current.copyWith(autoSyncOnConnect: value);
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoSync, value);
  }

  Future<void> setTieneImpresora(bool value) async {
    final current = state.value ?? const ConfiguracionApp();
    final updated = current.copyWith(tieneImpresora: value);
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kTieneImpresora, value);
  }

  Future<void> setImprimirAutomatico(bool value) async {
    final current = state.value ?? const ConfiguracionApp();
    final updated = current.copyWith(imprimirAutomatico: value);
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kImprimirAutomatico, value);
  }

  Future<void> setFormatoPapel(String value) async {
    final current = state.value ?? const ConfiguracionApp();
    final updated = current.copyWith(formatoPapel: value);
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFormatoPapel, value);
  }

  Future<void> setImpresoraNombre(String? value) async {
    final current = state.value ?? const ConfiguracionApp();
    final updated = current.copyWith(impresoraNombre: () => value);
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_kImpresoraNombre);
    } else {
      await prefs.setString(_kImpresoraNombre, value);
    }
  }

  Future<void> setDatosNegocio({
    String? nombre,
    String? rfc,
    String? direccion,
    String? telefono,
    String? mensajePie,
  }) async {
    final current = state.value ?? const ConfiguracionApp();
    final updated = current.copyWith(
      nombreNegocio: nombre,
      rfcNegocio: rfc,
      direccionNegocio: direccion,
      telefonoNegocio: telefono,
      mensajePieTicket: mensajePie,
    );
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    if (nombre != null) await prefs.setString(_kNombreNegocio, nombre);
    if (rfc != null) await prefs.setString(_kRfcNegocio, rfc);
    if (direccion != null) await prefs.setString(_kDireccionNegocio, direccion);
    if (telefono != null) await prefs.setString(_kTelefonoNegocio, telefono);
    if (mensajePie != null) await prefs.setString(_kMensajePieTicket, mensajePie);
  }
}

final configuracionProvider =
    AsyncNotifierProvider<ConfiguracionNotifier, ConfiguracionApp>(
  ConfiguracionNotifier.new,
);
