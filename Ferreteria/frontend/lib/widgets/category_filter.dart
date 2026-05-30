import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/categoria.dart';

class CategoryFilter extends StatelessWidget {
  final List<Categoria> categorias;
  final int? selectedCategoriaId;
  final ValueChanged<int?> onSelected;

  const CategoryFilter({
    super.key,
    required this.categorias,
    this.selectedCategoriaId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('Todos'),
                  selected: selectedCategoriaId == null,
                  onSelected: (_) => onSelected(null),
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: theme.colorScheme.primaryContainer,
                  checkmarkColor: theme.colorScheme.onPrimaryContainer,
                  labelStyle: TextStyle(
                    color: selectedCategoriaId == null
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                    fontWeight: selectedCategoriaId == null
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              ...categorias.map((cat) {
                final isSelected = selectedCategoriaId == cat.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat.nombre),
                    selected: isSelected,
                    onSelected: (_) => onSelected(isSelected ? null : cat.id),
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.primaryContainer,
                    checkmarkColor: theme.colorScheme.onPrimaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 250.ms)
        .slideX(begin: -0.05, end: 0, duration: 250.ms);
  }
}
