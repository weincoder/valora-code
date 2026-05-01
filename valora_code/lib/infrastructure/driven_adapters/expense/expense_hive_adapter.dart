import 'package:hive_flutter/hive_flutter.dart';
import '../../../domain/models/expense/expense.dart';
import '../../../domain/models/expense/gateway/expense_gateway.dart';
import '../../helpers/mappers/expense_mapper.dart';

class ExpenseHiveAdapter implements ExpenseGateway {
  static const String _boxName = 'expenses';

  Future<Box> get _box async => Hive.openBox(_boxName);

  @override
  Future<List<Expense>> getAll() async {
    final box = await _box;
    return box.values.map((e) => expenseFromJson(e as Map)).toList();
  }

  @override
  Future<void> save(Expense expense) async {
    final box = await _box;
    await box.put(expense.id, expenseToJson(expense));
  }

  @override
  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<void> clear() async {
    final box = await _box;
    await box.clear();
  }
}
