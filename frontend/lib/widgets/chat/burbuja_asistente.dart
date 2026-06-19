import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/sugerencia.dart';
import '../../services/chat_ejecutivo_service.dart';
import 'markdown_chat.dart';
import 'tarjeta_sugerencia.dart';

/// Burbuja del asistente IA — refactor del `_Burbuja` del chat viejo.
///
/// Estructura:
/// ```
/// ┌─ Avatar (robot) ─┐
/// │                  │
/// │  [Header] nombre · fuente · timestamp     [🔄]
/// │  ─────────────────────────────────────────
/// │  MarkdownChat(texto)  (párrafos, bullets, **bold**, *italic*, `code`)
/// │  ─────────────────────────────────────────
/// │  📦 Productos relacionados (N)
/// │  [TarjetaSugerencia]
/// │  [TarjetaSugerencia]
/// │  ─────────────────────────────────────────
/// │  [Footer] fuente · intención
/// │  [Acciones] 📋 Copiar
/// └──────────────────┘
/// ```
class BurbujaAsistente extends StatelessWidget {
  final ChatMensaje mensaje;
  final ChatRespuesta? respuesta;
  final VoidCallback? onRehacer;
  final bool esUltima;

  const BurbujaAsistente({
    super.key,
    required this.mensaje,
    this.respuesta,
    this.onRehacer,
    this.esUltima = false,
  });

  String _timestampRelativo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 5) return 'ahora';
    if (diff.inSeconds < 60) return 'hace ${diff.inSeconds}s';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    return '${t.day}/${t.month}';
  }

  String _etiquetaFuente(String fuente) {
    switch (fuente) {
      case 'llm':
        return 'LLM';
      case 'reglas':
      case 'reglas_locales':
        return 'Local';
      default:
        return fuente.isEmpty ? 'Local' : fuente;
    }
  }

  IconData _iconoFuente(String fuente) =>
      fuente == 'llm' ? Icons.psychology : Icons.bolt;

  Color _colorFuente(BuildContext context, String fuente) =>
      fuente == 'llm' ? Colors.deepPurple : Theme.of(context).colorScheme.outline;

  Future<void> _copiar(BuildContext context) async {
    final texto = respuesta?.texto ?? mensaje.texto;
    await Clipboard.setData(ClipboardData(text: texto));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Copiado al portapapeles'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fuente = respuesta?.fuente ?? 'reglas_locales';
    final intencion = respuesta?.intencion ?? '';
    final sugerencias = respuesta?.sugerencias ?? const <Sugerencia>[];

    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Burbuja principal ──
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border(
                  left: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 6, 4),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Asistente Ferretería',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          ' · ${_etiquetaFuente(fuente)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _colorFuente(context, fuente),
                          ),
                        ),
                        Text(
                          ' · ${_timestampRelativo(mensaje.timestamp)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const Spacer(),
                        if (onRehacer != null && esUltima)
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 16),
                            tooltip: 'Rehacer la última pregunta',
                            visualDensity: VisualDensity.compact,
                            onPressed: onRehacer,
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, indent: 14, endIndent: 14),
                  // Cuerpo markdown
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                    child: MarkdownChat(
                      texto: mensaje.texto,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  // Sugerencias con divisor y header
                  if (sugerencias.isNotEmpty) ...[
                    const Divider(height: 1, indent: 14, endIndent: 14),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_basket_outlined,
                            size: 14,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Productos relacionados (${sugerencias.length})',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: sugerencias
                            .map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: TarjetaSugerencia(sugerencia: s),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                  // Footer + acciones
                  const Divider(height: 1, indent: 14, endIndent: 14),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                    child: Row(
                      children: [
                        Icon(
                          _iconoFuente(fuente),
                          size: 12,
                          color: _colorFuente(context, fuente),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _etiquetaFuente(fuente),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _colorFuente(context, fuente),
                          ),
                        ),
                        if (intencion.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            '· $intencion',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _copiar(context),
                          icon: const Icon(Icons.copy, size: 12),
                          label: const Text('Copiar', style: TextStyle(fontSize: 11)),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
