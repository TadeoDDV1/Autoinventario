import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppPageTransitions {
  static const Duration defaultDuration = Duration(milliseconds: 350);
  static const Duration fastDuration = Duration(milliseconds: 250);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve fastCurve = Curves.easeOutQuart;

  static PageRouteBuilder<T> slideUp<T>({
    required Widget child,
    Duration? duration,
    Curve? curve,
    Offset beginOffset = const Offset(0, 0.15),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, _, _) => child,
      transitionDuration: duration ?? defaultDuration,
      reverseTransitionDuration: duration ?? fastDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve ?? defaultCurve,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  static PageRouteBuilder<T> fadeSlide<T>({
    required Widget child,
    Duration? duration,
    Curve? curve,
    Offset beginOffset = const Offset(0.1, 0),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, _, _) => child,
      transitionDuration: duration ?? defaultDuration,
      reverseTransitionDuration: duration ?? fastDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve ?? defaultCurve,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  static PageRouteBuilder<T> scaleFade<T>({
    required Widget child,
    Duration? duration,
    Curve? curve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, _, _) => child,
      transitionDuration: duration ?? defaultDuration,
      reverseTransitionDuration: duration ?? fastDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve ?? defaultCurve,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  static PageRouteBuilder<T> modalBottomSheet<T>({
    required Widget child,
    Duration? duration,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, _, _) => child,
      barrierColor: Colors.black54,
      opaque: false,
      transitionDuration: duration ?? fastDuration,
      reverseTransitionDuration: duration ?? fastDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }
}

extension WidgetAnimationX on Widget {
  Widget fadeIn({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
    double delay = 0,
  }) {
    return Animate(
      effects: [
        FadeEffect(
          duration: duration,
          curve: curve,
          delay: Duration(milliseconds: (delay * 1000).round()),
        ),
      ],
      child: this,
    );
  }

  Widget slideIn({
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeOutCubic,
    Offset begin = const Offset(0, 0.2),
    double delay = 0,
  }) {
    return Animate(
      effects: [
        SlideEffect(
          begin: begin,
          end: Offset.zero,
          duration: duration,
          curve: curve,
          delay: Duration(milliseconds: (delay * 1000).round()),
        ),
        FadeEffect(
          duration: duration,
          curve: curve,
          delay: Duration(milliseconds: (delay * 1000).round()),
        ),
      ],
      child: this,
    );
  }

  Widget slideInLeft({
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeOutCubic,
    double delay = 0,
  }) {
    return slideIn(
      duration: duration,
      curve: curve,
      begin: const Offset(-0.2, 0),
      delay: delay,
    );
  }

  Widget slideInRight({
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeOutCubic,
    double delay = 0,
  }) {
    return slideIn(
      duration: duration,
      curve: curve,
      begin: const Offset(0.2, 0),
      delay: delay,
    );
  }

  Widget staggerIn({
    required int index,
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeOutCubic,
    Offset begin = const Offset(0, 0.15),
    Duration itemDelay = const Duration(milliseconds: 80),
  }) {
    return Animate(
      effects: [
        SlideEffect(
          begin: begin,
          end: Offset.zero,
          duration: duration,
          curve: curve,
          delay: itemDelay * index,
        ),
        FadeEffect(
          duration: duration,
          curve: curve,
          delay: itemDelay * index,
        ),
      ],
      child: this,
    );
  }

  Widget scaleOnTap({
    required VoidCallback onTap,
    double scale = 0.97,
    Duration duration = const Duration(milliseconds: 100),
    Curve curve = Curves.easeOut,
    Widget Function(BuildContext, Widget)? builder,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Animate(
        effects: [
          ScaleEffect(
            begin: const Offset(1, 1),
            end: Offset(scale, scale),
            duration: duration,
            curve: curve,
          ),
        ],
        onComplete: (controller) => controller.reverse(),
        child: builder != null ? builder(this as BuildContext, this) : this,
      ),
    );
  }

  Widget countUp({
    required double target,
    Duration duration = const Duration(milliseconds: 1000),
    Curve curve = Curves.easeOutCubic,
    int decimalPlaces = 0,
    String prefix = '',
    String suffix = '',
    TextStyle? style,
  }) {
    return _CountUpWidget(
      target: target,
      duration: duration,
      curve: curve,
      decimalPlaces: decimalPlaces,
      prefix: prefix,
      suffix: suffix,
      style: style,
      child: this,
    );
  }

  Widget shimmer({
    Duration duration = const Duration(milliseconds: 1500),
    Color? baseColor,
    Color? highlightColor,
    double delay = 0,
  }) {
    return Animate(
      effects: [
        ShimmerEffect(
          duration: duration,
          delay: Duration(milliseconds: (delay * 1000).round()),
          colors: [
            baseColor ?? const Color(0xFFE8E3F5),
            highlightColor ?? const Color(0xFFF0ECF9),
            baseColor ?? const Color(0xFFE8E3F5),
          ],
        ),
      ],
      child: this,
    );
  }

  Widget pulse({
    Duration duration = const Duration(milliseconds: 1000),
    double minScale = 1.0,
    double maxScale = 1.05,
    double delay = 0,
  }) {
    return Animate(
      effects: [
        ScaleEffect(
          begin: Offset(minScale, minScale),
          end: Offset(maxScale, maxScale),
          duration: duration,
          curve: Curves.easeInOut,
          delay: Duration(milliseconds: (delay * 1000).round()),
        ),
      ],
      onComplete: (controller) => controller.repeat(reverse: true),
      child: this,
    );
  }

  Widget bounceIn({
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.elasticOut,
    double delay = 0,
  }) {
    return Animate(
      effects: [
        ScaleEffect(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: duration,
          curve: curve,
          delay: Duration(milliseconds: (delay * 1000).round()),
        ),
      ],
      child: this,
    );
  }
}

class _CountUpWidget extends StatefulWidget {
  final double target;
  final Duration duration;
  final Curve curve;
  final int decimalPlaces;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final Widget child;

  const _CountUpWidget({
    required this.target,
    required this.duration,
    required this.curve,
    required this.decimalPlaces,
    required this.prefix,
    required this.suffix,
    required this.style,
    required this.child,
  });

  @override
  State<_CountUpWidget> createState() => _CountUpWidgetState();
}

class _CountUpWidgetState extends State<_CountUpWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: widget.target).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        final formatted = widget.decimalPlaces > 0
            ? value.toStringAsFixed(widget.decimalPlaces)
            : value.round().toString();
        return Text(
          '${widget.prefix}$formatted${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}

class AppShimmer {
  static Widget card({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor ?? const Color(0xFFE8E3F5),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
    ).shimmer(
      baseColor: baseColor ?? const Color(0xFFE8E3F5),
      highlightColor: highlightColor ?? const Color(0xFFF0ECF9),
    );
  }

  static Widget text({
    double? width,
    double height = 16,
    BorderRadius? borderRadius,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor ?? const Color(0xFFE8E3F5),
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    ).shimmer(
      baseColor: baseColor ?? const Color(0xFFE8E3F5),
      highlightColor: highlightColor ?? const Color(0xFFF0ECF9),
    );
  }

  static Widget circle({
    double size = 48,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: baseColor ?? const Color(0xFFE8E3F5),
        shape: BoxShape.circle,
      ),
    ).shimmer(
      baseColor: baseColor ?? const Color(0xFFE8E3F5),
      highlightColor: highlightColor ?? const Color(0xFFF0ECF9),
    );
  }

  static Widget list({
    int count = 5,
    double itemHeight = 80,
    double spacing = 12,
    EdgeInsets? padding,
  }) {
    return Column(
      children: List.generate(count, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == count - 1 ? 0 : spacing),
          child: AppShimmer.card(height: itemHeight),
        );
      }),
    ).animate().fadeIn(duration: 300.ms);
  }

  static Widget dashboard({
    int cardCount = 4,
    int chartPoints = 6,
    int listItems = 5,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            2,
            (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == 0 ? 8 : 0, left: i == 1 ? 8 : 0),
                child: AppShimmer.card(height: 120),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            2,
            (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == 0 ? 8 : 0, left: i == 1 ? 8 : 0),
                child: AppShimmer.card(height: 120),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        AppShimmer.card(height: 200),
        const SizedBox(height: 24),
        AppShimmer.list(count: listItems, itemHeight: 72),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  static Widget productCard() {
    return Row(
      children: [
        AppShimmer.circle(size: 60),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppShimmer.text(width: double.infinity, height: 16),
              const SizedBox(height: 8),
              AppShimmer.text(width: 120, height: 12),
              const SizedBox(height: 4),
              AppShimmer.text(width: 80, height: 14),
            ],
          ),
        ),
        const SizedBox(width: 12),
        AppShimmer.text(width: 80, height: 20),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  static Widget inventoryItem() {
    return Row(
      children: [
        AppShimmer.circle(size: 48),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppShimmer.text(width: double.infinity, height: 16),
              const SizedBox(height: 4),
              AppShimmer.text(width: 150, height: 12),
              const SizedBox(height: 4),
              Row(
                children: [
                  AppShimmer.text(width: 80, height: 12),
                  const SizedBox(width: 12),
                  AppShimmer.text(width: 80, height: 12),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        AppShimmer.text(width: 60, height: 20),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}

class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Axis scrollDirection;
  final Duration itemDuration;
  final Duration itemDelay;
  final Offset slideBegin;
  final Curve curve;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const StaggeredList({
    super.key,
    required this.children,
    this.scrollDirection = Axis.vertical,
    this.itemDuration = const Duration(milliseconds: 350),
    this.itemDelay = const Duration(milliseconds: 80),
    this.slideBegin = const Offset(0, 0.15),
    this.curve = Curves.easeOutCubic,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: scrollDirection,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children[index].animate().slide(
              begin: slideBegin,
              duration: itemDuration,
              curve: curve,
              delay: itemDelay * index,
            );
      },
    );
  }
}

class StaggeredColumn extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDuration;
  final Duration itemDelay;
  final Offset slideBegin;
  final Curve curve;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  const StaggeredColumn({
    super.key,
    required this.children,
    this.itemDuration = const Duration(milliseconds: 350),
    this.itemDelay = const Duration(milliseconds: 80),
    this.slideBegin = const Offset(0, 0.15),
    this.curve = Curves.easeOutCubic,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        return child.animate().slide(
              begin: slideBegin,
              duration: itemDuration,
              curve: curve,
              delay: itemDelay * index,
            );
      }).toList(),
    );
  }
}

class DashboardCounter extends StatefulWidget {
  final double target;
  final Duration duration;
  final Curve curve;
  final int decimalPlaces;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final bool animateOnBuild;

  const DashboardCounter({
    super.key,
    required this.target,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutCubic,
    this.decimalPlaces = 0,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.animateOnBuild = true,
  });

  @override
  State<DashboardCounter> createState() => _DashboardCounterState();
}

class _DashboardCounterState extends State<DashboardCounter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: widget.target).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    if (widget.animateOnBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant DashboardCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      _animation = Tween<double>(begin: _animation.value, end: widget.target).animate(
        CurvedAnimation(parent: _controller, curve: widget.curve),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        final formatted = widget.decimalPlaces > 0
            ? value.toStringAsFixed(widget.decimalPlaces)
            : value.round().toString();
        return Text(
          '${widget.prefix}$formatted${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}

class AnimatedBarChart extends StatefulWidget {
  final List<double> values;
  final List<String> labels;
  final Color barColor;
  final Color backgroundColor;
  final double maxHeight;
  final Duration duration;
  final Curve curve;
  final double barWidth;
  final double spacing;
  final bool animateOnBuild;
  final Widget? Function(double value, String label)? tooltipBuilder;

  const AnimatedBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.barColor = const Color(0xFF651FFF),
    this.backgroundColor = const Color(0xFFE8E3F5),
    this.maxHeight = 160,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutCubic,
    this.barWidth = 32,
    this.spacing = 16,
    this.animateOnBuild = true,
    this.tooltipBuilder,
  });

  @override
  State<AnimatedBarChart> createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<AnimatedBarChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animations = List.generate(
      widget.values.length,
      (index) => Tween<double>(begin: 0, end: widget.values[index]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            (index / widget.values.length) * 0.5,
            0.5 + (index / widget.values.length) * 0.5,
            curve: widget.curve,
          ),
        ),
      ),
    );
    if (widget.animateOnBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      _animations = List.generate(
        widget.values.length,
        (index) => Tween<double>(begin: 0, end: widget.values[index]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              (index / widget.values.length) * 0.5,
              0.5 + (index / widget.values.length) * 0.5,
              curve: widget.curve,
            ),
          ),
        ),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = widget.values.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) maxValue == 1;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(widget.values.length, (index) {
            final animatedValue = _animations[index].value;
            final height = maxValue > 0
                ? (animatedValue / maxValue) * widget.maxHeight
                : 0.0;
            final label = index < widget.labels.length ? widget.labels[index] : '';

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                (widget.tooltipBuilder?.call(animatedValue, label) ??
                        const SizedBox.shrink()),
                const SizedBox(height: 4),
                Container(
                  width: widget.barWidth,
                  height: height,
                  decoration: BoxDecoration(
                    color: widget.barColor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }),
        );
      },
    );
  }
}

class PullToRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;

  const PullToRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.displacement = 80,
  });

  @override
  State<PullToRefreshIndicator> createState() => _PullToRefreshIndicatorState();
}

class _PullToRefreshIndicatorState extends State<PullToRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  bool _isRefreshing = false;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _rotation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    _controller.repeat();
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        _controller.stop();
        _controller.reset();
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primary;
    final bgColor = widget.backgroundColor ?? theme.colorScheme.surface;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final offset = notification.metrics.pixels;
          if (offset < 0 && !_isRefreshing) {
            setState(() => _dragOffset = (-offset).clamp(0, widget.displacement));
          }
        } else if (notification is ScrollEndNotification) {
          if (_dragOffset >= widget.displacement && !_isRefreshing) {
            _handleRefresh();
          }
          setState(() => _dragOffset = 0);
        }
        return false;
      },
      child: Stack(
        children: [
          widget.child,
          if (_dragOffset > 0 || _isRefreshing)
            Positioned(
              top: -widget.displacement + _dragOffset,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _isRefreshing ? _rotation : Listenable.merge([]),
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _isRefreshing
                          ? _rotation.value * 2 * 3.14159
                          : (_dragOffset / widget.displacement) * 0.5,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: bgColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_downward_rounded,
                            color: color,
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HapticFeedback {
  static void lightImpact() {
    // import 'package:flutter/services.dart';
    // ServicesBinding.instance.defaultBinaryMessenger
    //     .setMessageHandler('flutter/platform', (message) async {});
  }

  static void mediumImpact() {}

  static void heavyImpact() {}

  static void selectionClick() {}

  static void success() {}

  static void warning() {}

  static void error() {}
}