import 'package:flutter_test/flutter_test.dart';
import 'package:valora_code/domain/models/expense/expense.dart';
import 'package:valora_code/domain/models/expense/expense_category.dart';

Expense _makeExpense({
  String id = 'exp-1',
  String description = 'Dominio web',
  double amount = 150.0,
  ExpenseCategory category = ExpenseCategory.software,
  DateTime? date,
  String? notes,
}) {
  return Expense(
    id: id,
    description: description,
    amount: amount,
    category: category,
    date: date ?? DateTime(2025, 5, 10),
    notes: notes,
  );
}

void main() {
  group('Expense', () {
    test('should create an Expense with all required fields', () {
      // Arrange & Act
      final expense = _makeExpense();

      // Assert
      expect(expense.id, equals('exp-1'));
      expect(expense.description, equals('Dominio web'));
      expect(expense.amount, equals(150.0));
      expect(expense.category, equals(ExpenseCategory.software));
      expect(expense.date, equals(DateTime(2025, 5, 10)));
      expect(expense.notes, isNull);
    });

    test('should create an Expense with optional notes', () {
      // Arrange & Act
      final expense = _makeExpense(notes: 'Renovación anual');

      // Assert
      expect(expense.notes, equals('Renovación anual'));
    });

    group('copyWith', () {
      test('should return a new expense with updated amount', () {
        // Arrange
        final original = _makeExpense();

        // Act
        final copy = original.copyWith(amount: 200.0);

        // Assert
        expect(copy.amount, equals(200.0));
        expect(copy.id, equals(original.id));
        expect(copy.description, equals(original.description));
      });

      test('should update category', () {
        // Arrange
        final original = _makeExpense();

        // Act
        final copy = original.copyWith(category: ExpenseCategory.marketing);

        // Assert
        expect(copy.category, equals(ExpenseCategory.marketing));
      });

      test('should clear notes when clearNotes is true', () {
        // Arrange
        final original = _makeExpense(notes: 'Una nota');

        // Act
        final copy = original.copyWith(clearNotes: true);

        // Assert
        expect(copy.notes, isNull);
      });
    });
  });

  group('ExpenseCategory', () {
    test('should have correct labels', () {
      expect(ExpenseCategory.software.label, equals('Software'));
      expect(ExpenseCategory.hardware.label, equals('Hardware'));
      expect(ExpenseCategory.marketing.label, equals('Marketing'));
      expect(ExpenseCategory.services.label, equals('Servicios'));
      expect(ExpenseCategory.other.label, equals('Otro'));
    });
  });
}
