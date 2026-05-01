import '../../models/expense/gateway/expense_gateway.dart';

class DeleteExpenseUseCase {
  final ExpenseGateway gateway;

  DeleteExpenseUseCase({required this.gateway});

  Future<void> execute(String id) => gateway.delete(id);
}
