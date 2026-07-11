import 'dart:async';

import 'package:dio/dio.dart';

import '../core/api/dio_client.dart';
import '../core/sse/event_source_client.dart';
import 'device_id_service.dart';

class SesionItemDTO {
  final int productoId;
  final int cantidad;
  final int version;
  final String updatedBy;

  const SesionItemDTO({
    required this.productoId,
    required this.cantidad,
    required this.version,
    required this.updatedBy,
  });

  factory SesionItemDTO.fromJson(Map<String, dynamic> json) {
    return SesionItemDTO(
      productoId: (json['producto_id'] as num).toInt(),
      cantidad: (json['cantidad'] as num).toInt(),
      version: (json['version'] as num).toInt(),
      updatedBy: json['updated_by'] as String? ?? '',
    );
  }
}

class CajaSesionEstado {
  final String sesionId;
  final int version;
  final List<SesionItemDTO> items;
  final int devices;

  const CajaSesionEstado({
    required this.sesionId,
    required this.version,
    required this.items,
    required this.devices,
  });

  factory CajaSesionEstado.fromJson(Map<String, dynamic> json) {
    return CajaSesionEstado(
      sesionId: json['sesion_id'] as String? ?? 'caja-principal',
      version: (json['version'] as num?)?.toInt() ?? 0,
      items: ((json['items'] as List<dynamic>?) ?? [])
          .map((e) => SesionItemDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      devices: (json['devices'] as num?)?.toInt() ?? 0,
    );
  }
}

class ModifyResp {
  final int version;
  final List<SesionItemDTO> items;
  final bool confirmed;

  const ModifyResp({
    required this.version,
    required this.items,
    required this.confirmed,
  });

  factory ModifyResp.fromJson(Map<String, dynamic> json) {
    return ModifyResp(
      version: (json['version'] as num).toInt(),
      items: ((json['items'] as List<dynamic>?) ?? [])
          .map((e) => SesionItemDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      confirmed: json['confirmed'] as bool? ?? true,
    );
  }
}

class CajaSesionService {
  final Dio _dio;
  final DeviceIDService _deviceIdService;
  EventSourceClient? _sseClient;
  StreamSubscription? _sseSub;
  String? _deviceId;

  /// Stream de eventos SSE que cualquier provider puede escuchar.
  final StreamController<SSEEvent> _eventController =
      StreamController<SSEEvent>.broadcast();
  Stream<SSEEvent> get events => _eventController.stream;

  bool _connected = false;
  bool get isConnected => _connected;

  void Function(bool connected)? onConnectionChange;

  CajaSesionService({Dio? dio})
      : _dio = dio ?? DioClient().dio,
        _deviceIdService = DeviceIDService();

  Future<String> _getDeviceId() async {
    _deviceId ??= await _deviceIdService.getOrCreate();
    return _deviceId!;
  }

  Map<String, String> _headers() => {'X-Device-Id': _deviceId ?? ''};

  Future<CajaSesionEstado> obtenerEstado() async {
    final deviceId = await _getDeviceId();
    final resp = await _dio.get(
      '/caja/sesion',
      options: Options(headers: {'X-Device-Id': deviceId}),
    );
    return CajaSesionEstado.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<ModifyResp> agregarItem(int productoId, {int cantidad = 1}) async {
    final deviceId = await _getDeviceId();
    final resp = await _dio.post(
      '/caja/sesion/items',
      data: {
        'producto_id': productoId,
        'cantidad': cantidad,
        'client_op_id': _generateOpId(),
      },
      options: Options(headers: {'X-Device-Id': deviceId}),
    );
    return ModifyResp.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<ModifyResp> setCantidad(int productoId, int cantidad) async {
    final deviceId = await _getDeviceId();
    final resp = await _dio.put(
      '/caja/sesion/items/$productoId',
      data: {
        'producto_id': productoId,
        'cantidad': cantidad,
        'client_op_id': _generateOpId(),
      },
      options: Options(headers: {'X-Device-Id': deviceId}),
    );
    return ModifyResp.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<ModifyResp> removerItem(int productoId) async {
    final deviceId = await _getDeviceId();
    final resp = await _dio.delete(
      '/caja/sesion/items/$productoId',
      options: Options(headers: {'X-Device-Id': deviceId}),
    );
    return ModifyResp.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<ModifyResp> limpiar() async {
    final deviceId = await _getDeviceId();
    final resp = await _dio.post(
      '/caja/sesion/clear',
      options: Options(headers: {'X-Device-Id': deviceId}),
    );
    return ModifyResp.fromJson(resp.data as Map<String, dynamic>);
  }

  void conectarSSE() {
    _sseClient?.dispose();
    _sseClient = EventSourceClient(
      initialRetryDelay: const Duration(seconds: 2),
      maxRetryDelay: const Duration(seconds: 30),
    );

    _sseClient!.onConnectionChange = (connected) {
      _connected = connected;
      onConnectionChange?.call(connected);
    };

    final sseStream = _sseClient!.connect(
      '/api/v1/caja/sesion/stream',
      headers: _headers(),
    );

    _sseSub = sseStream.listen(
      (event) {
        _eventController.add(event);
      },
      onError: (_) {},
      onDone: () {},
    );
  }

  void desconectarSSE() {
    _sseSub?.cancel();
    _sseClient?.dispose();
    _connected = false;
  }

  String _generateOpId() {
    final rand = DateTime.now().microsecondsSinceEpoch;
    return '$rand-${_deviceId ?? 'unknown'}';
  }

  void dispose() {
    desconectarSSE();
    _eventController.close();
  }
}
