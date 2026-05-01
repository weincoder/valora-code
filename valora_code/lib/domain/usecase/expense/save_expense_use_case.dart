import '../../models/expense/gateway/expense_gateway.dart';
import '../../models/expense/expense.dart';

class SaveExpenseUseCase {
  final ExpenseGateway gateway;

  SaveExpenseUseCase({required this.gateway});

  Future<void> execute(Expense expense) => gateway.save(expense);
}
