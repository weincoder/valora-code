import 'package:intl/intl.dart';

final _copFormatter = NumberFormat.currency(
  locale: 'es_CO',
  symbol: '\$',
  decimalDigits: 0,
);

String formatCop(double amount) => _copFormatter.format(amount);

String formatCurrency(double amount, String currency) {
  if (currency == 'USD') {
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: 'USD \$',
      decimalDigits: 2,
    ).format(amount);
  }
  return _copFormatter.format(amount);
}
