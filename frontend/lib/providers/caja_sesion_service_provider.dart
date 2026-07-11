import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/caja_sesion_service.dart';

final cajaSesionServiceProvider = Provider<CajaSesionService>((ref) {
  final svc = CajaSesionService();
  ref.onDispose(() => svc.dispose());
  return svc;
});

class SseConnectedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setConnected(bool v) => state = v;
}

final sseConnectedProvider =
    NotifierProvider<SseConnectedNotifier, bool>(SseConnectedNotifier.new);
