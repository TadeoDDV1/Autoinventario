import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../config/api_config.dart';
import 'sse_event.dart';
export 'sse_event.dart';


class EventSourceClient {
  HttpClient? _client;
  StreamController<SSEEvent>? _controller;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  bool _disposed = false;

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

  Stream<SSEEvent> connect(String path, {Map<String, String>? headers}) {
    _controller = StreamController<SSEEvent>.broadcast(
      onCancel: () => dispose(),
    );
    _client = HttpClient();
    _disposed = false;
    _connectWithBackoff(path, headers, _initialDelay);
    return _controller!.stream;
  }

  void _connectWithBackoff(String path, Map<String, String>? headers, Duration delay) {
    if (_disposed) return;

    _startConnection(path, headers).then((_) {
      _connected = true;
      onConnectionChange?.call(true);
    }).catchError((_) {
      _connected = false;
      onConnectionChange?.call(false);
      if (_disposed) return;
      final nextDelay = Duration(
        milliseconds: (delay.inMilliseconds * 2).clamp(0, _maxDelay.inMilliseconds),
      );
      _reconnectTimer = Timer(delay, () => _connectWithBackoff(path, headers, nextDelay));
    });
  }

  Future<void> _startConnection(String path, Map<String, String>? headers) async {
    final base = apiBaseUrlSync.replaceAll('/api/v1', '');
    final uri = Uri.parse('$base$path');

    final request = await _client!.getUrl(uri);
    request.headers.set('Accept', 'text/event-stream');
    request.headers.set('Cache-Control', 'no-cache');
    request.headers.set('Connection', 'keep-alive');
    if (headers != null) {
      headers.forEach((k, v) => request.headers.set(k, v));
    }

    final response = await request.close();
    if (response.statusCode != 200) return;

    String currentEvent = 'message';
    final buf = StringBuffer();

    await for (final chunk in response.transform(utf8.decoder)) {
      if (_disposed) return;
      buf.write(chunk);

      final text = buf.toString();
      final lines = text.split('\n');
      buf.clear();

      for (final line in lines) {
        if (line.startsWith('event: ')) {
          currentEvent = line.substring(7).trim();
        } else if (line.startsWith('data: ')) {
          final dataStr = line.substring(6).trim();
          if (dataStr.isNotEmpty) {
            try {
              final data = jsonDecode(dataStr) as Map<String, dynamic>;
              _controller?.add(SSEEvent(type: currentEvent, data: data));
            } catch (_) {
              // Línea SSE sin JSON válido (evento keep-alive u otro formato)
            }
          }
          currentEvent = 'message';
        }
      }
    }
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _sub?.cancel();
    _client?.close(force: true);
    _controller?.close();
    _connected = false;
  }
}
