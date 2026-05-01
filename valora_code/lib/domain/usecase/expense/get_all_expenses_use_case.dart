import '../../models/expense/gateway/expense_gateway.dart';
import '../../models/expense/expense.dart';

class GetAllExpensesUseCase {
  final ExpenseGateway gateway;

  GetAllExpensesUseCase({required this.gateway});

  Future<List<Expense>> execute() => gateway.getAll();
}
