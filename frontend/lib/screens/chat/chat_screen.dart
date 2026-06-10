import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format/money.dart';
import '../../providers/venta_provider.dart';
import '../../services/chat_ejecutivo_service.dart';
import '../../widgets/chat/sugerencia_chip.dart';

/// Chat IA conversacional de la ferretería.
///
/// v2: Usa el endpoint `/ia/chat` con detección de intención en lenguaje
/// natural. Soporta quick-prompts, sugerencias inline tappables, indicador
/// de fuente IA (reglas vs LLM), markdown ligero y persistencia del
/// historial de conversaciones.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _service = ChatEjecutivoService();
  final List<ChatMensaje> _mensajes = [];
  final List<ChatRespuesta> _respuestas = []; // paralelo a _mensajes (los del asistente)
  bool _cargando = false;
  bool _iaActiva = false;
  String _fuenteIA = 'reglas_locales';

  // Quick prompts
  static const _quickPrompts = [
    '¿Qué le ofrezco a alguien que compra un taladro?',
    '¿Qué está por agotarse?',
    '¿Para qué sirve el teflón?',
    '¿Qué alternativas hay al PVC?',
    'Dame el resumen del día',
  ];

  @override
  void initState() {
    super.initState();
    _mensajes.add(ChatMensaje(
      esUsuario: false,
      texto: '👋 Hola, soy tu asistente de ferretería.\n\n'
          'Pregúntame sobre recomendaciones, usos, comparaciones o inventario.\n\n'
          'Toca una sugerencia rápida o escribe tu pregunta 👇',
    ));
    _cargarEstadoIA();
  }

  Future<void> _cargarEstadoIA() async {
    final estado = await _service.getEstadoIA();
    if (mounted) {
      setState(() {
        _iaActiva = estado.activo;
        _fuenteIA = estado.fuente;
      });
    }
  }

  Future<void> _toggleIA(bool activo) async {
    final ok = await _service.toggleIA(activo);
    if (ok) {
      setState(() {
        _iaActiva = activo;
        _fuenteIA = activo ? 'llm (si API key configurada)' : 'reglas_locales';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(activo
                ? '🧠 IA activada — las respuestas usarán LLM cuando esté disponible'
                : '⚡ IA en modo local (reglas determinísticas)'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final txt = _input.text.trim();
    if (txt.isEmpty || _cargando) return;
    setState(() {
      _mensajes.add(ChatMensaje(texto: txt, esUsuario: true));
      _cargando = true;
      _input.clear();
    });
    _scrollToEnd();

    // Historial previo (últimos 6)
    final historial = _mensajes.length > 12
        ? _mensajes.sublist(_mensajes.length - 12, _mensajes.length - 1)
        : _mensajes.sublist(0, _mensajes.length - 1);

    final carrito = ref.read(carritoProvider);
    final carritoIds = carrito.map((item) => item.producto.id).toList();

    final resp = await _service.enviarConversacional(
      txt,
      historial: historial,
      carritoIds: carritoIds,
    );
    if (!mounted) return;
    setState(() {
      _mensajes.add(ChatMensaje(texto: resp.texto, esUsuario: false));
      _respuestas.add(resp);
      _cargando = false;
      _fuenteIA = resp.fuente;
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _usarQuickPrompt(String prompt) {
    _input.text = prompt;
    _enviar();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente IA'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/dashboard'),
        ),
        actions: [
          // Toggle de IA
          Tooltip(
            message: _iaActiva
                ? 'IA potenciada por LLM (consume API)'
                : 'IA en modo local (sin LLM, más rápido)',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _iaActiva ? Icons.psychology : Icons.bolt,
                  size: 18,
                  color: _iaActiva ? Colors.deepPurple : theme.colorScheme.outline,
                ),
                Switch(
                  value: _iaActiva,
                  onChanged: _toggleIA,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historial',
            onPressed: () => context.push('/chat/historial'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick prompts
          if (_mensajes.length <= 1) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _quickPrompts
                    .map((p) => ActionChip(
                          label: Text(p, style: const TextStyle(fontSize: 12)),
                          onPressed: () => _usarQuickPrompt(p),
                          backgroundColor: theme.colorScheme.primaryContainer,
                        ))
                    .toList(),
              ),
            ),
          ],

          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _mensajes.length,
              itemBuilder: (ctx, i) {
                final msg = _mensajes[i];
                final respuesta = msg.esUsuario ? null : _respuestas.elementAtOrNull(i ~/ 2);
                return _Burbuja(
                  msg: msg,
                  respuesta: respuesta,
                );
              },
            ),
          ),
          if (_cargando)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  _PensandoDots(),
                  SizedBox(width: 12),
                  Text('Pensando…'),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    onSubmitted: (_) => _enviar(),
                    decoration: InputDecoration(
                      hintText: 'Pregúntame algo…',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _cargando ? null : _enviar,
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Burbuja extends StatelessWidget {
  final ChatMensaje msg;
  final ChatRespuesta? respuesta;
  const _Burbuja({required this.msg, this.respuesta});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final align = msg.esUsuario ? Alignment.centerRight : Alignment.centerLeft;
    final color = msg.esUsuario
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = msg.esUsuario
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Container(
      alignment: align,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          crossAxisAlignment:
              msg.esUsuario ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!msg.esUsuario)
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.auto_awesome,
                        size: 16, color: theme.colorScheme.onPrimaryContainer),
                  ),
                if (!msg.esUsuario) const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(msg.esUsuario ? 16 : 4),
                        bottomRight: Radius.circular(msg.esUsuario ? 4 : 16),
                      ),
                    ),
                    child: _MarkdownLight(
                      texto: msg.texto,
                      color: textColor,
                    ),
                  ),
                ),
                if (msg.esUsuario) const SizedBox(width: 8),
                if (msg.esUsuario)
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Icon(Icons.person,
                        size: 16, color: theme.colorScheme.onSecondaryContainer),
                  ),
              ],
            ),
            // Fuente IA + sugerencias (solo para respuestas del asistente)
            if (respuesta != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: respuesta!.fuente == 'llm'
                          ? Colors.deepPurple.shade50
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          respuesta!.fuente == 'llm' ? Icons.psychology : Icons.bolt,
                          size: 12,
                          color: respuesta!.fuente == 'llm'
                              ? Colors.deepPurple
                              : theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          respuesta!.fuente == 'llm'
                              ? 'LLM'
                              : (respuesta!.fuente == 'reglas' ? 'Local' : respuesta!.fuente),
                          style: TextStyle(
                            fontSize: 10,
                            color: respuesta!.fuente == 'llm'
                                ? Colors.deepPurple.shade700
                                : theme.colorScheme.outline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (respuesta!.intencion.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      '· ${respuesta!.intencion}',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
              if (respuesta!.sugerencias.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: respuesta!.sugerencias
                      .map((s) => SugerenciaChip(sugerencia: s))
                      .toList(),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Renderiza un texto con **negritas**, *cursivas*, bullets y saltos de línea.
class _MarkdownLight extends StatelessWidget {
  final String texto;
  final Color color;
  const _MarkdownLight({required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = TextStyle(color: color, height: 1.35);
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);
    final italicStyle = baseStyle.copyWith(fontStyle: FontStyle.italic);

    final lines = texto.split('\n');
    final spans = <InlineSpan>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty) {
        spans.add(const TextSpan(text: '\n'));
        continue;
      }
      // Bullets
      var remaining = line;
      bool isBullet = false;
      if (remaining.startsWith('• ') || remaining.startsWith('- ')) {
        isBullet = true;
        remaining = remaining.substring(2);
      }
      // Parsear **bold** y *italic*
      int idx = 0;
      final lineSpans = <InlineSpan>[];
      while (idx < remaining.length) {
        if (idx + 1 < remaining.length && remaining.substring(idx, idx + 2) == '**') {
          final end = remaining.indexOf('**', idx + 2);
          if (end > 0) {
            lineSpans.add(TextSpan(
              text: remaining.substring(idx + 2, end),
              style: boldStyle,
            ));
            idx = end + 2;
            continue;
          }
        }
        if (remaining[idx] == '*') {
          final end = remaining.indexOf('*', idx + 1);
          if (end > 0) {
            lineSpans.add(TextSpan(
              text: remaining.substring(idx + 1, end),
              style: italicStyle,
            ));
            idx = end + 1;
            continue;
          }
        }
        // Acumular hasta el siguiente *
        int next = idx + 1;
        while (next < remaining.length && remaining[next] != '*' && remaining.substring(next, next > remaining.length - 1 ? next : next + 1) != '**') {
          // buscar el siguiente * o **
          if (next + 1 < remaining.length && remaining[next] == '*' && remaining[next + 1] == '*') break;
          if (remaining[next] == '*') break;
          next++;
        }
        if (next == idx) next = idx + 1;
        lineSpans.add(TextSpan(text: remaining.substring(idx, next), style: baseStyle));
        idx = next;
      }

      if (isBullet) {
        spans.add(const TextSpan(text: '• '));
      }
      spans.addAll(lineSpans);
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return SelectableText.rich(
      TextSpan(style: baseStyle, children: spans),
      style: baseStyle,
    );
  }
}

class _PensandoDots extends StatefulWidget {
  const _PensandoDots();
  @override
  State<_PensandoDots> createState() => _PensandoDotsState();
}

class _PensandoDotsState extends State<_PensandoDots> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (_ctrl.value - i * 0.2) % 1.0;
            final opacity = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: opacity.clamp(0.2, 1.0)),
              ),
            );
          }),
        );
      },
    );
  }
}
