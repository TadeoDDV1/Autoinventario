import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/atmospheric_background.dart';

/// Pantalla mostrada cuando el router recibe una ruta inexistente.
///
/// Sin esto, `context.go('/ruta-que-no-existe')` lanzaba la excepción
/// *"No routes for location"* y la app se quedaba en blanco (pantalla negra).
class RouteNotFoundScreen extends StatelessWidget {
  final String location;

  const RouteNotFoundScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Página no encontrada')),
      body: Stack(
        children: [
          const AtmosphericBackground(),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.explore_off_outlined,
                      size: 72,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No encontramos esa sección',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'La ruta "$location" no existe o cambió de lugar.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.go('/caja'),
                      icon: const Icon(Icons.point_of_sale),
                      label: const Text('Ir a Caja'),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => context.go('/dashboard'),
                      icon: const Icon(Icons.dashboard_outlined),
                      label: const Text('Ir al Inicio'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
