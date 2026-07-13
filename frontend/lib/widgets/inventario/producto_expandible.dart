import 'package:flutter/material.dart';
import '../../core/theme/glass_tokens.dart';
import '../../models/producto.dart';
import 'conocimiento_ferreteria.dart';

Widget _detailChip(ThemeData theme, IconData icon, String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(GlassTokens.borderRadiusSmall),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class ProductoExpandible extends StatefulWidget {
  final Producto producto;

  const ProductoExpandible({super.key, required this.producto});

  @override
  State<ProductoExpandible> createState() => _ProductoExpandibleState();
}

class _ProductoExpandibleState extends State<ProductoExpandible> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = widget.producto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _expandido = !_expandido),
          borderRadius: BorderRadius.circular(GlassTokens.borderRadiusSmall),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nombre,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (p.descripcion != null && p.descripcion!.isNotEmpty)
                        Text(
                          p.descripcion!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: _expandido ? 10 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _expandido ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildExpandido(theme, p),
          crossFadeState: _expandido
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildExpandido(ThemeData theme, Producto p) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ConocimientoFerreteria.cargar(),
      builder: (context, snapshot) {
        final json = snapshot.data;
        final conocimiento = json != null
            ? ConocimientoFerreteria.buscarDescripcion(p.nombre, json)
            : null;

        final descBD = p.descripcion?.trim().isNotEmpty == true;
        final usoBD = p.uso?.trim().isNotEmpty == true;

        return Container(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (p.marca != null ||
                  p.ubicacion != null ||
                  p.sku != null) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (p.marca != null)
                      _detailChip(theme, Icons.business_center_outlined,
                          'Marca: ${p.marca}'),
                    if (p.ubicacion != null)
                      _detailChip(theme, Icons.place_outlined,
                          'Ubicación: ${p.ubicacion}'),
                    if (p.sku != null)
                      _detailChip(theme, Icons.qr_code_2, 'SKU: ${p.sku}'),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (descBD || conocimiento != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Descripción',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descBD ? p.descripcion! : conocimiento!.descripcion,
                  style: theme.textTheme.bodySmall,
                ),
              ],
              if (usoBD || (conocimiento?.usos.isNotEmpty == true && !usoBD)) ...[
                const SizedBox(height: 10),
                Text(
                  'Usos / Aplicaciones',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                if (usoBD)
                  Text(p.uso!, style: theme.textTheme.bodySmall)
                else
                  ...conocimiento!.usos.map(
                    (u) => Padding(
                      padding: const EdgeInsets.only(left: 8, top: 2),
                      child: Text(
                        '• $u',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
              ],
              if (!usoBD && conocimiento == null && !descBD)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Sin descripción o usos registrados',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              if (conocimiento?.compatibles.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                Text(
                  'Compatibles',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: conocimiento!.compatibles
                      .map((c) => Chip(
                            label: Text(c, style: const TextStyle(fontSize: 11)),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
