import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/money.dart';
import '../../models/sugerencia.dart';
import '../../providers/producto_provider.dart';
import '../../providers/venta_provider.dart';

/// Chip tappable que muestra un producto sugerido por la IA.
/// Al tocarlo, agrega el producto al carrito (vía getProductoById) y muestra
/// confirmación visual.
class SugerenciaChip extends ConsumerStatefulWidget {
  final Sugerencia sugerencia;
  final VoidCallback? onAgregado;

  const SugerenciaChip({super.key, required this.sugerencia, this.onAgregado});

  @override
  ConsumerState<SugerenciaChip> createState() => _SugerenciaChipState();
}

class _SugerenciaChipState extends ConsumerState<SugerenciaChip> {
  bool _agregando = false;

  IconData _iconForTipo() {
    switch (widget.sugerencia.tipo) {
      case 'alerta_stock':
        return Icons.warning_amber_rounded;
      case 'sustituto':
        return Icons.swap_horiz;
      default:
        return Icons.add_circle_outline;
    }
  }

  Color _colorForTipo(ThemeData theme) {
    switch (widget.sugerencia.tipo) {
      case 'alerta_stock':
        return Colors.orange.shade700;
      case 'sustituto':
        return Colors.blue.shade700;
      default:
        return theme.colorScheme.primary;
    }
  }

  Future<void> _agregar() async {
    if (_agregando) return;
    setState(() => _agregando = true);
    try {
      final api = ref.read(apiServiceProvider);
      final producto = await api.getProductoById(widget.sugerencia.productoId);
      if (!mounted) return;
      ref.read(carritoProvider.notifier).agregarProducto(producto);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${producto.nombre} agregado al carrito'),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      widget.onAgregado?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo agregar: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _agregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForTipo(theme);
    return InkWell(
      onTap: _agregando ? null : _agregar,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _agregando
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                : Icon(_iconForTipo(), color: color, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '${widget.sugerencia.nombre} · ${money.format(widget.sugerencia.precio)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
