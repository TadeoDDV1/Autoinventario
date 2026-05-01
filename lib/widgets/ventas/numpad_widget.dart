import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NumpadWidget extends StatelessWidget {
  final Function(String) onNumberTap;
  final VoidCallback onClear;
  final VoidCallback onDelete;

  const NumpadWidget({
    super.key,
    required this.onNumberTap,
    required this.onClear,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttons = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '.', '0', '<<',
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(4, (row) {
          return Row(
            children: List.generate(3, (col) {
              final index = row * 3 + col;
              final value = buttons[index];

              if (value == '<<') {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _NumpadButton(
                      onTap: onDelete,
                      child: Icon(
                        Icons.backspace_outlined,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }

              if (value == '.') {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _NumpadButton(
                      onTap: () => onNumberTap('.'),
                      child: Text(
                        '.',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _NumpadButton(
                    onTap: () => onNumberTap(value),
                    child: Text(
                      value,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}

class _NumpadButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _NumpadButton({
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 64,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
