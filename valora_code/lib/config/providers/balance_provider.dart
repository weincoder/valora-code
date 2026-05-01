import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/balance/balance_report.dart';
import '../../domain/usecase/balance/get_balance_use_case.dart';
import 'expense_provider.dart';
import 'sale_record_provider.dart';

final balanceProvider = Provider<BalanceReport>((ref) {
  final records = ref.watch(saleRecordProvider).records;
  final expenses = ref.watch(expenseProvider).expenses;
  return GetBalanceUseCase().execute(records, expenses);
});
