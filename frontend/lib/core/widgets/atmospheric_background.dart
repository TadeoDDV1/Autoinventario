import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/glass_tokens.dart';

class AtmosphericBackground extends StatelessWidget {
  final List<Color>? gradientColors;
  final bool animated;

  const AtmosphericBackground({
    super.key,
    this.gradientColors,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? GlassTokens.backgroundGradient;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effective = isDark ? colors : colors.map((c) => c.withValues(alpha: 0.4)).toList();

    return AnimatedContainer(
      duration: const Duration(seconds: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: effective,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: _AccentCircles(animated: animated),
    );
  }
}

class _AccentCircles extends StatefulWidget {
  final bool animated;
  const _AccentCircles({this.animated = false});

  @override
  State<_AccentCircles> createState() => _AccentCirclesState();
}

class _AccentCirclesState extends State<_AccentCircles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    if (widget.animated) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final rng = Random(42);

    return Stack(
      children: List.generate(5, (i) {
        final x = rng.nextDouble() * size.width;
        final y = rng.nextDouble() * size.height;
        final radius = 60.0 + rng.nextDouble() * 120;
        final color = HSLColor.fromAHSL(
          0.04 + rng.nextDouble() * 0.04,
          rng.nextDouble() * 360,
          0.6,
          0.5 + rng.nextDouble() * 0.3,
        ).toColor();

        if (widget.animated) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final dx = sin(_controller.value * 2 * pi + i.toDouble()) * 30;
              final dy = cos(_controller.value * 2 * pi + i.toDouble()) * 30;
              return Positioned(
                left: x + dx,
                top: y + dy,
                child: _Circle(radius: radius, color: color),
              );
            },
          );
        }

        return Positioned(
          left: x,
          top: y,
          child: _Circle(radius: radius, color: color),
        );
      }),
    );
  }
}

class _Circle extends StatelessWidget {
  final double radius;
  final Color color;
  const _Circle({required this.radius, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: radius,
            spreadRadius: radius * 0.3,
          ),
        ],
      ),
    );
  }
}
