import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/caja_sesion_provider.dart';
import '../providers/caja_sesion_service_provider.dart';
import '../services/cache_service.dart';
import '../services/sync_service.dart';

class ConectividadBadge extends ConsumerWidget {
  const ConectividadBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(conectividadProvider);
    final colaAsync = ref.watch(colaVentasCountProvider);
    final sseConnected = ref.watch(sseConnectedProvider);
    final sesion = ref.watch(cajaSesionEstadoProvider);

    final colaCount = colaAsync.maybeWhen(data: (n) => n, orElse: () => 0);

    final hasSse = sseConnected;
    final deviceCount = sesion?.devices ?? 0;

    if (estado == ConectividadEstado.online && colaCount == 0 && !hasSse) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[];

    if (hasSse) {
      children.add(_chip('SSE ${deviceCount > 1 ? "($deviceCount)" : ""}', Colors.green));
    } else {
      children.add(_chip('SSE', Colors.orange));
    }

    switch (estado) {
      case ConectividadEstado.offline:
        children.add(_chip(
          colaCount > 0 ? '$colaCount pend' : 'offline',
          Colors.orange,
        ));
        break;
      case ConectividadEstado.sincronizando:
        children.add(_chip(colaCount > 0 ? 'sync $colaCount' : 'sync', Colors.blue));
        break;
      case ConectividadEstado.online:
        if (colaCount > 0) {
          children.add(_chip('$colaCount pend', Colors.amber));
        }
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _forzarSync(ref),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _chip(String texto, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            texto,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _forzarSync(WidgetRef ref) {
    ref.read(conectividadProvider.notifier).sincronizarAhora();
  }
}
