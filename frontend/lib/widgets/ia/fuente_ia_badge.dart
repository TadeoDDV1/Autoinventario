import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/chat_ejecutivo_service.dart' show ChatEjecutivoService;

/// Provider que escucha el estado de activación del LLM.
/// Se inicializa en false y se actualiza al consultar el backend.
class IaActivaNotifier extends Notifier<bool> {
  @override
  bool build() => false;
}

final iaActivaProvider = NotifierProvider<IaActivaNotifier, bool>(IaActivaNotifier.new);

/// Badge pequeño que indica si la IA está usando reglas locales o LLM.
/// Aparece en el AppBar de Caja y Chat.
class FuenteIABadge extends ConsumerStatefulWidget {
  const FuenteIABadge({super.key});

  @override
  ConsumerState<FuenteIABadge> createState() => _FuenteIABadgeState();
}

class _FuenteIABadgeState extends ConsumerState<FuenteIABadge> {
  String _fuente = 'reglas_locales';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final estado = await ChatEjecutivoService().getEstadoIA();
    if (mounted) {
      setState(() {
        _fuente = estado.fuente;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final esLLM = _fuente.contains('llm');
    return Tooltip(
      message: esLLM
          ? 'IA potenciada por LLM (más natural, consume API)'
          : 'IA en modo local (rápido, sin API)',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: esLLM
              ? Colors.deepPurple.withValues(alpha: 0.12)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: esLLM
                ? Colors.deepPurple.withValues(alpha: 0.4)
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              esLLM ? Icons.psychology : Icons.bolt,
              size: 12,
              color: esLLM ? Colors.deepPurple : theme.colorScheme.outline,
            ),
            const SizedBox(width: 4),
            Text(
              esLLM ? 'LLM' : 'Local',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: esLLM
                    ? Colors.deepPurple.shade700
                    : theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
