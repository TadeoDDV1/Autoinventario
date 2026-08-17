import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ShimmerLoading extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final ShapeBorder? shape;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final Duration delay;

  const ShimmerLoading({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBaseColor = baseColor ??
        (isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3));

    final effectiveHighlightColor = highlightColor ??
        (isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1));

    return Animate(
      effects: [
        ShimmerEffect(
          duration: duration,
          delay: delay,
          colors: [
            effectiveBaseColor,
            effectiveHighlightColor,
            effectiveBaseColor,
          ],
        ),
      ],
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: effectiveBaseColor,
          shape: shape ??
              RoundedRectangleBorder(
                borderRadius: borderRadius ?? BorderRadius.circular(12),
              ),
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final List<Widget>? children;
  final bool animate;

  const ShimmerCard({
    super.key,
    this.height = 120,
    this.padding,
    this.margin,
    this.borderRadius,
    this.children,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);

    final highlightColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1);

    final defaultChildren = <Widget>[
      ShimmerLoading(
        width: 160,
        height: 24,
        borderRadius: BorderRadius.circular(4),
        baseColor: baseColor,
        highlightColor: highlightColor,
      ),
      const SizedBox(height: 12),
      ShimmerLoading(
        width: 200,
        height: 16,
        borderRadius: BorderRadius.circular(4),
        baseColor: baseColor,
        highlightColor: highlightColor,
      ),
      const SizedBox(height: 8),
      ShimmerLoading(
        width: 120,
        height: 14,
        borderRadius: BorderRadius.circular(4),
        baseColor: baseColor,
        highlightColor: highlightColor,
      ),
    ];

    final card = Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children ?? defaultChildren,
      ),
    );

    if (animate) {
      return Animate(
        effects: const [FadeEffect(duration: Duration(milliseconds: 300))],
        child: card,
      );
    }
    return card;
  }
}

class ShimmerList extends StatelessWidget {
  final int count;
  final double itemHeight;
  final double spacing;
  final EdgeInsets? padding;
  final Widget Function(int index)? itemBuilder;

  const ShimmerList({
    super.key,
    this.count = 5,
    this.itemHeight = 80,
    this.spacing = 12,
    this.padding,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) {
        final widget = itemBuilder?.call(index) ??
            ShimmerCard(
              height: itemHeight,
              animate: true,
            );
        return Padding(
          padding: EdgeInsets.only(bottom: index == count - 1 ? 0 : spacing),
          child: widget,
        );
      },
    );
  }
}

class ShimmerDashboard extends StatelessWidget {
  final int cardCount;
  final int chartHeight;
  final int listItems;
  final bool showCharts;

  const ShimmerDashboard({
    super.key,
    this.cardCount = 4,
    this.chartHeight = 200,
    this.listItems = 5,
    this.showCharts = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            (cardCount / 2).ceil(),
            (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: i == 0 ? 8 : 0,
                  left: i == (cardCount / 2).ceil() - 1 ? 8 : 0,
                ),
                child: _fade(ShimmerCard(height: 120), 400.ms, (i * 100).ms),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (showCharts) ...[
          _fade(ShimmerCard(height: chartHeight.toDouble()), 400.ms, 300.ms),
          const SizedBox(height: 16),
        ],
        ShimmerList(
          count: listItems,
          itemHeight: 72,
          itemBuilder: (index) => _fade(
            const ShimmerProductCard(),
            350.ms,
            (index * 80 + 400).ms,
          ),
        ),
      ],
    );
  }
}

Animate _fade(Widget child, Duration duration, Duration delay) {
  return Animate(
    effects: [
      FadeEffect(duration: duration, delay: delay),
    ],
    child: child,
  );
}

class ShimmerProductCard extends StatelessWidget {
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerProductCard({
    super.key,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = baseColor ?? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final highlight = highlightColor ?? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1);
    return Container(
      height: 72,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          ShimmerLoading(
            width: 48,
            height: 48,
            shape: const CircleBorder(),
            baseColor: base,
            highlightColor: highlight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerLoading(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                  baseColor: base,
                  highlightColor: highlight,
                ),
                const SizedBox(height: 6),
                ShimmerLoading(
                  width: 140,
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                  baseColor: base,
                  highlightColor: highlight,
                ),
                const SizedBox(height: 4),
                ShimmerLoading(
                  width: 100,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                  baseColor: base,
                  highlightColor: highlight,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ShimmerLoading(
            width: 70,
            height: 20,
            borderRadius: BorderRadius.circular(4),
            baseColor: base,
            highlightColor: highlight,
          ),
        ],
      ),
    );
  }
}

class ShimmerInventoryItem extends StatelessWidget {
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerInventoryItem({
    super.key,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = baseColor ?? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final highlight = highlightColor ?? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1);
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          ShimmerLoading(
            width: 40,
            height: 40,
            shape: const CircleBorder(),
            baseColor: base,
            highlightColor: highlight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerLoading(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                  baseColor: base,
                  highlightColor: highlight,
                ),
                const SizedBox(height: 4),
                ShimmerLoading(
                  width: 160,
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                  baseColor: base,
                  highlightColor: highlight,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ShimmerLoading(
            width: 50,
            height: 18,
            borderRadius: BorderRadius.circular(4),
            baseColor: base,
            highlightColor: highlight,
          ),
        ],
      ),
    );
  }
}

class ShimmerStatsGrid extends StatelessWidget {
  final int count;
  final double? cardHeight;

  const ShimmerStatsGrid({
    super.key,
    this.count = 4,
    this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        return _fade(
          ShimmerCard(
            height: cardHeight,
            animate: true,
          ),
          400.ms,
          (index * 100).ms,
        );
      },
    );
  }
}

class ShimmerSection extends StatelessWidget {
  final String title;
  final int itemCount;
  final double itemHeight;
  final Widget Function(int)? customItemBuilder;

  const ShimmerSection({
    super.key,
    required this.title,
    this.itemCount = 5,
    this.itemHeight = 72,
    this.customItemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: _fade(
            ShimmerLoading(
              width: 120,
              height: 20,
              borderRadius: BorderRadius.circular(4),
            ),
            200.ms,
            Duration.zero,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            final child = customItemBuilder?.call(index) ??
                ShimmerCard(height: itemHeight);
            return Padding(
              padding: EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : 12),
              child: _fade(child, 350.ms, (index * 80).ms),
            );
          },
        ),
      ],
    );
  }
}

class ContentTransition extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Widget? loadingWidget;
  final Duration fadeDuration;
  final Duration slideDuration;

  const ContentTransition({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingWidget,
    this.fadeDuration = const Duration(milliseconds: 300),
    this.slideDuration = const Duration(milliseconds: 350),
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ??
          ShimmerDashboard(
            cardCount: 4,
            chartHeight: 200,
            listItems: 5,
          );
    }

    return AnimatedSwitcher(
      duration: fadeDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: const ValueKey('content'),
        child: child,
      ),
    );
  }
}