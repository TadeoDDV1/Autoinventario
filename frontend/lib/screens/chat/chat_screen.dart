import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/glass_tokens.dart';
import '../../core/widgets/atmospheric_background.dart';
import '../../core/widgets/glass_container.dart';
import '../../providers/venta_provider.dart';
import '../../services/chat_ejecutivo_service.dart';
import '../../widgets/chat/burbuja_asistente.dart';
import '../../widgets/chat/burbuja_escribiendo.dart';

/// Chat IA conversacional de la ferretería.
///
/// v3 (plan 2026-06-18): usa el endpoint `/ia/chat` con detección de intención,
/// persiste la sesión activa en `shared_preferences`, atajos de teclado
/// (Esc para volver, Ctrl+Enter para enviar), y la nueva burbuja del asistente
/// con header/footer/acciones (Copiar) y burbuja de "escribiendo…".
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _inputFocus = FocusNode();
  final _service = ChatEjecutivoService();
  final List<ChatMensaje> _mensajes = [];
  final List<ChatRespuesta> _respuestas = []; // paralelo a _mensajes (asistente)
  bool _cargando = false;
  bool _iaActiva = false;
  // Nota: _fuenteIA se mantiene por compatibilidad con versiones previas
  // del UI; la burbuja del asistente ahora muestra la fuente por respuesta.
  // ignore: unused_field
  String _fuenteIA = 'reglas_locales';
  // Para rehacer: guardamos el último mensaje del usuario.
  String? _ultimoMensajeUsuario;

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
    _cargarSesionActiva();
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

  /// Re-hidrata la sesión activa (última conversación en curso) si existe.
  Future<void> _cargarSesionActiva() async {
    final sesion = await _service.cargarSesionActiva();
    if (!mounted || sesion == null || sesion.mensajes.isEmpty) return;
    // Reemplazar el mensaje de bienvenida sólo si hay algo real.
    setState(() {
      _mensajes
        ..clear()
        ..addAll(sesion.mensajes);
      _respuestas
        ..clear()
        ..addAll(sesion.respuestas);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
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

  /// Persiste la conversación en curso después de cada mensaje.
  void _persistirSesion() {
    _service.guardarSesionActiva(
      mensajes: _mensajes,
      respuestas: _respuestas,
    );
  }

  /// Limpia la sesión activa y vuelve al mensaje de bienvenida.
  Future<void> _borrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Borrar conversación?'),
        content: const Text(
          'Se perderán los mensajes de esta conversación. '
          'El historial de conversaciones anteriores se mantiene.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    await _service.borrarSesionActiva();
    setState(() {
      _mensajes
        ..clear()
        ..add(ChatMensaje(
          esUsuario: false,
          texto: '👋 Hola, soy tu asistente de ferretería.\n\n'
              'Pregúntame sobre recomendaciones, usos, comparaciones o inventario.\n\n'
              'Toca una sugerencia rápida o escribe tu pregunta 👇',
        ));
      _respuestas.clear();
      _ultimoMensajeUsuario = null;
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  Future<void> _enviar([String? textoForzado]) async {
    final txt = (textoForzado ?? _input.text).trim();
    if (txt.isEmpty || _cargando) return;
    setState(() {
      _mensajes.add(ChatMensaje(texto: txt, esUsuario: true));
      _ultimoMensajeUsuario = txt;
      _cargando = true;
      _input.clear();
    });
    _scrollToEnd();

    // Historial previo (últimos 6 pares = 12 mensajes aprox)
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
    _persistirSesion();
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

  /// Atajo Ctrl+Enter / Esc vía KeyEvent (a nivel de Scaffold).
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    // Esc → volver
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/dashboard');
      }
      return KeyEventResult.handled;
    }
    // Ctrl+Enter → enviar
    final isCtrl = HardwareKeyboard.instance.isControlPressed;
    if (isCtrl && event.logicalKey == LogicalKeyboardKey.enter) {
      _enviar();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
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
          if (_mensajes.length > 1)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Borrar conversación actual',
              onPressed: _borrarSesion,
            ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historial',
            onPressed: () => context.push('/chat/historial'),
          ),
        ],
      ),
      body: Stack(
        children: [
          const AtmosphericBackground(),
          Focus(
            autofocus: true,
            onKeyEvent: _onKey,
            child: Column(
              children: [
                // Quick prompts (sólo al inicio, cuando sólo hay el mensaje de bienvenida)
                if (_mensajes.length <= 1) ...[
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    borderRadius: GlassTokens.borderRadiusSmall,
                    blur: GlassTokens.blurSmall,
                    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
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
                      if (msg.esUsuario) {
                        return _BurbujaUsuario(texto: msg.texto);
                      }
                      // Es respuesta del asistente: la nueva BurbujaAsistente.
                      // índice de respuesta = i ~/ 2 (los pares usuario+asistente).
                      final respuesta = _respuestas.elementAtOrNull(i ~/ 2);
                      final esUltima = i == _mensajes.length - 1;
                      return BurbujaAsistente(
                        mensaje: msg,
                        respuesta: respuesta,
                        onRehacer: _ultimoMensajeUsuario == null
                            ? null
                            : () => _enviar(_ultimoMensajeUsuario),
                        esUltima: esUltima,
                      );
                    },
                  ),
                ),
                // Esqueleto "escribiendo…"
                if (_cargando) const BurbujaEscribiendo(),

                GlassContainer(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  borderRadius: 0,
                  blur: GlassTokens.blurSmall,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          focusNode: _inputFocus,
                          onSubmitted: (_) => _enviar(),
                          decoration: InputDecoration(
                            hintText: 'Pregúntame algo…  (Ctrl+Enter)',
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
          ),
        ],
      ),
    );
  }
}

/// Burbuja del usuario (lado derecho). Sin cambios respecto a v2.
class _BurbujaUsuario extends StatelessWidget {
  final String texto;
  const _BurbujaUsuario({required this.texto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: SelectableText(
                  texto,
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(
                Icons.person,
                size: 16,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
