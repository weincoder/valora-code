import '../../../domain/models/expense/expense.dart';
import '../../../domain/models/expense/expense_category.dart';

Map<String, dynamic> expenseToJson(Expense e) => {
  'id': e.id,
  'description': e.description,
  'amount': e.amount,
  'category': e.category.name,
  'date': e.date.toIso8601String(),
  'notes': e.notes,
};

Expense expenseFromJson(Map<dynamic, dynamic> map) => Expense(
  id: map['id'] as String? ?? '',
  description: map['description'] as String? ?? 'Sin descripción',
  amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
  category: _parseCategory(map['category'] as String?),
  date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
  notes: map['notes'] as String?,
);

ExpenseCategory _parseCategory(String? value) {
  return ExpenseCategory.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ExpenseCategory.other,
  );
}
