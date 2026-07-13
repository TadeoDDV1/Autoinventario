import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/entrada.dart';
import '../services/entrada_service.dart';

final entradaServiceProvider = Provider<EntradaService>((ref) => EntradaService());

final entradasProvider = FutureProvider<List<EntradaInventario>>((ref) async {
  final api = ref.read(entradaServiceProvider);
  return api.getAll();
});

final entradaHistorialProvider =
    FutureProvider.family<List<EntradaInventario>, HistorialFiltro>(
  (ref, filtro) async {
    final api = ref.read(entradaServiceProvider);
    return api.getHistorial(
      desde: filtro.desde,
      hasta: filtro.hasta,
      page: filtro.page,
    );
  },
);

class HistorialFiltro {
  final String? desde;
  final String? hasta;
  final int page;

  const HistorialFiltro({this.desde, this.hasta, this.page = 1});
}