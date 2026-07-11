import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/sugerencia.dart';
import '../../providers/ia_chat_bubble_provider.dart';
import '../../providers/ia_provider.dart';
import '../../providers/venta_provider.dart';
import '../../services/chat_ejecutivo_service.dart';
import '../chat/tarjeta_sugerencia.dart';

/// Burbuja de chat flotante estilo Messenger para la pantalla de caja.
///
/// Colapsada: un [CircleAvatar] con pulso animado cuando hay sugerencias no
/// leídas. Expandida: un panel con mini-chat inline, sugerencias contextuales
/// y acceso al chat completo.
class IaChatBubble extends ConsumerStatefulWidget {
  const IaChatBubble({super.key});

  @override
  ConsumerState<IaChatBubble> createState() => _IaChatBubbleState();
}

class _IaChatBubbleState extends ConsumerState<IaChatBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  int _ultimoVisto = 0;
  final List<ChatMensaje> _mensajes = [];
  final List<ChatRespuesta> _respuestas = [];
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _inputFocus = FocusNode();
  bool _cargando = false;

  static const _quickPrompts = [
    'Recomiéndame productos',
    '¿Qué más necesito?',
    'Resumen del carrito',
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _inputFocus.dispose();
    _mensajes.clear();
    _respuestas.clear();
    super.dispose();
  }

  bool get _isExpanded => ref.watch(burbujaExpandidaProvider);

  void _toggleBubble() {
    final expandido = ref.read(burbujaExpandidaProvider);
    if (!expandido) {
      final sugs = ref
              .read(copilotSugerenciasProvider)
              .asData
              ?.value
              .sugerencias ??
          [];
      _ultimoVisto = sugs.length;
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
    ref.read(burbujaExpandidaProvider.notifier).toggle();
  }

  void _closeBubble() {
    final sugs = ref
            .read(copilotSugerenciasProvider)
            .asData
            ?.value
            .sugerencias ??
        [];
    _ultimoVisto = sugs.length;
    ref.read(burbujaExpandidaProvider.notifier).close();
  }

  Future<void> _enviar([String? forzado]) async {
    final txt = (forzado ?? _inputCtrl.text).trim();
    if (txt.isEmpty || _cargando) return;

    setState(() {
      _mensajes.add(ChatMensaje(texto: txt, esUsuario: true));
      _cargando = true;
      _inputCtrl.clear();
    });
    _scrollToEnd();

    final carrito = ref.read(carritoProvider);
    final carritoIds = carrito.map((i) => i.producto.id).toList();

    final historial = _mensajes.length > 10
        ? _mensajes.sublist(_mensajes.length - 10, _mensajes.length - 1)
        : _mensajes.sublist(0, _mensajes.length - 1);

    try {
      final resp = await ChatEjecutivoService().enviarConversacional(
        txt,
        historial: historial,
        carritoIds: carritoIds,
      );
      if (!mounted) return;
      setState(() {
        _mensajes.add(ChatMensaje(texto: resp.texto, esUsuario: false));
        _respuestas.add(resp);
        _cargando = false;
      });
      _scrollToEnd();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _mensajes.add(ChatMensaje(
          texto: 'Error al obtener respuesta. Intenta de nuevo.',
          esUsuario: false,
        ));
        _cargando = false;
      });
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sugsAsync = ref.watch(copilotSugerenciasProvider);
    final carritoCount = ref.watch(carritoCantidadProvider);
    final posicion = ref.watch(burbujaPosicionProvider);

    final sugerencias = sugsAsync.asData?.value.sugerencias ?? [];
    final nuevas = sugerencias.length - _ultimoVisto;
    final hayNuevas = !_isExpanded && nuevas > 0;

    if (hayNuevas && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!hayNuevas && _pulseCtrl.isAnimating) {
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: posicion == BurbujaPosicion.bottomLeft
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        if (_isExpanded)
          _buildPanel(theme, sugerencias, carritoCount, posicion),
        const SizedBox(height: 8),
        _buildBubbleButton(theme, nuevas, posicion),
      ],
    );
  }

  Widget _buildBubbleButton(
    ThemeData theme,
    int nuevas,
    BurbujaPosicion posicion,
  ) {
    final boton = Material(
      elevation: _isExpanded ? 0 : 4,
      shape: const CircleBorder(),
      color: theme.colorScheme.tertiaryContainer,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _toggleBubble,
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          child: Icon(
            _isExpanded ? Icons.close : Icons.auto_awesome,
            color: theme.colorScheme.onTertiaryContainer,
            size: 28,
          ),
        ),
      ),
    );

    final contenido = nuevas > 0
        ? Badge(
            isLabelVisible: true,
            label: Text(
              '$nuevas',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            child: boton,
          )
        : boton;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: nuevas > 0 && !_isExpanded ? _pulseAnim.value : 1.0,
          child: child,
        );
      },
      child: contenido,
    );
  }

  Widget _buildPanel(
    ThemeData theme,
    List<Sugerencia> sugerencias,
    int carritoCount,
    BurbujaPosicion posicion,
  ) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final panelWidth = isDesktop ? 380.0 : MediaQuery.of(context).size.width * 0.92;
    final panelHeight = isDesktop
        ? 520.0
        : MediaQuery.of(context).size.height * 0.55;

    return Container(
      width: panelWidth,
      height: panelHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme, posicion),
            if (carritoCount > 0 && _mensajes.isEmpty)
              _buildSuggestionsSection(theme, sugerencias),
            Expanded(
              child: _buildChatArea(theme),
            ),
            if (_cargando) _buildTypingIndicator(theme),
            _buildInputArea(theme),
            _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, BurbujaPosicion posicion) {
    final fuente =
        ref.watch(copilotSugerenciasProvider).asData?.value.fuente ?? 'local';
    final isLlm = fuente == 'hibrido' || fuente == 'llm';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Asistente IA',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isLlm ? Colors.deepPurple.withValues(alpha: 0.15) : theme.colorScheme.outline.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLlm ? Icons.psychology : Icons.bolt,
                  size: 12,
                  color: isLlm ? Colors.deepPurple : theme.colorScheme.outline,
                ),
                const SizedBox(width: 3),
                Text(
                  isLlm ? 'LLM' : 'Local',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isLlm ? Colors.deepPurple : theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Tooltip(
            message: posicion == BurbujaPosicion.bottomRight
                ? 'Mover a izquierda'
                : 'Mover a derecha',
            child: IconButton(
              icon: const Icon(Icons.swap_horiz, size: 20),
              visualDensity: VisualDensity.compact,
              onPressed: () =>
                  ref.read(burbujaPosicionProvider.notifier).toggle(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            visualDensity: VisualDensity.compact,
            onPressed: _closeBubble,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection(
    ThemeData theme,
    List<Sugerencia> sugerencias,
  ) {
    if (sugerencias.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxHeight: 160),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Sugerencias para esta venta',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              shrinkWrap: true,
              children: sugerencias
                  .map((s) => TarjetaSugerencia(sugerencia: s))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(ThemeData theme) {
    if (_mensajes.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildWelcomeMessage(theme),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _quickPrompts
                .map((p) => ActionChip(
                      label: Text(p, style: const TextStyle(fontSize: 11)),
                      onPressed: () => _enviar(p),
                      backgroundColor: theme.colorScheme.primaryContainer,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ))
                .toList(),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(12),
      itemCount: _mensajes.length,
      itemBuilder: (_, i) {
        final msg = _mensajes[i];
        if (msg.esUsuario) {
          return _BurbujaUsuario(texto: msg.texto);
        }
        return _BurbujaAsistente(texto: msg.texto);
      },
    );
  }

  Widget _buildWelcomeMessage(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'Asistente IA',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pregúntame sobre los productos en carrito, '
            'recomendaciones o inventario.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(theme, 0),
                const SizedBox(width: 4),
                _dot(theme, 150),
                const SizedBox(width: 4),
                _dot(theme, 300),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _dot(ThemeData theme, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      builder: (_, value, child) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: value),
        ),
      ),
      onEnd: () {},
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputCtrl,
              focusNode: _inputFocus,
              onSubmitted: (_) => _enviar(),
              decoration: InputDecoration(
                hintText: 'Pregunta algo…',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                isDense: true,
              ),
              textInputAction: TextInputAction.send,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              icon: Icon(
                _cargando ? Icons.more_horiz : Icons.send,
                size: 20,
              ),
              onPressed: _cargando ? null : () => _enviar(),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return InkWell(
      onTap: () {
        _closeBubble();
        final carrito = ref.read(carritoProvider);
        final ids = carrito.map((i) => i.producto.id).toList();
        final query = ids.isEmpty ? '' : '?carrito=${ids.join(',')}';
        context.push('/chat$query');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.open_in_full,
              size: 14,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Ir al chat completo',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Burbuja de usuario (lado derecho).
class _BurbujaUsuario extends StatelessWidget {
  final String texto;
  const _BurbujaUsuario({required this.texto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            texto,
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

/// Burbuja del asistente (lado izquierdo).
class _BurbujaAsistente extends StatelessWidget {
  final String texto;
  const _BurbujaAsistente({required this.texto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(14),
            ),
          ),
          child: Text(
            texto,
            style: TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }
}
