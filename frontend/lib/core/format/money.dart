import 'package:intl/intl.dart';

/// Formateador de dinero compartido en toda la app.
/// Usar siempre esta función en lugar de crear NumberFormat manualmente
/// para mantener consistencia visual.
final NumberFormat money = NumberFormat.currency(
  symbol: r'$',
  decimalDigits: 2,
);

/// Formato compacto para snippets (e.g. snackbars, badges).
String formatMoneyCompact(double value) {
  if (value.abs() >= 1000000) {
    return '\$${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value.abs() >= 1000) {
    return '\$${(value / 1000).toStringAsFixed(1)}K';
  }
  return money.format(value);
}
