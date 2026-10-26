import 'dart:async';

import 'sse_event.dart';
export 'sse_event.dart';

class EventSourceClient {
  void Function(bool connected)? onConnectionChange;

  EventSourceClient({
    Duration initialRetryDelay = const Duration(seconds: 2),
    Duration maxRetryDelay = const Duration(seconds: 30),
  });

  bool get isConnected => false;

  Stream<SSEEvent> connect(String path, {Map<String, String>? headers}) =>
      const Stream<SSEEvent>.empty();

  void dispose() {}
}
