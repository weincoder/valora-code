import 'expense_category.dart';

class Expense {
  final String id;
  final String description;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? notes;

  const Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });

  Expense copyWith({
    String? id,
    String? description,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? notes,
    bool clearNotes = false,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }
}
