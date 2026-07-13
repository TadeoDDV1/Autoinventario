import 'package:flutter/material.dart';

import '../../core/theme/glass_tokens.dart';
import '../../core/widgets/glass_container.dart';

/// Sección visual reutilizable para el formulario de producto.
///
/// Renderiza un título con barrita de color primaria y un [GlassContainer]
/// envolviendo los children. Usado por `ProductoFormScreen` para mantener
/// consistencia visual entre las secciones (Identificación, Descripción,
/// Categoría/Ubicación, Precios, Stock).
class ProductoFormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final String? subtitle;

  const ProductoFormSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      borderRadius: GlassTokens.borderRadiusMedium,
      blur: GlassTokens.blurSmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}