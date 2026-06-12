import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/money.dart';
import '../../models/sugerencia.dart';
import '../../providers/producto_provider.dart';
import '../../providers/venta_provider.dart';

/// Recuadro inset (estilo quote-block) que muestra una sugerencia del chat IA.
///
/// Se renderiza DENTRO de la burbuja del asistente, debajo del texto principal,
/// con un borde izquierdo acentuado que indica el tipo de sugerencia.
///
/// Estados:
///   - Normal: muestra nombre, razón, precio, stock y botón "+ Agregar"
///   - Cargando: spinner mientras llama getProductoById
///   - Agregado: check verde + texto "Agregado" 1.5s
///   - Sin stock: badge rojo + botón deshabilitado
class TarjetaSugerencia extends ConsumerStatefulWidget {
  final Sugerencia sugerencia;

  const TarjetaSugerencia({super.key, required this.sugerencia});

  @override
  ConsumerState<TarjetaSugerencia> createState() => _TarjetaSugerenciaState();
}

class _TarjetaSugerenciaState extends ConsumerState<TarjetaSugerencia> {
  bool _agregando = false;
  bool _agregado = false;

  Sugerencia get s => widget.sugerencia;

  Color _colorAcento(ThemeData theme) {
    switch (s.tipo) {
      case 'alerta_stock':
        return Colors.orange.shade700;
      case 'sustituto':
        return Colors.blue.shade700;
      case 'upgrade':
        return Colors.deepPurple.shade400;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _iconoTipo() {
    switch (s.tipo) {
      case 'alerta_stock':
        return Icons.warning_amber_rounded;
      case 'sustituto':
        return Icons.swap_horiz_rounded;
      case 'upgrade':
        return Icons.trending_up_rounded;
      default:
        return Icons.lightbulb_outline;
    }
  }

  bool get _sinStock =>
      s.stockActual != null && s.stockActual! <= 0;

  Future<void> _agregar() async {
    if (_agregando || _agregado || _sinStock) return;
    setState(() => _agregando = true);
    try {
      final api = ref.read(apiServiceProvider);
      final producto = await api.getProductoById(s.productoId);
      if (!mounted) return;
      ref.read(carritoProvider.notifier).agregarProducto(producto);
      if (mounted) {
        setState(() {
          _agregado = true;
          _agregando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('${producto.nombre} agregado al carrito')),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        // Volver al estado normal después de 1.5s
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _agregado = false);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _agregando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo agregar: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorAcento = _colorAcento(theme);

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: colorAcento.withValues(alpha: 0.06),
        border: Border(
          left: BorderSide(color: colorAcento, width: 4),
          top: BorderSide(color: colorAcento.withValues(alpha: 0.2), width: 1),
          right: BorderSide(color: colorAcento.withValues(alpha: 0.2), width: 1),
          bottom: BorderSide(color: colorAcento.withValues(alpha: 0.2), width: 1),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: etiqueta + icono
            Row(
              children: [
                Icon(_iconoTipo(), size: 14, color: colorAcento),
                const SizedBox(width: 6),
                Text(
                  s.etiqueta.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colorAcento,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                if (s.nivelUrgencia == 'alto')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'URGENTE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            // Nombre del producto (bold, tappable para ver detalle)
            Text(
              s.nombre,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            // Razón en cursiva
            if (s.razon.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                s.razon,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            // Descripción (si viene del backend)
            if (s.descripcion != null && s.descripcion!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                s.descripcion!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            // Footer: precio + stock + botón
            Row(
              children: [
                // Precio
                Text(
                  money.format(s.precio),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorAcento,
                  ),
                ),
                const SizedBox(width: 10),
                // Stock
                if (s.stockActual != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _sinStock
                          ? Colors.red.shade50
                          : (s.stockActual! <= 5
                              ? Colors.orange.shade50
                              : Colors.green.shade50),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _sinStock ? 'Sin stock' : '${s.stockActual} uds',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _sinStock
                            ? Colors.red.shade700
                            : (s.stockActual! <= 5
                                ? Colors.orange.shade800
                                : Colors.green.shade800),
                      ),
                    ),
                  ),
                const Spacer(),
                // Botón + Agregar
                _BotonAgregar(
                  cargando: _agregando,
                  agregado: _agregado,
                  sinStock: _sinStock,
                  color: colorAcento,
                  onTap: _agregar,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonAgregar extends StatelessWidget {
  final bool cargando;
  final bool agregado;
  final bool sinStock;
  final Color color;
  final VoidCallback onTap;

  const _BotonAgregar({
    required this.cargando,
    required this.agregado,
    required this.sinStock,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (sinStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Sin stock',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }
    if (agregado) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 14, color: Colors.green.shade700),
            const SizedBox(width: 4),
            Text(
              'Agregado',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: cargando ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (cargando)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              else
                Icon(Icons.add, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                cargando ? '...' : 'Agregar',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
