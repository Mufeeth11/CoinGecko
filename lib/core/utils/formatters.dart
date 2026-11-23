import 'package:intl/intl.dart';

/// Presentation-only helpers. Kept free of BuildContext so they are trivial to
/// unit test.
abstract final class Formatters {
  static String currency(double? value) {
    if (value == null) return '—';
    if (value == 0) return r'$0.00';
    final absolute = value.abs();
    final digits = absolute >= 1000
        ? 2
        : absolute >= 1
        ? 2
        : absolute >= 0.01
        ? 4
        : 6;
    return '\$${value.toStringAsFixed(digits)}';
  }

  static String compact(num? value) {
    if (value == null) return '—';
    final absolute = value.abs().toDouble();
    if (absolute >= 1e12) return '${_trim(value / 1e12)}T';
    if (absolute >= 1e9) return '${_trim(value / 1e9)}B';
    if (absolute >= 1e6) return '${_trim(value / 1e6)}M';
    if (absolute >= 1e3) return '${_trim(value / 1e3)}K';
    return _trim(value);
  }

  static String compactCurrency(num? value) =>
      value == null ? '—' : r'$' + compact(value);

  static String supply(num? value, [String? symbol]) {
    if (value == null) return '—';
    final formatted = compact(value);
    return symbol == null || symbol.isEmpty
        ? formatted
        : '$formatted ${symbol.toUpperCase()}';
  }

  static String percent(double? value, {bool signed = false}) {
    if (value == null) return '—';
    final prefix = signed && value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(2)}%';
  }

  static String signedPercent(double? value) => percent(value, signed: true);

  static String dateTime(dynamic value) {
    DateTime? date;
    if (value is DateTime) {
      date = value;
    } else if (value is int) {
      date = DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      date = DateTime.tryParse(value);
    }
    if (date == null) return '—';
    return DateFormat.yMMMd().add_Hm().format(date.toLocal());
  }

  static String shortDate(dynamic value) {
    DateTime? date;
    if (value is DateTime) {
      date = value;
    } else if (value is int) {
      date = DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (date == null) return '—';
    return DateFormat.MMMd().format(date.toLocal());
  }

  static String _trim(num value) {
    final fixed = value.toStringAsFixed(value.abs() >= 100 ? 0 : 2);
    return fixed.endsWith('.00') ? fixed.substring(0, fixed.length - 3) : fixed;
  }
}
