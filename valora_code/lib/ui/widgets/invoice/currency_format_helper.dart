import 'package:intl/intl.dart';

final _copFormatter = NumberFormat.currency(
  locale: 'es_CO',
  symbol: '\$',
  decimalDigits: 0,
);

String formatCop(double amount) => _copFormatter.format(amount);
