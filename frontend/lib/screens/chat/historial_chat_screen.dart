import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/glass_tokens.dart';
import '../../core/widgets/atmospheric_background.dart';
import '../../core/widgets/glass_container.dart';
import '../../services/chat_ejecutivo_service.dart';

/// Pantalla con el historial de conversaciones previas del chat IA.
/// Las conversaciones se persisten en shared_preferences (últimas 20).
class HistorialChatScreen extends ConsumerStatefulWidget {
  const HistorialChatScreen({super.key});

  @override
  ConsumerState<HistorialChatScreen> createState() => _HistorialChatScreenState();
}

class _HistorialChatScreenState extends ConsumerState<HistorialChatScreen> {
  final _service = ChatEjecutivoService();
  List<ChatConversacion> _conversaciones = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final list = await _service.cargarConversaciones();
    if (mounted) {
      setState(() {
        _conversaciones = list;
        _cargando = false;
      });
    }
  }

  Future<void> _borrarTodo() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar historial'),
        content: const Text('¿Eliminar todas las conversaciones guardadas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _service.borrarHistorial();
      await _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('dd MMM · HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial del Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_conversaciones.isNotEmpty)
            IconButton(
              onPressed: _borrarTodo,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Borrar todo',
            ),
        ],
      ),
      body: Stack(
        children: [
          const AtmosphericBackground(),
          _cargando
              ? const Center(child: CircularProgressIndicator())
              : _conversaciones.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 64, color: theme.colorScheme.outline),
                          const SizedBox(height: 16),
                          Text('Sin conversaciones guardadas',
                              style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            'Las conversaciones del chat se guardan automáticamente',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _conversaciones.length,
                      itemBuilder: (ctx, i) {
                        final conv = _conversaciones[i];
                        final firstUser = conv.mensajes
                            .firstWhere(
                              (m) => m.esUsuario,
                              orElse: () => ChatMensaje(texto: conv.titulo, esUsuario: true),
                            )
                            .texto;
                        final preview = firstUser.length > 80
                            ? '${firstUser.substring(0, 80)}…'
                            : firstUser;

                        return GlassContainer(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          borderRadius: GlassTokens.borderRadiusMedium,
                          blur: GlassTokens.blurSmall,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.chat_bubble,
                                color: theme.colorScheme.onPrimaryContainer,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              preview,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${conv.mensajes.length} mensajes · ${dateFmt.format(conv.updatedAt)}',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                            onTap: () {
                              _mostrarConversacion(ctx, conv);
                            },
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }

  void _mostrarConversacion(BuildContext context, ChatConversacion conv) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollCtrl) {
            return ListView.builder(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: conv.mensajes.length,
              itemBuilder: (_, i) {
                final m = conv.mensajes[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Align(
                    alignment: m.esUsuario ? Alignment.centerRight : Alignment.centerLeft,
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        borderRadius: GlassTokens.borderRadiusMedium,
                        blur: GlassTokens.blurSmall,
                        color: m.esUsuario
                            ? Theme.of(ctx).colorScheme.primary
                            : null,
                        child: Text(
                          m.texto,
                          style: TextStyle(
                            color: m.esUsuario
                                ? Theme.of(ctx).colorScheme.onPrimary
                                : Theme.of(ctx).colorScheme.onSurface,
                          ),
                        ),
                      ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
