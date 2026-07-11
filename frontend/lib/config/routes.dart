import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/layout/breakpoints.dart';
import '../core/theme/glass_tokens.dart';
import '../core/widgets/atmospheric_background.dart';
import '../core/widgets/glass_container.dart';
import '../domain/enums.dart';
import '../models/venta.dart';
import '../providers/theme_provider.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/chat/historial_chat_screen.dart';
import '../widgets/ia/fuente_ia_badge.dart';
import '../screens/caja/caja_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/ventas/ticket_screen.dart';
import '../screens/ventas/historial_ventas_screen.dart';
import '../screens/inventario/inventario_screen.dart';
import '../screens/inventario/predicciones_screen.dart';
import '../screens/inventario/producto_form_screen.dart';
import '../screens/inventario/escanear_producto_screen.dart';
import '../widgets/conectividad_badge.dart';
import '../widgets/stock_alert_banner.dart';
import '../providers/modo_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/caja',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          // Dashboard (inicio)
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          // Modo Caja
          GoRoute(
            path: '/caja',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CajaScreen(),
            ),
            routes: [
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
          // Modo Inventario
          GoRoute(
            path: '/inventario',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InventarioScreen(),
            ),
            routes: [
              GoRoute(
                path: 'predicciones',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PrediccionesScreen(),
                ),
              ),
              GoRoute(
                path: 'nuevo',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const ProductoFormScreen(),
              ),
              GoRoute(
                path: 'nuevo-rapido',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const ProductoFormScreen(
                  mode: ProductoFormMode.rapido,
                ),
              ),
              GoRoute(
                path: 'escanear',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const EscanearProductoScreen(),
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
      // Chat ejecutivo (full-screen, fuera del shell)
      GoRoute(
        path: '/chat',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChatScreen(),
        routes: [
          GoRoute(
            path: 'historial',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const HistorialChatScreen(),
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
    if (location.startsWith('/dashboard')) return 1;
    if (location.startsWith('/inventario')) return 2;
    return 0;
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        context.go('/caja');
        ref.read(modoAppProvider.notifier).setModo(ModoApp.caja);
        break;
      case 1:
        context.go('/dashboard');
        ref.read(modoAppProvider.notifier).setModo(ModoApp.caja);
        break;
      case 2:
        context.go('/inventario');
        ref.read(modoAppProvider.notifier).setModo(ModoApp.inventario);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isWide = Breakpoints.isDesktop(width);
    final selectedIndex = _getSelectedIndex(context);
    final stockAlertCount = ref.watch(stockAlertCountProvider);
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.point_of_sale_outlined),
        selectedIcon: const Icon(Icons.point_of_sale),
        label: 'Caja',
      ),
      NavigationDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard),
        label: 'Inicio',
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
      body: Stack(
        children: [
          const AtmosphericBackground(),
          Row(
            children: [
              if (isWide)
                GlassContainer(
                  width: 80,
                  height: double.infinity,
                  borderRadius: 0,
                  blur: GlassTokens.blurSmall,
                  child: NavigationRail(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: _onDestinationSelected,
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: Colors.transparent,
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Icon(
                        Icons.hardware,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    trailing: Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: IconButton(
                            onPressed: () =>
                                ref.read(themeProvider.notifier).toggle(context),
                            icon: Icon(_themeIcon(theme)),
                            tooltip: _themeTooltip(theme),
                          ),
                        ),
                      ),
                    ),
                    destinations: railDestinations,
                  ),
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
                    if (!isWide)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ConectividadBadge(),
                      ),
                    Expanded(
                      child: widget.child,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : GlassContainer(
              borderRadius: GlassTokens.borderRadiusLarge,
              blur: GlassTokens.blurMedium,
              borderColor: Colors.transparent,
              customDecoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(GlassTokens.borderRadiusLarge),
                  topRight: Radius.circular(GlassTokens.borderRadiusLarge),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (stockAlertCount == 0) const ConectividadBadge(),
                  NavigationBar(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: _onDestinationSelected,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    destinations: destinations,
                  ),
                ],
              ),
            ),
    );
  }

  IconData _themeIcon(ThemeData theme) {
    final mode = ref.watch(themeProvider);
    if (mode == AppThemeMode.system) {
      return theme.brightness == Brightness.dark
          ? Icons.brightness_auto
          : Icons.brightness_auto;
    }
    return mode == AppThemeMode.dark
        ? Icons.dark_mode
        : Icons.light_mode;
  }

  String _themeTooltip(ThemeData theme) {
    final mode = ref.watch(themeProvider);
    return switch (mode) {
      AppThemeMode.system => 'Tema: Sistema (toca para cambiar)',
      AppThemeMode.light => 'Tema: Claro (toca para oscuro)',
      AppThemeMode.dark => 'Tema: Oscuro (toca para sistema)',
    };
  }
}