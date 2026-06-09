import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/cache_service.dart';
import '../services/sync_service.dart';

/// Badge flotante que muestra el estado de conectividad + cantidad de
/// ventas pendientes de sincronizar. Clickable para forzar sync.
class ConectividadBadge extends ConsumerWidget {
  const ConectividadBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(conectividadProvider);
    final colaAsync = ref.watch(colaVentasCountProvider);

    final colaCount = colaAsync.maybeWhen(data: (n) => n, orElse: () => 0);

    // Si está online y no hay cola, no mostrar nada (evitar ruido visual)
    if (estado == ConectividadEstado.online && colaCount == 0) {
      return const SizedBox.shrink();
    }

    Color bg;
    Color fg;
    IconData icon;
    String texto;
    bool showSpinner = false;

    switch (estado) {
      case ConectividadEstado.offline:
        bg = Colors.orange.shade700;
        fg = Colors.white;
        icon = Icons.wifi_off;
        texto = colaCount > 0
            ? 'Sin conexión • $colaCount venta${colaCount == 1 ? '' : 's'} en cola'
            : 'Sin conexión';
        break;
      case ConectividadEstado.sincronizando:
        bg = Colors.blue.shade700;
        fg = Colors.white;
        icon = Icons.sync;
        texto = colaCount > 0
            ? 'Sincronizando $colaCount venta${colaCount == 1 ? '' : 's'}...'
            : 'Sincronizando...';
        showSpinner = true;
        break;
      case ConectividadEstado.online:
        bg = Colors.green.shade700;
        fg = Colors.white;
        icon = Icons.cloud_done;
        texto = colaCount > 0
            ? 'En línea • $colaCount venta${colaCount == 1 ? '' : 's'} pendiente${colaCount == 1 ? '' : 's'}'
            : 'En línea';
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
            color: bg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: bg.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showSpinner)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(fg),
                  ),
                )
              else
                Icon(icon, size: 14, color: fg),
              const SizedBox(width: 6),
              Text(
                texto,
                style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _forzarSync(WidgetRef ref) {
    ref.read(conectividadProvider.notifier).sincronizarAhora();
  }
}
