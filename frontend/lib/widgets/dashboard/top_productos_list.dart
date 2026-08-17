import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/format/money.dart';
import '../../models/sugerencia.dart';
import 'dashboard_constants.dart';

class TopProductosList extends StatelessWidget {
  final List<TopProducto> productos;
  final int maxItems;
  final void Function(TopProducto)? onTap;

  const TopProductosList({
    super.key,
    required this.productos,
    this.maxItems = 5,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = money;
    if (productos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(DashboardSpacing.xl),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.shopping_bag,
                size: 40, color: theme.colorScheme.outline),
            const SizedBox(height: DashboardSpacing.sm),
            Text('Aún no hay ventas hoy',
                style: theme.textTheme.titleSmall),
            const SizedBox(height: DashboardSpacing.xs),
            Text(
              'Cuando registres ventas aparecerán aquí',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    final items = productos.take(maxItems).toList();
    final maxTotal = items.fold<double>(
      0,
      (m, p) => p.totalVenta > m ? p.totalVenta : m,
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _TopProductoRow(
              rank: i + 1,
              producto: items[i],
              maxTotal: maxTotal,
              formatter: formatter,
              onTap: onTap == null ? null : () => onTap!(items[i]),
            ),
            if (i < items.length - 1)
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                indent: DashboardSpacing.lg,
                endIndent: DashboardSpacing.lg,
              ),
          ],
        ],
      ),
    );
  }
}

class _TopProductoRow extends StatefulWidget {
  final int rank;
  final TopProducto producto;
  final double maxTotal;
  final NumberFormat formatter;
  final VoidCallback? onTap;

  const _TopProductoRow({
    required this.rank,
    required this.producto,
    required this.maxTotal,
    required this.formatter,
    this.onTap,
  });

  @override
  State<_TopProductoRow> createState() => _TopProductoRowState();
}

class _TopProductoRowState extends State<_TopProductoRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = widget.maxTotal == 0
        ? 0.0
        : widget.producto.totalVenta / widget.maxTotal;
    final isPodium = widget.rank <= 3;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DashboardSpacing.md,
          vertical: DashboardSpacing.sm,
        ),
        child: Row(
          children: [
            _RankBadge(rank: widget.rank, isPodium: isPodium),
            const SizedBox(width: DashboardSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.producto.nombre,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: ratio * _progressAnimation.value,
                          minHeight: 4,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isPodium
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primary.withValues(alpha: 0.55),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.producto.cantidad} uds',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DashboardSpacing.md),
            Text(
              widget.formatter.format(widget.producto.totalVenta),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  final bool isPodium;
  const _RankBadge({required this.rank, required this.isPodium});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medal = switch (rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => null,
    };
    if (medal != null) {
      return SizedBox(
        width: 32,
        height: 32,
        child: Center(child: Text(medal, style: const TextStyle(fontSize: 20))),
      );
    }
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}