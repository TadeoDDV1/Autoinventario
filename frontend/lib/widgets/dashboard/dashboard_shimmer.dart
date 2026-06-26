import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'dashboard_constants.dart';

/// Skeleton que replica la estructura del dashboard real mientras
/// el provider carga datos. Usa shimmer (paquete ya en pubspec).
/// No es idéntico al dashboard final — solo mantiene proporciones
/// para que la transición data→skeleton sea visualmente coherente.
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceContainerHighest;
    final highlight = theme.colorScheme.surface;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView(
        padding: const EdgeInsets.all(DashboardSpacing.lg),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Header
          _bar(width: 200, height: 24),
          const SizedBox(height: DashboardSpacing.sm),
          _bar(width: 140, height: 14),
          const SizedBox(height: DashboardSpacing.xl),

          // Hero card
          _shimmerBox(height: 140),
          const SizedBox(height: DashboardSpacing.lg),

          // 3 cards secundarias
          Row(
            children: [
              Expanded(child: _shimmerBox(height: DashboardSizes.cardSecundariaHeight)),
              const SizedBox(width: DashboardSpacing.md),
              Expanded(child: _shimmerBox(height: DashboardSizes.cardSecundariaHeight)),
              const SizedBox(width: DashboardSpacing.md),
              Expanded(child: _shimmerBox(height: DashboardSizes.cardSecundariaHeight)),
            ],
          ),
          const SizedBox(height: DashboardSpacing.xl),

          // Top productos header
          _bar(width: 160, height: 18),
          const SizedBox(height: DashboardSpacing.sm),
          ...List.generate(5, (_) => Padding(
                padding: const EdgeInsets.only(bottom: DashboardSpacing.sm),
                child: _shimmerBox(height: DashboardSizes.rowListHeight),
              )),

          const SizedBox(height: DashboardSpacing.xl),

          // Chart header
          _bar(width: 180, height: 18),
          const SizedBox(height: DashboardSpacing.sm),
          _shimmerBox(height: DashboardSizes.chartHeight),
        ],
      ),
    );
  }

  Widget _shimmerBox({required double height}) => Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DashboardRadius.lg),
        ),
      );

  Widget _bar({required double width, required double height}) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DashboardRadius.sm),
        ),
      );
}