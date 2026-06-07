import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _currencyFmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _currencyFmtDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final DateFormat _dateFmt = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFmt = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _monthFmt = DateFormat('MMM');

  static String formatCurrency(double amount) {
    return _currencyFmt.format(amount);
  }

  static String formatCurrencyDecimals(double amount) {
    return _currencyFmtDecimals.format(amount);
  }

  static String formatCurrencyCompact(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return formatCurrency(amount);
  }

  static String formatDate(DateTime date) {
    return _dateFmt.format(date);
  }

  static String formatDateTime(DateTime date) {
    return _dateTimeFmt.format(date);
  }

  static String formatMonth(DateTime date) {
    return _monthFmt.format(date);
  }

  static String formatPhoneNumber(String phone) {
    if (phone.length == 10) {
      return '+91 ${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return phone;
  }

  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) return '${duration.inDays} days';
    if (duration.inHours > 0) return '${duration.inHours} hrs';
    return '${duration.inMinutes} min';
  }

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 30) return formatDate(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
