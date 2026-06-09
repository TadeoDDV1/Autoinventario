import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/chat_ejecutivo_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _service = ChatEjecutivoService();
  final List<ChatMensaje> _mensajes = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _mensajes.add(ChatMensaje(
      esUsuario: false,
      texto: '👋 Hola, soy tu asistente ejecutivo. '
          'Pregúntame sobre tus ventas, inventario o predicciones.\n\n'
          'Escribe "ayuda" para ver qué puedo hacer.',
    ));
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

    final resp = await _service.enviar(txt);
    if (!mounted) return;
    setState(() {
      _mensajes.add(ChatMensaje(texto: resp.texto, esUsuario: false));
      _cargando = false;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente Ejecutivo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _mensajes.length,
              itemBuilder: (ctx, i) => _Burbuja(msg: _mensajes[i]),
            ),
          ),
          if (_cargando)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
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
  const _Burbuja({required this.msg});

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
          child: SelectableText(
            msg.texto,
            style: TextStyle(color: textColor, height: 1.35),
          ),
        ),
      ),
    );
  }
}
