import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/api_config.dart';
import '../../core/widgets/atmospheric_background.dart';
import '../../core/widgets/glass_container.dart';
import '../../providers/configuracion_provider.dart';
import '../../providers/producto_provider.dart';
import '../../providers/sync_status_provider.dart';
import '../../services/sync_service.dart';

class ConfiguracionScreen extends ConsumerStatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  ConsumerState<ConfiguracionScreen> createState() =>
      _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends ConsumerState<ConfiguracionScreen> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _cargando = true;
  bool _guardando = false;
  String? _mensajeExito;

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    final host = await getSavedHost();
    final port = await getSavedPort();
    _hostController.text = host;
    _portController.text = port.toString();
    setState(() => _cargando = false);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
      _mensajeExito = null;
    });

    final host = _hostController.text.trim();
    final port = int.parse(_portController.text.trim());

    await saveApiConfig(host: host, port: port);

    // Invalidar providers para que se reconstruyan con la nueva URL
    ref.invalidate(apiServiceProvider);
    ref.read(productosProvider.notifier).refresh();
    ref.read(categoriasProvider.notifier).refresh();

    setState(() {
      _guardando = false;
      _mensajeExito = 'Configuración guardada. Reconectando...';
    });

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _mensajeExito = null);
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Configuración del Servidor'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const AtmosphericBackground(),
          if (_cargando)
            const Center(child: CircularProgressIndicator())
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.dns,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Backend Server',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'IP o hostname del computador que corre el backend.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(153),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _hostController,
                            decoration: const InputDecoration(
                              labelText: 'Host / IP',
                              hintText: '192.168.1.100',
                              prefixIcon: Icon(Icons.computer),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.url,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingresa la IP del servidor';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _portController,
                            decoration: const InputDecoration(
                              labelText: 'Puerto',
                              hintText: '8080',
                              prefixIcon: Icon(Icons.numbers),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingresa el puerto';
                              }
                              final port = int.tryParse(value.trim());
                              if (port == null || port < 1 || port > 65535) {
                                return 'Puerto inválido (1-65535)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _guardando ? null : _guardar,
                              icon: _guardando
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(
                                _guardando ? 'Guardando...' : 'Guardar',
                              ),
                            ),
                          ),
                          if (_mensajeExito != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _mensajeExito!,
                                      style: TextStyle(
                                        color: theme
                                            .colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSyncSection(theme),
                    const SizedBox(height: 16),
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Notas',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildNota(
                            theme,
                            'El celular y el computador deben estar en la misma red WiFi.',
                          ),
                          _buildNota(
                            theme,
                            'La IP del computador se puede ver con: ip addr (en Linux) o ipconfig (en Windows).',
                          ),
                          _buildNota(
                            theme,
                            'El backend debe estar corriendo en el puerto indicado.',
                          ),
                          _buildNota(
                            theme,
                            'Sincroniza regularmente para mantener los datos actualizados entre el dispositivo y el servidor.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNota(ThemeData theme, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              texto,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncSection(ThemeData theme) {
    final configAsync = ref.watch(configuracionProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final conectividad = ref.watch(conectividadProvider);
    final pendientes = ref.watch(totalPendientesProvider);
    final ejecutarSync = ref.read(ejecutarSyncManualProvider);

    final pendientesCount = pendientes.maybeWhen(
      data: (c) => c,
      orElse: () => 0,
    );

    final isSyncing = syncStatus.status == SyncStatus.sincronizando;
    final isOffline = conectividad == ConectividadEstado.offline;

    final config = configAsync.maybeWhen(
      data: (c) => c,
      orElse: () => const ConfiguracionApp(),
    );

    final ultimoSync = syncStatus.timestamp;
    String ultimoSyncStr;
    if (ultimoSync == null) {
      ultimoSyncStr = 'Nunca';
    } else {
      final diff = DateTime.now().difference(ultimoSync);
      if (diff.inMinutes < 1) {
        ultimoSyncStr = 'Hace unos segundos';
      } else if (diff.inMinutes < 60) {
        ultimoSyncStr = 'Hace ${diff.inMinutes} min';
      } else if (diff.inHours < 24) {
        ultimoSyncStr = 'Hace ${diff.inHours} h';
      } else {
        ultimoSyncStr = 'Hace ${diff.inDays} días';
      }
    }

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sync,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Sincronización',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Descarga productos, ventas y entradas del servidor. '
            'Sube operaciones realizadas offline.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 16),

          // Estado de conexión
          Row(
            children: [
              Icon(
                isOffline ? Icons.cloud_off : Icons.cloud_done,
                size: 18,
                color: isOffline ? Colors.red.shade400 : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                isOffline ? 'Sin conexión' : 'Conectado',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (pendientesCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$pendientesCount pendientes',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Días de historial
          Text(
            'Días de historial a sincronizar',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: config.diasHistorialSync,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(value: 7, child: Text('Últimos 7 días')),
              DropdownMenuItem(value: 30, child: Text('Últimos 30 días')),
              DropdownMenuItem(value: 90, child: Text('Últimos 90 días')),
              DropdownMenuItem(value: 0, child: Text('Todo el historial')),
            ],
            onChanged: isSyncing ? null : (v) {
              if (v != null) {
                ref.read(configuracionProvider.notifier).setDiasHistorial(v);
              }
            },
          ),
          const SizedBox(height: 16),

          // Última sincronización
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
              const SizedBox(width: 6),
              Text(
                'Última sincronización: $ultimoSyncStr',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Botón sincronizar
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isSyncing ? null : () => ejecutarSync(),
              icon: isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.sync),
              label: Text(isSyncing ? 'Sincronizando...' : 'Sincronizar ahora'),
            ),
          ),

          // Mensaje de resultado
          if (syncStatus.mensaje != null && !isSyncing) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: syncStatus.status == SyncStatus.error
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    syncStatus.status == SyncStatus.error
                        ? Icons.error_outline
                        : Icons.check_circle_outline,
                    size: 18,
                    color: syncStatus.status == SyncStatus.error
                        ? Colors.red
                        : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      syncStatus.mensaje!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
