import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sync_service.dart';

enum SyncStatus { idle, sincronizando, exito, error }

class SyncStatusState {
  final SyncStatus status;
  final String? mensaje;
  final DateTime? timestamp;
  final int ventasSubidas;
  final int entradasSubidas;
  final int productosSubidos;
  final int ventasDescargadas;
  final int entradasDescargadas;
  final int productosDescargados;

  const SyncStatusState({
    this.status = SyncStatus.idle,
    this.mensaje,
    this.timestamp,
    this.ventasSubidas = 0,
    this.entradasSubidas = 0,
    this.productosSubidos = 0,
    this.ventasDescargadas = 0,
    this.entradasDescargadas = 0,
    this.productosDescargados = 0,
  });

  SyncStatusState copyWith({
    SyncStatus? status,
    String? mensaje,
    DateTime? timestamp,
    int? ventasSubidas,
    int? entradasSubidas,
    int? productosSubidos,
    int? ventasDescargadas,
    int? entradasDescargadas,
    int? productosDescargados,
  }) {
    return SyncStatusState(
      status: status ?? this.status,
      mensaje: mensaje ?? this.mensaje,
      timestamp: timestamp ?? this.timestamp,
      ventasSubidas: ventasSubidas ?? this.ventasSubidas,
      entradasSubidas: entradasSubidas ?? this.entradasSubidas,
      productosSubidos: productosSubidos ?? this.productosSubidos,
      ventasDescargadas: ventasDescargadas ?? this.ventasDescargadas,
      entradasDescargadas: entradasDescargadas ?? this.entradasDescargadas,
      productosDescargados: productosDescargados ?? this.productosDescargados,
    );
  }

  int get totalSubidos => ventasSubidas + entradasSubidas + productosSubidos;
  int get totalDescargados => ventasDescargadas + entradasDescargadas + productosDescargados;
}

class SyncStatusNotifier extends Notifier<SyncStatusState> {
  @override
  SyncStatusState build() => const SyncStatusState();

  void setSincronizando() {
    state = state.copyWith(
      status: SyncStatus.sincronizando,
      mensaje: 'Sincronizando...',
      ventasSubidas: 0,
      entradasSubidas: 0,
      productosSubidos: 0,
      ventasDescargadas: 0,
      entradasDescargadas: 0,
      productosDescargados: 0,
    );
  }

  void setExito({
    int ventasSubidas = 0,
    int entradasSubidas = 0,
    int productosSubidos = 0,
    int ventasDescargadas = 0,
    int entradasDescargadas = 0,
    int productosDescargados = 0,
  }) {
    state = state.copyWith(
      status: SyncStatus.exito,
      timestamp: DateTime.now(),
      ventasSubidas: ventasSubidas,
      entradasSubidas: entradasSubidas,
      productosSubidos: productosSubidos,
      ventasDescargadas: ventasDescargadas,
      entradasDescargadas: entradasDescargadas,
      productosDescargados: productosDescargados,
    );
    _construirMensaje();
  }

  void setError(String mensaje) {
    state = state.copyWith(
      status: SyncStatus.error,
      mensaje: mensaje,
      timestamp: DateTime.now(),
    );
  }

  void reset() {
    state = const SyncStatusState();
  }

  void _construirMensaje() {
    final sub = state.totalSubidos;
    final desc = state.totalDescargados;
    final parts = <String>[];
    if (sub > 0) parts.add('$sub subidos');
    if (desc > 0) parts.add('$desc descargados');
    final msg = parts.isEmpty ? 'Sincronización completa' : 'Sync: ${parts.join(', ')}';
    state = state.copyWith(mensaje: msg);
  }
}

final syncStatusProvider =
    NotifierProvider<SyncStatusNotifier, SyncStatusState>(
  SyncStatusNotifier.new,
);

/// Provider que ejecuta la sincronización manual completa.
final ejecutarSyncManualProvider = Provider<Future<SyncStatusState> Function()>((ref) {
  return () async {
    final notifier = ref.read(syncStatusProvider.notifier);
    notifier.setSincronizando();
    try {
      final sync = ref.read(conectividadProvider.notifier);
      final result = await sync.sincronizarCompleto();
      if (kDebugMode) debugPrint('Sync manual: $result');
      notifier.setExito(
        ventasSubidas: result['ventas_subidas'] ?? 0,
        entradasSubidas: result['entradas_subidas'] ?? 0,
        productosSubidos: result['productos_subidos'] ?? 0,
        ventasDescargadas: result['ventas_descargadas'] ?? 0,
        entradasDescargadas: result['entradas_descargadas'] ?? 0,
        productosDescargados: result['productos_descargados'] ?? 0,
      );
      ref.invalidate(totalPendientesProvider);
      return ref.read(syncStatusProvider);
    } catch (e) {
      notifier.setError(e.toString());
      return ref.read(syncStatusProvider);
    }
  };
});
