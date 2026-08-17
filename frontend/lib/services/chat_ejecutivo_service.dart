import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/sugerencia.dart';

/// Servicio de chat ejecutivo.
///
/// v2: Usa el endpoint `/api/v1/ia/chat` que es conversacional con detección
/// de intención en lenguaje natural. Mantiene compatibilidad con el modo
/// "datos de negocio" como fallback si el chat IA no está disponible.
///
/// Historial de conversaciones: las últimas 20 se guardan en
/// shared_preferences (key: `chat_historial`).
class ChatEjecutivoService {
  final Dio _dio;
  static const _historialKey = 'chat_historial';
  static const _maxConversaciones = 20;

  ChatEjecutivoService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: apiBaseUrlSync,
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 12),
            ));

  /// Envía un mensaje al chat IA conversacional.
  ///
  /// [historial] son los últimos N mensajes previos para mantener contexto.
  /// [carritoIds] son los IDs de productos actualmente en el carrito.
  Future<ChatRespuesta> enviarConversacional(
    String mensaje, {
    List<ChatMensaje> historial = const [],
    List<int> carritoIds = const [],
  }) async {
    try {
      final resp = await _dio.post(
        '/ia/chat',
        data: {
          'mensaje': mensaje,
          'historial': historial
              .map((m) => {'rol': m.esUsuario ? 'user' : 'assistant', 'texto': m.texto})
              .toList(),
          'carrito_ids': carritoIds,
        },
      );
      final data = resp.data as Map<String, dynamic>;
      final sugs = (data['sugerencias'] as List<dynamic>?)
              ?.map((s) => Sugerencia.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const <Sugerencia>[];

      return ChatRespuesta(
        texto: (data['texto'] as String?) ?? '',
        tipo: ChatTipo.texto,
        sugerencias: sugs,
        fuente: (data['fuente'] as String?) ?? 'desconocido',
        intencion: (data['intencion'] as String?) ?? '',
      );
    } on DioException catch (e) {
      // Si falla el chat, intentar con el modo datos de negocio
      return await enviarFallbackNegocio(mensaje, e);
    } catch (e) {
      return ChatRespuesta(
        texto: 'Error: $e',
        tipo: ChatTipo.texto,
      );
    }
  }

  /// Fallback: si el chat IA falla, responder con datos de negocio directos.
  Future<ChatRespuesta> enviarFallbackNegocio(String mensaje, Object? causa) async {
    final lower = mensaje.toLowerCase().trim();
    if (lower.isEmpty) {
      return ChatRespuesta(
        texto: 'Escribe una pregunta. Ejemplos: "¿cuánto vendí hoy?", '
            '"productos con stock bajo", "predicciones críticas"',
        tipo: ChatTipo.texto,
      );
    }
    if (lower.contains('ayuda') || lower.contains('help')) {
      return ChatRespuesta(
        texto: 'Puedo responder preguntas como:\n\n'
            '• "¿Cuánto vendí hoy / esta semana / este mes?"\n'
            '• "¿Qué productos tienen stock bajo?"\n'
            '• "¿Qué se va a agotar pronto?"\n'
            '• "Dame el dashboard / resumen"\n'
            '• "¿Cuáles son los más vendidos?"\n'
            '• "¿Cuánto vale mi inventario?"\n\n'
            'Las respuestas se generan con datos reales de tu base de datos.',
        tipo: ChatTipo.texto,
      );
    }
    try {
      // Predicciones / stock
      if (lower.contains('stock') ||
          lower.contains('bajo') ||
          lower.contains('agotar') ||
          lower.contains('predic')) {
        final r = await _dio.get('/ia/inventario/predicciones');
        final d = r.data as Map<String, dynamic>;
        final criticos = d['productos_criticos'] ?? 0;
        final urgentes = d['productos_urgentes'] ?? 0;
        final top = (d['top_criticos'] as List? ?? []).cast<Map<String, dynamic>>();
        final buf = StringBuffer('🔮 **Predicciones de inventario**\n\n');
        buf.writeln('• 🔴 Críticos: $criticos');
        buf.writeln('• 🟠 Urgentes: $urgentes');
        if (top.isNotEmpty) {
          buf.writeln('\n**Top críticos:**');
          for (final p in top.take(5)) {
            buf.writeln('• ${p['nombre']} — ${p['dias_restantes']} días restantes');
          }
        }
        return ChatRespuesta(texto: buf.toString(), tipo: ChatTipo.texto);
      }
      // Ventas
      if (lower.contains('vendí') ||
          lower.contains('ventas') ||
          lower.contains('hoy') ||
          lower.contains('semana') ||
          lower.contains('mes')) {
        final r = await _dio.get('/dashboard/resumen');
        final d = r.data as Map<String, dynamic>;
        final buf = StringBuffer('📊 **Ventas**\n\n');
        buf.writeln('• Hoy: \$${d['ventas_hoy'] ?? 0}');
        buf.writeln('• Transacciones: ${d['transacciones_hoy'] ?? 0}');
        return ChatRespuesta(texto: buf.toString(), tipo: ChatTipo.texto);
      }
      // Resumen / dashboard
      if (lower.contains('resumen') || lower.contains('dashboard') || lower.contains('general')) {
        final r = await _dio.get('/dashboard/resumen');
        final d = r.data as Map<String, dynamic>;
        final buf = StringBuffer('📈 **Resumen**\n\n');
        buf.writeln('• Ventas hoy: \$${d['ventas_hoy'] ?? 0}');
        buf.writeln('• Ticket promedio: \$${d['ticket_promedio'] ?? 0}');
        return ChatRespuesta(texto: buf.toString(), tipo: ChatTipo.texto);
      }
      return ChatRespuesta(
        texto: '🤔 No entendí esa pregunta. Escribe "ayuda" para ver qué puedo hacer.',
        tipo: ChatTipo.texto,
      );
    } catch (e) {
      return ChatRespuesta(
        texto: 'El chat IA no está disponible. Error: $causa',
        tipo: ChatTipo.texto,
      );
    }
  }

  /// Atajo: usa el conversacional (preferido).
  Future<ChatRespuesta> enviar(
    String mensaje, {
    List<ChatMensaje> historial = const [],
    List<int> carritoIds = const [],
  }) {
    return enviarConversacional(
      mensaje,
      historial: historial,
      carritoIds: carritoIds,
    );
  }

  /// Estado del toggle IA.
  Future<({bool activo, String fuente, String descripcion})> getEstadoIA() async {
    try {
      final r = await _dio.get('/ia/estado');
      final d = r.data as Map<String, dynamic>;
      return (
        activo: (d['activo'] as bool?) ?? false,
        fuente: (d['fuente_actual'] as String?) ?? 'desconocido',
        descripcion: (d['descripcion'] as String?) ?? '',
      );
    } catch (_) {
      return (activo: false, fuente: 'error', descripcion: 'No se pudo conectar al servidor');
    }
  }

  Future<bool> toggleIA(bool activo) async {
    try {
      await _dio.post('/ia/toggle', data: {'activo': activo});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Sugerencias de autocompletado para registro de productos nuevos.
  Future<SugerenciaProducto?> sugerirProducto(String nombre) async {
    try {
      final r = await _dio.get(
        '/ia/sugerir-producto',
        queryParameters: {'nombre': nombre},
      );
      final d = r.data as Map<String, dynamic>;
      return SugerenciaProducto.fromJson(d);
    } catch (_) {
      return null;
    }
  }

  // ── Historial de conversaciones ──

  /// Guarda una conversación en el historial persistente.
  Future<void> guardarConversacion(ChatConversacion conv) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historialKey);
      final list = raw == null
          ? <ChatConversacion>[]
          : (jsonDecode(raw) as List<dynamic>)
              .map((j) => ChatConversacion.fromJson(j as Map<String, dynamic>))
              .toList();
      list.insert(0, conv);
      while (list.length > _maxConversaciones) {
        list.removeLast();
      }
      await prefs.setString(
        _historialKey,
        jsonEncode(list.map((c) => c.toJson()).toList()),
      );
    } catch (_) {
      // Silenciar errores de persistencia
    }
  }

  Future<List<ChatConversacion>> cargarConversaciones() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historialKey);
      if (raw == null) return [];
      return (jsonDecode(raw) as List<dynamic>)
          .map((j) => ChatConversacion.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> borrarHistorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historialKey);
    } catch (_) {
      // Silenciar errores de persistencia del historial
    }
  }

  // ── Sesión activa (la conversación en curso, NO el historial completo) ──

  static const _sesionKey = 'chat_sesion_activa';

  /// Guarda la conversación en curso (mensajes + respuestas paralelas).
  /// Se re-hidrata al volver a abrir la pantalla de chat.
  Future<void> guardarSesionActiva({
    required List<ChatMensaje> mensajes,
    required List<ChatRespuesta> respuestas,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Construir pares (mensaje_usuario, respuesta_asistente) para re-hidratar fácil.
      final pares = <Map<String, dynamic>>[];
      for (var i = 0; i < mensajes.length; i++) {
        final m = mensajes[i];
        // Cada respuesta del asistente corresponde a un mensaje del usuario previo.
        // Las respuestas[] está paralela al log: índice j -> respuesta del asistente j-ésima.
        // Aquí serializamos un solo objeto con texto y fuente.
        pares.add({
          'texto': m.texto,
          'esUsuario': m.esUsuario,
          'timestamp': m.timestamp.toIso8601String(),
        });
      }
      final data = {
        'mensajes': pares,
        // Guardamos respuestas aplanadas (sin objetos Sugerencia complejos,
        // basta con la lista de nombres para re-mostrar las tarjetas).
        'respuestas': respuestas.map((r) => {
              'texto': r.texto,
              'fuente': r.fuente,
              'intencion': r.intencion,
              'sugerencias_nombres': r.sugerencias.map((s) => s.nombre).toList(),
            }).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_sesionKey, jsonEncode(data));
    } catch (_) {
      // Silenciar errores de persistencia
    }
  }

  /// Carga la sesión activa guardada, o null si no hay.
  /// Las respuestas no se re-hidratan completas (sin objetos Sugerencia),
  /// sólo el texto plano y metadatos para re-mostrar la burbuja.
  Future<ChatSesionActiva?> cargarSesionActiva() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sesionKey);
      if (raw == null) return null;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final mensajes = (data['mensajes'] as List<dynamic>)
          .map((j) => ChatMensaje.fromJson(j as Map<String, dynamic>))
          .toList();
      final respuestas = (data['respuestas'] as List<dynamic>).map((j) {
        final m = j as Map<String, dynamic>;
        return ChatRespuesta(
          texto: m['texto'] as String? ?? '',
          tipo: ChatTipo.texto,
          fuente: m['fuente'] as String? ?? 'reglas_locales',
          intencion: m['intencion'] as String? ?? '',
          // Las sugerencias detalladas no se restauran (sólo los nombres) —
          // quedan como [] y la burbuja se ve sin tarjetas en re-hidratación.
          sugerencias: const [],
        );
      }).toList();
      return ChatSesionActiva(mensajes: mensajes, respuestas: respuestas);
    } catch (_) {
      return null;
    }
  }

  Future<void> borrarSesionActiva() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sesionKey);
    } catch (_) {}
  }
}

