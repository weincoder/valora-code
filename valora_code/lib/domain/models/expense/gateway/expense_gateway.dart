import '../expense.dart';

abstract class ExpenseGateway {
  Future<List<Expense>> getAll();
  Future<void> save(Expense expense);
  Future<void> delete(String id);
}
