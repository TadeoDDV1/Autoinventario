import 'package:flutter/material.dart';

class NavTab {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String? badge;

  const NavTab({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badge,
  });
}

class AnimatedBottomNavBar extends StatelessWidget {
  final List<NavTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Color? backgroundColor;
  final double height;
  final BorderRadius? borderRadius;

  const AnimatedBottomNavBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.backgroundColor,
    this.height = 72,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ??
        (theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : theme.colorScheme.surface);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius ?? BorderRadius.zero,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        boxShadow: theme.brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == selectedIndex;
          return Expanded(
            child: _AnimatedNavTabItem(
              tab: tab,
              isSelected: isSelected,
              onTap: () => onTabSelected(index),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AnimatedNavTabItem extends StatefulWidget {
  final NavTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedNavTabItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedNavTabItem> createState() => _AnimatedNavTabItemState();
}

class _AnimatedNavTabItemState extends State<_AnimatedNavTabItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTapDown: (_) {
        _pressController.forward();
      },
      onTapUp: (_) {
        _pressController.reverse();
        _handleTap();
      },
      onTapCancel: () {
        _pressController.reverse();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          final pressScale = 1.0 - (_pressController.value * 0.08);
          return Transform.scale(
            scale: pressScale,
            child: child,
          );
        },
        child: SizedBox(
          height: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                top: widget.isSelected ? 8 : 12,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: widget.isSelected ? 64 : 0,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? primaryColor.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    scale: widget.isSelected ? 1.1 : 1.0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Icon(
                            widget.isSelected
                                ? widget.tab.selectedIcon
                                : widget.tab.icon,
                            key: ValueKey(
                              '${widget.tab.label}_${widget.isSelected}',
                            ),
                            color: widget.isSelected
                                ? primaryColor
                                : onSurfaceVariant,
                            size: 24,
                          ),
                        ),
                        if (widget.tab.badge != null)
                          Positioned(
                            right: -8,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: theme.colorScheme.surface,
                                  width: 1.5,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                widget.tab.badge!,
                                style: TextStyle(
                                  color: theme.colorScheme.onError,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: widget.isSelected
                          ? primaryColor
                          : onSurfaceVariant,
                      letterSpacing: 0.2,
                    ),
                    child: Text(widget.tab.label),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedNavRail extends StatelessWidget {
  final List<NavTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final double width;
  final Color? backgroundColor;
  final Widget? leading;
  final Widget? trailing;

  const AnimatedNavRail({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.width = 90,
    this.backgroundColor,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ??
        (theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : theme.colorScheme.surface);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          if (leading != null) Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: leading!,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                final isSelected = index == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _AnimatedRailItem(
                    tab: tab,
                    isSelected: isSelected,
                    onTap: () => onTabSelected(index),
                  ),
                );
              }).toList(),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _AnimatedRailItem extends StatefulWidget {
  final NavTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedRailItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedRailItem> createState() => _AnimatedRailItemState();
}

class _AnimatedRailItemState extends State<_AnimatedRailItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: widget.onTap,
      onHover: (hovered) {
        if (hovered) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? primaryColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      widget.isSelected
                          ? widget.tab.selectedIcon
                          : widget.tab.icon,
                      key: ValueKey(
                        '${widget.tab.label}_rail_${widget.isSelected}',
                      ),
                      color: widget.isSelected
                          ? primaryColor
                          : onSurfaceVariant,
                      size: 26,
                    ),
                  ),
                  if (widget.tab.badge != null)
                    Positioned(
                      right: -6,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: bgColorSafe(context),
                            width: 1.5,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          widget.tab.badge!,
                          style: TextStyle(
                            color: theme.colorScheme.onError,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 10,
                fontWeight: widget.isSelected
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: widget.isSelected
                    ? primaryColor
                    : onSurfaceVariant,
              ),
              child: Text(widget.tab.label),
            ),
          ],
        ),
      ),
    );
  }

  Color bgColorSafe(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1B41) : Colors.white;
  }
}