enum ChatTipo { texto }

class ChatRespuesta {
  final String texto;
  final ChatTipo tipo;
  final List<Sugerencia> sugerencias;
  final String fuente;
  final String intencion;

  ChatRespuesta({
    required this.texto,
    required this.tipo,
    this.sugerencias = const [],
    this.fuente = 'desconocido',
    this.intencion = '',
  });
}

class ChatMensaje {
  final String texto;
  final bool esUsuario;
  final DateTime timestamp;
  ChatMensaje({
    required this.texto,
    required this.esUsuario,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'texto': texto,
        'esUsuario': esUsuario,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMensaje.fromJson(Map<String, dynamic> json) => ChatMensaje(
        texto: json['texto'] as String,
        esUsuario: json['esUsuario'] as bool,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      );
}

class ChatConversacion {
  final String id;
  final String titulo;
  final List<ChatMensaje> mensajes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatConversacion({
    required this.id,
    required this.titulo,
    required this.mensajes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'mensajes': mensajes.map((m) => m.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ChatConversacion.fromJson(Map<String, dynamic> json) => ChatConversacion(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        mensajes: (json['mensajes'] as List<dynamic>)
            .map((m) => ChatMensaje.fromJson(m as Map<String, dynamic>))
            .toList(),
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Sugerencia de autocompletado para producto nuevo.
class SugerenciaProducto {
  final String nombre;
  final String categoriaSugerida;
  final int? categoriaId;
  final double precioMin;
  final double precioMax;
  final double precioPromedio;
  final String descripcion;
  final List<int> necesita;
  final int coincidencias;
  final String fuente;

  SugerenciaProducto({
    required this.nombre,
    required this.categoriaSugerida,
    this.categoriaId,
    required this.precioMin,
    required this.precioMax,
    required this.precioPromedio,
    required this.descripcion,
    this.necesita = const [],
    required this.coincidencias,
    required this.fuente,
  });

  factory SugerenciaProducto.fromJson(Map<String, dynamic> json) {
    return SugerenciaProducto(
      nombre: (json['nombre'] as String?) ?? '',
      categoriaSugerida: (json['categoria_sugerida'] as String?) ?? '',
      categoriaId: (json['categoria_id'] as num?)?.toInt(),
      precioMin: (json['precio_min'] as num?)?.toDouble() ?? 0,
      precioMax: (json['precio_max'] as num?)?.toDouble() ?? 0,
      precioPromedio: (json['precio_promedio'] as num?)?.toDouble() ?? 0,
      descripcion: (json['descripcion'] as String?) ?? '',
      necesita: ((json['necesita'] as List<dynamic>?) ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
      coincidencias: (json['coincidencias'] as num?)?.toInt() ?? 0,
      fuente: (json['fuente'] as String?) ?? 'desconocido',
    );
  }
}

/// Estructura devuelta por [ChatEjecutivoService.cargarSesionActiva].
class ChatSesionActiva {
  final List<ChatMensaje> mensajes;
  final List<ChatRespuesta> respuestas;
  ChatSesionActiva({required this.mensajes, required this.respuestas});
}
