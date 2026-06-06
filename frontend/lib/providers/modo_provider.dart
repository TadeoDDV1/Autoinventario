import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/enums.dart';

class ModoNotifier extends Notifier<ModoApp> {
  @override
  ModoApp build() => ModoApp.caja;

  void setModo(ModoApp modo) {
    state = modo;
  }
}

final modoAppProvider = NotifierProvider<ModoNotifier, ModoApp>(
  ModoNotifier.new,
);
