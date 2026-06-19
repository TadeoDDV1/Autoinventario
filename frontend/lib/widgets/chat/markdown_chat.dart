import 'package:flutter/material.dart';

/// Parser de markdown ligero para las respuestas del chat IA.
///
/// Soporta:
/// - **negrita** con `**texto**`
/// - *cursiva* con `*texto*`
/// - `código inline` con backticks
/// - Bullets con `• ` o `- `
/// - Saltos de línea (uno = soft break, doble = párrafo)
///
/// NO soporta (por decisión del plan 18-jun):
/// - Tablas markdown
/// - Links `[texto](url)`
/// - Bloques de código multi-línea con triple backtick
/// - Imágenes
class MarkdownChat extends StatelessWidget {
  final String texto;
  final Color color;
  final double fontSize;

  const MarkdownChat({
    super.key,
    required this.texto,
    required this.color,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = TextStyle(color: color, fontSize: fontSize, height: 1.35);
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);
    final italicStyle = baseStyle.copyWith(fontStyle: FontStyle.italic);
    final codeStyle = baseStyle.copyWith(
      fontFamily: 'monospace',
      fontSize: fontSize - 1,
      backgroundColor: theme.colorScheme.surfaceContainerLow,
    );

    final spans = <InlineSpan>[];

    // Dividir por párrafos (doble salto de línea).
    final paragraphs = texto.split(RegExp(r'\n\s*\n'));
    for (var p = 0; p < paragraphs.length; p++) {
      final paragraph = paragraphs[p];
      // Cada párrafo se procesa línea por línea.
      final lines = paragraph.split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        _parseLine(line, baseStyle, boldStyle, italicStyle, codeStyle, spans);
        if (i < lines.length - 1) {
          spans.add(const TextSpan(text: '\n'));
        }
      }
      if (p < paragraphs.length - 1) {
        // Doble salto entre párrafos.
        spans.add(const TextSpan(text: '\n\n'));
      }
    }

    return SelectableText.rich(
      TextSpan(style: baseStyle, children: spans),
    );
  }

  void _parseLine(
    String line,
    TextStyle base,
    TextStyle bold,
    TextStyle italic,
    TextStyle code,
    List<InlineSpan> out,
  ) {
    if (line.isEmpty) return;

    // Bullet
    var remaining = line;
    var bullet = false;
    if (remaining.startsWith('• ') || remaining.startsWith('- ')) {
      bullet = true;
      remaining = remaining.substring(2);
    }

    if (bullet) {
      out.add(const TextSpan(text: '•  '));
    }

    // Parsear token por token: **, *, `, o texto plano.
    var idx = 0;
    while (idx < remaining.length) {
      // Código inline `xxx`
      if (remaining[idx] == '`') {
        final end = remaining.indexOf('`', idx + 1);
        if (end > idx + 1) {
          out.add(TextSpan(
            text: ' ${remaining.substring(idx + 1, end)} ',
            style: code,
          ));
          idx = end + 1;
          continue;
        }
      }

      // **bold**
      if (idx + 1 < remaining.length && remaining.substring(idx, idx + 2) == '**') {
        final end = remaining.indexOf('**', idx + 2);
        if (end > idx + 2) {
          out.add(TextSpan(
            text: remaining.substring(idx + 2, end),
            style: bold,
          ));
          idx = end + 2;
          continue;
        }
      }

      // *italic*
      if (remaining[idx] == '*' && (idx == 0 || remaining[idx - 1] != '*')) {
        // Buscar cierre que no sea parte de **
        var end = idx + 1;
        while (end < remaining.length) {
          if (remaining[end] == '*' &&
              !(end + 1 < remaining.length && remaining[end + 1] == '*') &&
              !(end > 0 && remaining[end - 1] == '*')) {
            break;
          }
          end++;
        }
        if (end > idx + 1 && end < remaining.length) {
          out.add(TextSpan(
            text: remaining.substring(idx + 1, end),
            style: italic,
          ));
          idx = end + 1;
          continue;
        }
      }

      // Texto plano hasta el próximo token especial.
      var next = idx + 1;
      while (next < remaining.length) {
        final c = remaining[next];
        if (c == '`' || c == '*') break;
        next++;
      }
      if (next == idx) next = idx + 1; // seguridad: avanzar al menos 1
      out.add(TextSpan(text: remaining.substring(idx, next), style: base));
      idx = next;
    }
  }
}
