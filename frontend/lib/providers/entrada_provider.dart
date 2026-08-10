import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/entrada.dart';
import '../services/entrada_service.dart';

final entradaServiceProvider = Provider<EntradaService>(
  (ref) => EntradaService(),
);

/// Lista de entradas sin filtros (paginado). Para el historial real,
/// usar [entradaHistorialProvider].
final entradasProvider = FutureProvider<PaginatedEntradas>((ref) async {
  final api = ref.read(entradaServiceProvider);
  return api.getAll();
});

final entradaHistorialProvider =
    FutureProvider.family<PaginatedEntradas, HistorialFiltro>(
  (ref, filtro) async {
    final api = ref.read(entradaServiceProvider);
    return api.getHistorial(filtro);
  },
);

/// Entrada individual por ID. Usado por la pantalla de detalle
/// cuando se abre un bottom sheet sobre una entrada específica.
final entradaByIdProvider =
    FutureProvider.family<EntradaInventario, int>(
  (ref, id) async {
    final api = ref.read(entradaServiceProvider);
    return api.getById(id);
  },
);
