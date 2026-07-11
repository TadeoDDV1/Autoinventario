import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/glass_tokens.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final Decoration? customDecoration;
  final Clip clipBehavior;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius = GlassTokens.borderRadiusMedium,
    this.blur = GlassTokens.blurMedium,
    this.color,
    this.borderColor,
    this.boxShadow,
    this.customDecoration,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? GlassTokens.glassColor(context);
    final brdColor = borderColor ?? GlassTokens.glassBorder(context);
    final shadow = boxShadow ?? [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: GlassTokens.shadowBlur,
        offset: const Offset(0, 4),
      ),
    ];

    return Container(
      width: width,
      height: height,
      margin: margin,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: customDecoration != null
              ? DecoratedBox(
                  decoration: customDecoration!,
                  child: _buildContent(context, bgColor, brdColor),
                )
              : _buildContent(context, bgColor, brdColor),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color bg, Color brd) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: brd,
          width: GlassTokens.borderWidth,
        ),
      ),
      child: child,
    );
  }
}
