import 'package:flutter/material.dart';

/// Fondo sutil para pantallas.
///
/// MIGRACIÓN: Antes era un glassmorfismo animado con 5 círculos HSL
/// aleatorios y blur. Ahora es solo un degradado vertical en dark mode
/// y transparente en light mode (deja ver el `surface` del Scaffold).
class AtmosphericBackground extends StatelessWidget {
  const AtmosphericBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) {
      return const SizedBox.shrink();
    }
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F2027),
            Color(0xFF1A1B41),
          ],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}
