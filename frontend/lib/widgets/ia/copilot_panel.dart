import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/money.dart';
import '../../models/producto.dart';
import '../../models/sugerencia.dart';
import '../../providers/ia_provider.dart';
import '../../providers/producto_provider.dart';
import '../../providers/venta_provider.dart';

/// Panel colapsable de sugerencias IA en el POS.
/// Se muestra debajo del input de código, con animación de entrada/salida.
/// Reacciona automáticamente cuando cambia el carrito.
class CopilotPanel extends ConsumerStatefulWidget {
  const CopilotPanel({super.key});

  @override
  ConsumerState<CopilotPanel> createState() => _CopilotPanelState();
}

class _CopilotPanelState extends ConsumerState<CopilotPanel>
    with SingleTickerProviderStateMixin {
  bool _expanded = true;
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _agregarAlCarrito(Sugerencia sug) async {
    try {
      final api = ref.read(apiServiceProvider);
      final producto = await api.getProductoById(sug.productoId);
      if (!mounted) return;
      ref.read(carritoProvider.notifier).agregarProducto(producto);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${sug.nombre} agregado'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo agregar: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  IconData _iconForTipo(String tipo) {
    switch (tipo) {
      case 'alerta_stock':
        return Icons.warning_amber_rounded;
      case 'sustituto':
        return Icons.swap_horiz;
      default:
        return Icons.add_circle_outline;
    }
  }

  Color _colorForTipo(String tipo, ThemeData theme) {
    switch (tipo) {
      case 'alerta_stock':
        return Colors.orange.shade700;
      case 'sustituto':
        return Colors.blue.shade700;
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sugerenciasAsync = ref.watch(copilotSugerenciasProvider);
    final carritoCount = ref.watch(carritoCantidadProvider);
    final formatter = money;

    // No mostrar nada si el carrito está vacío
    if (carritoCount == 0) {
      return const SizedBox.shrink();
    }

    return sugerenciasAsync.when(
      data: (response) {
        if (response.sugerencias.isEmpty) {
          return const SizedBox.shrink();
        }
        return SizeTransition(
          sizeFactor: CurvedAnimation(parent: _anim, curve: Curves.easeOut),
          axisAlignment: -1.0,
          child: FadeTransition(
            opacity: _anim,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                    theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () => setState(() => _expanded = !_expanded),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sugerencias IA',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${response.sugerencias.length}',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (response.fuente == 'reglas_locales')
                            Tooltip(
                              message: 'Modo local: sin conexión a LLM',
                              child: Icon(
                                Icons.bolt,
                                size: 14,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          Icon(
                            _expanded ? Icons.expand_less : Icons.expand_more,
                            size: 20,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: _expanded
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            child: Column(
                              children: response.sugerencias
                                  .map((s) => _SugerenciaTile(
                                        sugerencia: s,
                                        icon: _iconForTipo(s.tipo),
                                        color: _colorForTipo(s.tipo, theme),
                                        precioFormateado:
                                            formatter.format(s.precio),
                                        onAgregar: () => _agregarAlCarrito(s),
                                      ))
                                  .toList(),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _SugerenciaTile extends StatelessWidget {
  final Sugerencia sugerencia;
  final IconData icon;
  final Color color;
  final String precioFormateado;
  final VoidCallback onAgregar;

  const _SugerenciaTile({
    required this.sugerencia,
    required this.icon,
    required this.color,
    required this.precioFormateado,
    required this.onAgregar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: theme.colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onAgregar,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sugerencia.nombre,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        sugerencia.razon,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  precioFormateado,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.add_circle,
                  color: color,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper para que un widget externo pueda agregar productos al carrito
/// sin tener que importar el provider.
Future<void> agregarProductoAlCarrito(WidgetRef ref, Producto producto) async {
  ref.read(carritoProvider.notifier).agregarProducto(producto);
}
