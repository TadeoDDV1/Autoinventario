import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dashboard_constants.dart';

class SeccionHeader extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final Color? color;
  final Widget? trailing;
  final int? badgeCount;

  const SeccionHeader({
    super.key,
    required this.titulo,
    required this.icon,
    this.color,
    this.trailing,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: DashboardSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: c, size: 18),
          ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.5, 0.5)),
          const SizedBox(width: DashboardSpacing.sm),
          Expanded(
            child: Text(
              titulo,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 50.ms).slideX(begin: -0.1),
          ),
          if (badgeCount != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DashboardSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(DashboardRadius.sm),
              ),
              child: Text(
                '$badgeCount',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: c,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms).scale(begin: const Offset(0.5, 0.5)),
            const SizedBox(width: DashboardSpacing.sm),
          ],
          trailing != null
              ? trailing!.animate().fadeIn(duration: 300.ms, delay: 150.ms)
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}