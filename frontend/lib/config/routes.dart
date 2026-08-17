import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/animations/app_animations.dart';
import '../core/layout/breakpoints.dart';
import '../core/widgets/atmospheric_background.dart';
import '../domain/enums.dart';
import '../models/venta.dart';
import '../providers/theme_provider.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/chat/historial_chat_screen.dart';
import '../widgets/common/animated_nav_bar.dart';
import '../widgets/common/sync_button.dart';
import '../widgets/conectividad_badge.dart';
import '../widgets/stock_alert_banner.dart';
import '../screens/caja/caja_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/ventas/ticket_screen.dart';
import '../screens/ventas/historial_ventas_screen.dart';
import '../screens/inventario/inventario_screen.dart';
import '../screens/inventario/predicciones_screen.dart';
import '../screens/inventario/producto_form_screen.dart';
import '../screens/inventario/escanear_producto_screen.dart';
import '../screens/inventario/entrada_screen.dart';
import '../screens/inventario/historial_entradas_screen.dart';
import '../screens/configuracion/configuracion_screen.dart';
import '../providers/modo_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

Page<dynamic> _slideUpPage(Widget child, LocalKey? key) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionDuration: AppPageTransitions.defaultDuration,
    reverseTransitionDuration: AppPageTransitions.fastDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: AppPageTransitions.defaultCurve,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: FadeTransition(
          opacity: curvedAnimation,
          child: child,
        ),
      );
    },
  );
}

Page<dynamic> _fadeSlidePage(Widget child, LocalKey? key) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionDuration: AppPageTransitions.defaultDuration,
    reverseTransitionDuration: AppPageTransitions.fastDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: AppPageTransitions.defaultCurve,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: FadeTransition(
          opacity: curvedAnimation,
          child: child,
        ),
      );
    },
  );
}

Page<dynamic> _scaleFadePage(Widget child, LocalKey? key) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionDuration: AppPageTransitions.defaultDuration,
    reverseTransitionDuration: AppPageTransitions.fastDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: AppPageTransitions.defaultCurve,
      );
      return ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
        child: FadeTransition(
          opacity: curvedAnimation,
          child: child,
        ),
      );
    },
  );
}

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
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/caja',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CajaScreen(),
            ),
            routes: [
              GoRoute(
                path: 'ticket',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) {
                  final venta = state.extra as Venta;
                  return _fadeSlidePage(
                    TicketScreen(venta: venta),
                    state.pageKey,
                  );
                },
              ),
              GoRoute(
                path: 'historial',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) {
                  return _fadeSlidePage(
                    const HistorialVentasScreen(),
                    state.pageKey,
                  );
                },
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
                path: 'predicciones',
                pageBuilder: (context, state) {
                  return _fadeSlidePage(
                    const PrediccionesScreen(),
                    state.pageKey,
                  );
                },
              ),
              GoRoute(
                path: 'nuevo',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) {
                  return _slideUpPage(
                    const ProductoFormScreen(),
                    state.pageKey,
                  );
                },
              ),
              GoRoute(
                path: 'nuevo-rapido',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) {
                  return _slideUpPage(
                    const ProductoFormScreen(
                      mode: ProductoFormMode.rapido,
                    ),
                    state.pageKey,
                  );
                },
              ),
              GoRoute(
                path: 'escanear',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) {
                  return _scaleFadePage(
                    const EscanearProductoScreen(),
                    state.pageKey,
                  );
                },
              ),
              GoRoute(
                path: 'editar/:id',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return _slideUpPage(
                    ProductoFormScreen(productoId: id),
                    state.pageKey,
                  );
                },
              ),
              GoRoute(
                path: 'entrada',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) {
                  return _slideUpPage(
                    const EntradaScreen(),
                    state.pageKey,
                  );
                },
              ),
              GoRoute(
                path: 'entradas',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) {
                  return _fadeSlidePage(
                    const HistorialEntradasScreen(),
                    state.pageKey,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/configuracion',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return _slideUpPage(
            const ConfiguracionScreen(),
            state.pageKey,
          );
        },
      ),
      GoRoute(
        path: '/chat',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            const ChatScreen(),
            state.pageKey,
          );
        },
        routes: [
          GoRoute(
            path: 'historial',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              return _fadeSlidePage(
                const HistorialChatScreen(),
                state.pageKey,
              );
            },
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

    final navTabs = [
      const NavTab(
        icon: Icons.point_of_sale_outlined,
        selectedIcon: Icons.point_of_sale,
        label: 'Caja',
      ),
      const NavTab(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: 'Inicio',
      ),
      NavTab(
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
        label: 'Inventario',
        badge: stockAlertCount > 0 ? '$stockAlertCount' : null,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const AtmosphericBackground(),
          Row(
            children: [
              if (isWide)
                AnimatedNavRail(
                  selectedIndex: selectedIndex,
                  onTabSelected: _onDestinationSelected,
                  tabs: navTabs,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Icon(
                      Icons.hardware,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  trailing: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () =>
                              ref.read(themeProvider.notifier).toggle(context),
                          icon: Icon(_themeIcon(theme)),
                          tooltip: _themeTooltip(theme),
                        ),
                        const SyncButton(),
                        IconButton(
                          onPressed: () =>
                              context.push('/configuracion'),
                          icon: const Icon(Icons.settings),
                          tooltip: 'Configuración del servidor',
                        ),
                      ],
                    ),
                  ),
                ),
              if (isWide)
                VerticalDivider(
                  thickness: 0.5,
                  width: 0.5,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              Expanded(
                child: Column(
                  children: [
                    if (!isWide && stockAlertCount > 0)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: StockAlertBanner(),
                      ),
                    if (!isWide)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            const Expanded(child: ConectividadBadge()),
                            const SizedBox(width: 8),
                            const SyncButton(),
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: () => context.push('/configuracion'),
                              icon: const Icon(Icons.settings, size: 20),
                              tooltip: 'Configuración del servidor',
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey(
                            GoRouterState.of(context).uri.toString(),
                          ),
                          child: widget.child,
                        ),
                      ),
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
          : AnimatedBottomNavBar(
              tabs: navTabs,
              selectedIndex: selectedIndex,
              onTabSelected: _onDestinationSelected,
              borderRadius: BorderRadius.zero,
              backgroundColor: theme.colorScheme.surface,
              height: 76,
            ),
    );
  }

  IconData _themeIcon(ThemeData theme) {
    final mode = ref.watch(themeProvider);
    if (mode == AppThemeMode.system) {
      return Icons.brightness_auto;
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