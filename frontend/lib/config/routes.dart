import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/venta.dart';
import '../screens/inventario/inventario_screen.dart';
import '../screens/inventario/producto_form_screen.dart';
import '../screens/ventas/pos_screen.dart';
import '../screens/ventas/cobros_screen.dart';
import '../screens/ventas/ticket_screen.dart';
import '../screens/ventas/historial_ventas_screen.dart';
import '../widgets/stock_alert_banner.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/ventas',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/ventas',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PosScreen(),
            ),
            routes: [
              GoRoute(
                path: 'cobros',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const CobrosScreen(),
              ),
              GoRoute(
                path: 'ticket',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final venta = state.extra as Venta;
                  return TicketScreen(venta: venta);
                },
              ),
              GoRoute(
                path: 'historial',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const HistorialVentasScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/inventario',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InventarioScreen(),
            ),
            routes: [
              GoRoute(
                path: 'nuevo',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const ProductoFormScreen(),
              ),
              GoRoute(
                path: 'editar/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return ProductoFormScreen(productoId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/inventario')) return 1;
    return 0;
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        context.go('/ventas');
        break;
      case 1:
        context.go('/inventario');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 800;
    final selectedIndex = _getSelectedIndex(context);
    final stockAlertCount = ref.watch(stockAlertCountProvider);

    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.point_of_sale_outlined),
        selectedIcon: const Icon(Icons.point_of_sale),
        label: 'Ventas',
      ),
      NavigationDestination(
        icon: Badge(
          isLabelVisible: stockAlertCount > 0,
          label: Text('$stockAlertCount'),
          child: const Icon(Icons.inventory_2_outlined),
        ),
        selectedIcon: Badge(
          isLabelVisible: stockAlertCount > 0,
          label: Text('$stockAlertCount'),
          child: const Icon(Icons.inventory_2),
        ),
        label: 'Inventario',
      ),
    ];

    final railDestinations = destinations
        .map((d) => NavigationRailDestination(
              icon: d.icon,
              selectedIcon: d.selectedIcon,
              label: Text(d.label),
            ))
        .toList();

    return Scaffold(
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Icon(
                  Icons.hardware,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
              destinations: railDestinations,
            ),
          if (isWide)
            const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [
                if (!isWide && stockAlertCount > 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: StockAlertBanner(),
                  ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: destinations,
            ),
    );
  }
}