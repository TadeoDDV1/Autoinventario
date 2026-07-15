import 'package:flutter/material.dart';

import '../theme/glass_tokens.dart';

/// Card M3 sólido con elevación sutil. Reemplazo post-glassmorfismo.
///
/// - `surfaceContainerHigh` como fondo + borde `outlineVariant` 0.5dp.
/// - Elevation 1 vía Material para shadow nativo.
/// - Sin BackdropFilter, sin blur: render nativo, sin coste GPU extra.
class M3Card extends StatelessWidget {
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

  const M3Card({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius = GlassTokens.borderRadiusMedium,
    this.blur = 0,
    this.color,
    this.borderColor,
    this.boxShadow,
    this.customDecoration,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = color ?? theme.colorScheme.surfaceContainerHigh;
    final brdColor = borderColor ?? theme.colorScheme.outlineVariant;

    if (customDecoration != null) {
      return Container(
        width: width,
        height: height,
        margin: margin,
        clipBehavior: clipBehavior,
        decoration: customDecoration,
        child: _buildContent(context, bgColor, brdColor),
      );
    }
    return Container(
      width: width,
      height: height,
      margin: margin,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: brdColor, width: GlassTokens.borderWidth),
        boxShadow: boxShadow,
      ),
      child: _buildContent(context, bgColor, brdColor),
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

/// Alias deprecado de [M3Card]. Mantenido por compatibilidad con los
/// 46 call-sites existentes. Mañana: migración call-site por call-site.
@Deprecated('Usar M3Card. GlassContainer se conserva solo para compat.')
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
    this.blur = 0,
    this.color,
    this.borderColor,
    this.boxShadow,
    this.customDecoration,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    return M3Card(
      key: key,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      borderRadius: borderRadius,
      blur: blur,
      color: color,
      borderColor: borderColor,
      boxShadow: boxShadow,
      customDecoration: customDecoration,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}
