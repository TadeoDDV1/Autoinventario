import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sugerencia.dart';
import '../services/ia_service.dart';
import 'venta_provider.dart';

final iaServiceProvider = Provider<IaService>((ref) => IaService());

/// Provider de sugerencias del copilot. Se reevalúa cuando cambia el carrito.
/// Tiene debounce interno (300ms) para evitar spam durante el escaneo.
final copilotSugerenciasProvider =
    FutureProvider.autoDispose<SugerenciasResponse>((ref) async {
  final carrito = ref.watch(carritoProvider);
  final ids = carrito.map((item) => item.producto.id).toList();

  // Debounce para no saturar el backend
  final completer = Completer<SugerenciasResponse>();
  final timer = Timer(const Duration(milliseconds: 350), () async {
    try {
      final ia = ref.read(iaServiceProvider);
      final result = await ia.getSugerencias(carritoProductoIds: ids);
      completer.complete(result);
    } catch (e) {
      // Si la IA falla, retornar lista vacía silenciosamente
      completer.complete(
        const SugerenciasResponse(sugerencias: [], fuente: 'error'),
      );
    }
  });

  ref.onDispose(() {
    timer.cancel();
    if (!completer.isCompleted) completer.completeError(StateError('cancelled'));
  });

  return completer.future;
});

/// Ventas del día agregadas por hora (24 entradas, 0..23).
final ventasHoyPorHoraProvider =
    FutureProvider.autoDispose<List<VentaHora>>((ref) async {
  final ia = ref.read(iaServiceProvider);
  return ia.getVentasHoyPorHora();
});

/// Últimas N ventas del día (default 5).
final ventasRecientesProvider =
    FutureProvider.autoDispose<List<VentaReciente>>((ref) async {
  final ia = ref.read(iaServiceProvider);
  return ia.getVentasRecientes();
});

/// Dashboard ejecutivo. Se refresca con `ref.invalidate`.
final dashboardProvider = FutureProvider.autoDispose<DashboardResumen>((ref) async {
  final ia = ref.read(iaServiceProvider);
  return ia.getDashboardResumen();
});

/// Predicciones de inventario. Análisis que combina datos de stock + ventas
/// para estimar días restantes y sugerir reorden.
final prediccionesInventarioProvider =
    FutureProvider.autoDispose<PrediccionesResumen>((ref) async {
  final ia = ref.read(iaServiceProvider);
  return ia.getPrediccionesInventario();
});
