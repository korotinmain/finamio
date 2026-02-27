import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final Map<String, NumberFormat> _currencyFormats = {};

  static NumberFormat _getCurrencyFormat(
    String symbol, {
    bool compact = false,
  }) {
    final key = '$symbol$compact';
    return _currencyFormats.putIfAbsent(key, () {
      if (compact) {
        return NumberFormat.compactCurrency(symbol: symbol, decimalDigits: 1);
      }
      return NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    });
  }

  static String formatAmount(
    double amount, {
    String symbol = '\$',
    bool compact = false,
    bool showSign = false,
  }) {
    final abs = amount.abs();
    final formatted = _getCurrencyFormat(symbol, compact: compact).format(abs);
    if (showSign) {
      return amount >= 0 ? '+$formatted' : '-$formatted';
    }
    return amount < 0 ? '-$formatted' : formatted;
  }

  static String formatDate(DateTime date) =>
      DateFormat('MMM d, yyyy').format(date);

  static String formatShortDate(DateTime date) =>
      DateFormat('MMM d').format(date);

  static String formatMonthYear(DateTime date) =>
      DateFormat('MMMM yyyy').format(date);

  static String formatTime(DateTime date) => DateFormat('h:mm a').format(date);

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return formatShortDate(date);
  }

  static String formatPercentage(double value, {int decimals = 1}) =>
      '${value.toStringAsFixed(decimals)}%';

  static String formatCompactNumber(double value) =>
      NumberFormat.compact().format(value);
}
