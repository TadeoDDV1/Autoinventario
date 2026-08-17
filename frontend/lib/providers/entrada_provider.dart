import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../models/entrada.dart';
import '../services/entrada_service.dart';

final entradaServiceProvider = Provider<EntradaService>(
  (ref) => EntradaService(),
);

/// Lista de entradas desde la BD local (offline-first).
final entradasProvider = FutureProvider<PaginatedEntradas>((ref) async {
  try {
    final db = ref.read(appDatabaseProvider);
    final entradasLocal = await db.getAllEntradas(limit: 500);
    final items = <EntradaInventario>[];
    for (final e in entradasLocal) {
      final detallesData = await db.getDetallesByEntrada(e.id);
      items.add(EntradaInventario(
        id: e.id,
        folio: e.folio ?? '',
        proveedor: e.proveedor,
        observaciones: e.observaciones,
        total: e.total,
        fecha: e.fecha,
        detalles: detallesData.map((d) => DetalleEntrada(
          entradaId: e.id,
          productoId: d.productoId,
          nombreProducto: d.nombreProducto,
          cantidad: d.cantidad,
          costoUnitario: d.costoUnitario,
        )).toList(),
      ));
    }
    return PaginatedEntradas(
      items: items,
      total: items.length,
      page: 1,
      pageSize: items.length,
      totalPages: 1,
    );
  } catch (e) {
    if (kDebugMode) debugPrint('entradasProvider local error: $e');
    return const PaginatedEntradas(items: [], total: 0, page: 1, pageSize: 20, totalPages: 0);
  }
});

/// Historial de entradas desde la BD local con filtros.
final entradaHistorialProvider =
    FutureProvider.family<PaginatedEntradas, HistorialFiltro>(
  (ref, filtro) async {
    try {
      final db = ref.read(appDatabaseProvider);
      final allEntradas = await db.getAllEntradas(limit: 1000);

      var filtered = allEntradas;

      // Filtro por fecha: desde
      if (filtro.desde != null && filtro.desde!.isNotEmpty) {
        final desdeDate = DateTime.parse(filtro.desde!);
        filtered = filtered.where((e) => !e.fecha.isBefore(desdeDate)).toList();
      }
      // Filtro por fecha: hasta
      if (filtro.hasta != null && filtro.hasta!.isNotEmpty) {
        final hastaDate = DateTime.parse(filtro.hasta!).add(const Duration(days: 1));
        filtered = filtered.where((e) => e.fecha.isBefore(hastaDate)).toList();
      }
      // Filtro por proveedor
      if (filtro.proveedor != null && filtro.proveedor!.isNotEmpty) {
        final prov = filtro.proveedor!.toLowerCase();
        filtered = filtered
            .where((e) => (e.proveedor ?? '').toLowerCase().contains(prov))
            .toList();
      }
      // Filtro por texto (q)
      if (filtro.q != null && filtro.q!.isNotEmpty) {
        final q = filtro.q!.toLowerCase();
        filtered = filtered.where((e) {
          return (e.folio ?? '').toLowerCase().contains(q) ||
              (e.proveedor ?? '').toLowerCase().contains(q) ||
              (e.observaciones ?? '').toLowerCase().contains(q);
        }).toList();
      }

      // Paginación
      final total = filtered.length;
      final totalPages = (total / filtro.pageSize).ceil();
      final start = (filtro.page - 1) * filtro.pageSize;
      final end = start + filtro.pageSize;
      final pageItems = start < total
          ? filtered.sublist(start, end > total ? total : end)
          : <EntradasLocalData>[];

      final items = <EntradaInventario>[];
      for (final e in pageItems) {
        final detallesData = await db.getDetallesByEntrada(e.id);
        items.add(EntradaInventario(
          id: e.id,
          folio: e.folio ?? '',
          proveedor: e.proveedor,
          observaciones: e.observaciones,
          total: e.total,
          fecha: e.fecha,
          detalles: detallesData.map((d) => DetalleEntrada(
            entradaId: e.id,
            productoId: d.productoId,
            nombreProducto: d.nombreProducto,
            cantidad: d.cantidad,
            costoUnitario: d.costoUnitario,
          )).toList(),
        ));
      }

      return PaginatedEntradas(
        items: items,
        total: total,
        page: filtro.page,
        pageSize: filtro.pageSize,
        totalPages: totalPages,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('entradaHistorialProvider local error: $e');
      return const PaginatedEntradas(items: [], total: 0, page: 1, pageSize: 20, totalPages: 0);
    }
  },
);

/// Entrada individual por ID desde la BD local.
final entradaByIdProvider =
    FutureProvider.family<EntradaInventario?, int>(
  (ref, id) async {
    try {
      final db = ref.read(appDatabaseProvider);
      final e = await db.getEntradaByIdLocal(id);
      if (e == null) return null;
      final detallesData = await db.getDetallesByEntrada(id);
      return EntradaInventario(
        id: e.id,
        folio: e.folio ?? '',
        proveedor: e.proveedor,
        observaciones: e.observaciones,
        total: e.total,
        fecha: e.fecha,
        detalles: detallesData.map((d) => DetalleEntrada(
          entradaId: e.id,
          productoId: d.productoId,
          nombreProducto: d.nombreProducto,
          cantidad: d.cantidad,
          costoUnitario: d.costoUnitario,
        )).toList(),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('entradaByIdProvider local error: $e');
      return null;
    }
  },
);
