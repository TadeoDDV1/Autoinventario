import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/venta.dart';
import '../screens/inventario/inventario_screen.dart';
import '../screens/inventario/producto_form_screen.dart';
import '../screens/ventas/pos_screen.dart';
import '../screens/ventas/cobros_screen.dart';
import '../screens/ventas/ticket_screen.dart';
import '../screens/ventas/historial_ventas_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/ventas',
    routes: [
      GoRoute(
        path: '/ventas',
        builder: (context, state) => const PosScreen(),
        routes: [
          GoRoute(
            path: 'cobros',
            builder: (context, state) => const CobrosScreen(),
          ),
          GoRoute(
            path: 'ticket',
            builder: (context, state) {
              final venta = state.extra as Venta;
              return TicketScreen(venta: venta);
            },
          ),
          GoRoute(
            path: 'historial',
            builder: (context, state) => const HistorialVentasScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/inventario',
        builder: (context, state) => const InventarioScreen(),
        routes: [
          GoRoute(
            path: 'nuevo',
            builder: (context, state) => const ProductoFormScreen(),
          ),
          GoRoute(
            path: 'editar/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return ProductoFormScreen(productoId: id);
            },
          ),
        ],
      ),
    ],
  );
});
