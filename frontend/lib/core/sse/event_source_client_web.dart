import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import '../../config/api_config.dart';
import 'sse_event.dart';
export 'sse_event.dart';

class EventSourceClient {
  html.EventSource? _source;
  StreamController<SSEEvent>? _controller;
  final List<StreamSubscription> _subs = [];

  final Duration _initialDelay;
  final Duration _maxDelay;
  void Function(bool connected)? onConnectionChange;

  EventSourceClient({
    Duration initialRetryDelay = const Duration(seconds: 2),
    Duration maxRetryDelay = const Duration(seconds: 30),
  })  : _initialDelay = initialRetryDelay,
        _maxDelay = maxRetryDelay;

  bool _connected = false;
  bool get isConnected => _connected;

  static const _eventTypes = [
    'item_added',
    'item_set',
    'item_removed',
    'cleared',
    'ping',
  ];

  Stream<SSEEvent> connect(String path, {Map<String, String>? headers}) {
    _controller = StreamController<SSEEvent>.broadcast(
      onCancel: () => dispose(),
    );

    final base = apiBaseUrlSync.replaceAll('/api/v1', '');
    final uri = Uri.parse('$base$path');
    final source = html.EventSource(uri.toString());
    _source = source;

    _subs.add(source.onOpen.listen((_) {
      _connected = true;
      onConnectionChange?.call(true);
    }));

    _subs.add(source.onError.listen((_) {
      _connected = false;
      onConnectionChange?.call(false);
    }));

    _subs.add(source.onMessage.listen((event) {
      _emit('message', event.data);
    }));

    for (final type in _eventTypes) {
      source.addEventListener(type, (event) {
        final message = event as html.MessageEvent;
        _emit(type, message.data);
      });
    }

    return _controller!.stream;
  }

  void _emit(String type, dynamic raw) {
    if (raw is! String || raw.isEmpty) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _controller?.add(SSEEvent(type: type, data: data));
    } catch (_) {
      // Evento sin JSON válido (keep-alive u otro formato).
    }
  }

  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();
    _source?.close();
    _source = null;
    _controller?.close();
    _connected = false;
  }
}
