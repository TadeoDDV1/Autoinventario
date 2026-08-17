import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/sync_status_provider.dart';
import '../../services/sync_service.dart';

/// Botón de sincronización manual. Muestra un badge con el número de
/// operaciones pendientes y un indicador de estado (idle/syncing/exito/error).
class SyncButton extends ConsumerWidget {
  final bool compact;

  const SyncButton({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);
    final conectividad = ref.watch(conectividadProvider);
    final pendientes = ref.watch(totalPendientesProvider);
    final ejecutarSync = ref.read(ejecutarSyncManualProvider);

    final pendientesCount = pendientes.maybeWhen(
      data: (count) => count,
      orElse: () => 0,
    );

    final isSyncing = syncStatus.status == SyncStatus.sincronizando;
    final isOffline = conectividad == ConectividadEstado.offline;

    // Color del icono según estado
    Color iconColor;
    if (isSyncing) {
      iconColor = Colors.blue;
    } else if (isOffline) {
      iconColor = Colors.red.shade400;
    } else if (pendientesCount > 0) {
      iconColor = Colors.orange.shade600;
    } else {
      iconColor = Colors.green;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: isSyncing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  ),
                )
              : Icon(
                  isOffline ? Icons.cloud_off : Icons.cloud_sync,
                  color: iconColor,
                ),
          tooltip: isSyncing
              ? 'Sincronizando...'
              : isOffline
                  ? 'Sin conexión - $pendientesCount pendientes'
                  : pendientesCount > 0
                      ? 'Sincronizar ($pendientesCount pendientes)'
                      : 'Sincronizar',
          onPressed: isSyncing ? null : () => ejecutarSync(),
        ),
        if (pendientesCount > 0 && !isSyncing)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                pendientesCount > 99 ? '99+' : pendientesCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

/// Chip de estado de sincronización para mostrar en la pantalla de Caja.
/// Muestra el estado de conexión y permite sincronizar con un tap.
class SyncChip extends ConsumerWidget {
  const SyncChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);
    final conectividad = ref.watch(conectividadProvider);
    final pendientes = ref.watch(totalPendientesProvider);
    final ejecutarSync = ref.read(ejecutarSyncManualProvider);

    final pendientesCount = pendientes.maybeWhen(
      data: (count) => count,
      orElse: () => 0,
    );

    final isSyncing = syncStatus.status == SyncStatus.sincronizando;
    final isOffline = conectividad == ConectividadEstado.offline;

    Color chipColor;
    String label;
    IconData icon;

    if (isSyncing) {
      chipColor = Colors.blue.shade100;
      label = 'Sincronizando...';
      icon = Icons.sync;
    } else if (isOffline) {
      chipColor = Colors.red.shade100;
      label = pendientesCount > 0 ? 'Offline ($pendientesCount)' : 'Offline';
      icon = Icons.cloud_off;
    } else if (pendientesCount > 0) {
      chipColor = Colors.orange.shade100;
      label = '$pendientesCount pendientes';
      icon = Icons.cloud_upload;
    } else {
      chipColor = Colors.green.shade100;
      label = 'Online';
      icon = Icons.cloud_done;
    }

    return GestureDetector(
      onTap: isSyncing ? null : () => ejecutarSync(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isSyncing
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: chipColor.computeLuminance() > 0.5
                    ? Colors.black87
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
