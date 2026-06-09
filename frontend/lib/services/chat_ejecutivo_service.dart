import 'package:intl/intl.dart';
import '../config/api_config.dart';
import 'package:dio/dio.dart';

/// Servicio de chat ejecutivo.
/// Interpreta preguntas en lenguaje natural y consulta la BD del backend
/// para devolver respuestas con datos reales.
/// Funciona 100% local con regex (no requiere LLM externo).
class ChatEjecutivoService {
  final Dio _dio;
  final NumberFormat _money;

  ChatEjecutivoService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: apiBaseUrl,
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            )),
        _money = NumberFormat.currency(
            locale: 'es_MX', symbol: r'$', decimalDigits: 2);

  Future<ChatRespuesta> enviar(String mensaje) async {
    final lower = mensaje.toLowerCase().trim();
    if (lower.isEmpty) {
      return ChatRespuesta(
        texto: 'Escribe una pregunta. Ejemplos: "¿cuánto vendí hoy?", '
            '"productos con stock bajo", "predicciones críticas"',
        tipo: ChatTipo.texto,
      );
    }

    // ── INTENCIÓN: ventas hoy ──────────────────────────────
    if (_match(lower, ['hoy', 'dia', 'día', 'vendí hoy', 'ventas hoy'])) {
      return await _ventasHoy();
    }
    // ── INTENCIÓN: ventas semana ──────────────────────────
    if (_match(lower, ['semana', '7 dias', '7 días'])) {
      return await _ventasSemana();
    }
    // ── INTENCIÓN: ventas mes ─────────────────────────────
    if (_match(lower, ['mes', '30 dias', '30 días'])) {
      return await _ventasMes();
    }
    // ── INTENCIÓN: stock bajo ─────────────────────────────
    if (_match(lower, ['stock bajo', 'bajo stock', 'poco stock', 'por agotarse'])) {
      return await _stockBajo();
    }
    // ── INTENCIÓN: predicciones / críticos ─────────────────
    if (_match(lower, ['prediccion', 'predicción', 'critico', 'crítico',
        'urgente', 'agotar'])) {
      return await _predicciones();
    }
    // ── INTENCIÓN: dashboard / resumen ─────────────────────
    if (_match(lower, ['dashboard', 'resumen', 'como va', 'cómo va',
        'negocio', 'general'])) {
      return await _dashboard();
    }
    // ── INTENCIÓN: top productos ──────────────────────────
    if (_match(lower, ['top', 'mas vendido', 'más vendido', 'vendidos',
        'producto mas', 'producto más'])) {
      return await _topProductos();
    }
    // ── INTENCIÓN: valor inventario ────────────────────────
    if (_match(lower, ['valor', 'inventario total', 'capital'])) {
      return await _valorInventario();
    }
    // ── INTENCIÓN: ayuda ──────────────────────────────────
    if (_match(lower, ['ayuda', 'help', 'que puedes', 'qué puedes',
        'opciones', 'comandos'])) {
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

    return ChatRespuesta(
      texto: 'No entendí esa pregunta. Escribe "ayuda" para ver qué puedo hacer.',
      tipo: ChatTipo.texto,
    );
  }

  bool _match(String s, List<String> needles) =>
      needles.any((n) => s.contains(n));

  // ── IMPLEMENTACIONES ──────────────────────────────────

  Future<ChatRespuesta> _ventasHoy() async {
    try {
      final r = await _dio.get('/dashboard/resumen');
      final d = r.data as Map<String, dynamic>;
      final total = (d['ventas_hoy'] ?? d['ventasHoy'] ?? 0).toDouble();
      final numVentas = d['numero_ventas_hoy'] ?? d['numeroVentasHoy'] ?? 0;
      return ChatRespuesta(
        texto: '📊 **Ventas de hoy**\n\n'
            '• Total: ${_money.format(total)}\n'
            '• Número de ventas: $numVentas\n'
            '• Ticket promedio: ${_money.format(numVentas > 0 ? total / numVentas : 0)}',
        tipo: ChatTipo.texto,
      );
    } catch (e) {
      return ChatRespuesta(texto: 'Error consultando ventas de hoy: $e', tipo: ChatTipo.texto);
    }
  }

  Future<ChatRespuesta> _ventasSemana() async {
    try {
      final r = await _dio.get('/dashboard/resumen');
      final d = r.data as Map<String, dynamic>;
      final total = (d['ventas_semana'] ?? d['ventasSemana'] ?? 0).toDouble();
      final numVentas = d['numero_ventas_semana'] ?? 0;
      return ChatRespuesta(
        texto: '📅 **Ventas últimos 7 días**\n\n'
            '• Total: ${_money.format(total)}\n'
            '• Número de ventas: $numVentas\n'
            '• Promedio diario: ${_money.format(numVentas / 7)}',
        tipo: ChatTipo.texto,
      );
    } catch (e) {
      return ChatRespuesta(texto: 'Error: $e', tipo: ChatTipo.texto);
    }
  }

  Future<ChatRespuesta> _ventasMes() async {
    try {
      final r = await _dio.get('/dashboard/resumen');
      final d = r.data as Map<String, dynamic>;
      final total = (d['ventas_mes'] ?? d['ventasMes'] ?? 0).toDouble();
      final numVentas = d['numero_ventas_mes'] ?? 0;
      return ChatRespuesta(
        texto: '📆 **Ventas últimos 30 días**\n\n'
            '• Total: ${_money.format(total)}\n'
            '• Número de ventas: $numVentas\n'
            '• Promedio diario: ${_money.format(numVentas / 30)}',
        tipo: ChatTipo.texto,
      );
    } catch (e) {
      return ChatRespuesta(texto: 'Error: $e', tipo: ChatTipo.texto);
    }
  }

  Future<ChatRespuesta> _stockBajo() async {
    try {
      final r = await _dio.get('/productos', queryParameters: {
        'page': 1,
        'page_size': 200,
      });
      final productos = (r.data['data'] as List).cast<Map<String, dynamic>>();
      final bajo = productos.where((p) {
        final stock = (p['stock_actual'] ?? 0) as int;
        final minimo = (p['stock_minimo'] ?? 0) as int;
        return stock <= minimo;
      }).toList();

      if (bajo.isEmpty) {
        return ChatRespuesta(
          texto: '✅ Todos los productos tienen stock suficiente.',
          tipo: ChatTipo.texto,
        );
      }

      final buf = StringBuffer('⚠️ **Productos con stock bajo** (${bajo.length})\n\n');
      for (final p in bajo.take(10)) {
        final nombre = p['nombre'] ?? 'Sin nombre';
        final stock = p['stock_actual'] ?? 0;
        final min = p['stock_minimo'] ?? 0;
        buf.writeln('• $nombre — stock: $stock / mín: $min');
      }
      if (bajo.length > 10) {
        buf.writeln('\n… y ${bajo.length - 10} más.');
      }
      return ChatRespuesta(texto: buf.toString(), tipo: ChatTipo.texto);
    } catch (e) {
      return ChatRespuesta(texto: 'Error: $e', tipo: ChatTipo.texto);
    }
  }

  Future<ChatRespuesta> _predicciones() async {
    try {
      final r = await _dio.get('/ia/inventario/predicciones');
      final d = r.data as Map<String, dynamic>;
      final criticos = d['productos_criticos'] ?? 0;
      final urgentes = d['productos_urgentes'] ?? 0;
      final sinVentas = d['productos_sin_ventas'] ?? 0;
      final top = (d['top_criticos'] as List? ?? []).cast<Map<String, dynamic>>();

      final buf = StringBuffer('🔮 **Predicciones de inventario**\n\n');
      buf.writeln('• 🔴 Críticos (≤3 días): $criticos');
      buf.writeln('• 🟠 Urgentes (≤7 días): $urgentes');
      buf.writeln('• ⚫ Sin ventas (30d): $sinVentas');
      buf.writeln('');
      if (top.isEmpty) {
        buf.writeln('✅ No hay productos en estado crítico.');
      } else {
        buf.writeln('**Top críticos:**');
        for (final p in top.take(5)) {
          final nombre = p['nombre'] ?? '?';
          final dias = p['dias_restantes'] ?? '?';
          buf.writeln('• $nombre — $dias días restantes');
        }
      }
      return ChatRespuesta(texto: buf.toString(), tipo: ChatTipo.texto);
    } catch (e) {
      return ChatRespuesta(texto: 'Error: $e', tipo: ChatTipo.texto);
    }
  }

  Future<ChatRespuesta> _dashboard() async {
    try {
      final r = await _dio.get('/dashboard/resumen');
      final d = r.data as Map<String, dynamic>;
      final buf = StringBuffer('📈 **Resumen del negocio**\n\n');
      buf.writeln('• Ventas hoy: ${_money.format(d['ventas_hoy'] ?? 0)}');
      buf.writeln('• Ventas semana: ${_money.format(d['ventas_semana'] ?? 0)}');
      buf.writeln('• Ventas mes: ${_money.format(d['ventas_mes'] ?? 0)}');
      buf.writeln('• Productos totales: ${d['total_productos'] ?? 0}');
      buf.writeln('• Stock bajo: ${d['productos_stock_bajo'] ?? 0}');
      return ChatRespuesta(texto: buf.toString(), tipo: ChatTipo.texto);
    } catch (e) {
      return ChatRespuesta(texto: 'Error: $e', tipo: ChatTipo.texto);
    }
  }

  Future<ChatRespuesta> _topProductos() async {
    try {
      final r = await _dio.get('/dashboard/resumen');
      final d = r.data as Map<String, dynamic>;
      final top = (d['top_productos'] as List? ?? []).cast<Map<String, dynamic>>();
      if (top.isEmpty) {
        return ChatRespuesta(
          texto: 'Aún no hay datos de ventas suficientes para generar un top.',
          tipo: ChatTipo.texto,
        );
      }
      final buf = StringBuffer('🏆 **Top productos vendidos (30 días)**\n\n');
      for (var i = 0; i < top.take(5).length; i++) {
        final p = top[i];
        buf.writeln('${i + 1}. ${p['nombre']} — ${p['cantidad_vendida']} uds');
      }
      return ChatRespuesta(texto: buf.toString(), tipo: ChatTipo.texto);
    } catch (e) {
      return ChatRespuesta(texto: 'Error: $e', tipo: ChatTipo.texto);
    }
  }

  Future<ChatRespuesta> _valorInventario() async {
    try {
      final r = await _dio.get('/ia/inventario/predicciones');
      final d = r.data as Map<String, dynamic>;
      final valor = (d['valor_inventario'] ?? 0).toDouble();
      final critico = (d['valor_critico'] ?? 0).toDouble();
      final buf = StringBuffer('💰 **Valor de inventario**\n\n');
      buf.writeln('• Total: ${_money.format(valor)}');
      buf.writeln('• En productos críticos: ${_money.format(critico)}');
      return ChatRespuesta(texto: buf.toString(), tipo: ChatTipo.texto);
    } catch (e) {
      return ChatRespuesta(texto: 'Error: $e', tipo: ChatTipo.texto);
    }
  }
}

enum ChatTipo { texto }

class ChatRespuesta {
  final String texto;
  final ChatTipo tipo;
  ChatRespuesta({required this.texto, required this.tipo});
}

class ChatMensaje {
  final String texto;
  final bool esUsuario;
  final DateTime timestamp;
  ChatMensaje({required this.texto, required this.esUsuario, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}
