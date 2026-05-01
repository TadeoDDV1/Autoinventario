import 'package:flutter/material.dart';

class ProductoSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const ProductoSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SearchBar(
      controller: controller,
      hintText: 'Buscar producto o código de barras...',
      leading: const Padding(
        padding: EdgeInsets.only(left: 12),
        child: Icon(Icons.search),
      ),
      trailing: [
        if (controller.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller.clear();
              onClear();
            },
          ),
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          tooltip: 'Escanear código',
          onPressed: () {},
        ),
      ],
      onChanged: onChanged,
      elevation: WidgetStateProperty.all(1),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 8),
      ),
      textStyle: WidgetStateProperty.all(theme.textTheme.bodyMedium),
    );
  }
}
