import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:valora_code/domain/models/expense/expense.dart';
import 'package:valora_code/domain/models/expense/expense_category.dart';
import 'package:valora_code/infrastructure/driven_adapters/expense/expense_hive_adapter.dart';

void main() {
  late ExpenseHiveAdapter adapter;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_expense_test_');
    Hive.init(tempDir.path);
  });

  setUp(() {
    adapter = ExpenseHiveAdapter();
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk('expenses');
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  final sampleExpense = Expense(
    id: 'exp-1',
    description: 'Compra de materiales',
    amount: 150.0,
    category: ExpenseCategory.services,
    date: DateTime(2025, 3, 15),
    notes: 'Nota de prueba',
  );

  group('ExpenseHiveAdapter', () {
    test('getAll returns empty list when box is empty', () async {
      // Arrange & Act
      final result = await adapter.getAll();

      // Assert
      expect(result, isEmpty);
    });

    test('save persists an expense and getAll returns it', () async {
      // Arrange & Act
      await adapter.save(sampleExpense);
      final result = await adapter.getAll();

      // Assert
      expect(result.length, 1);
      expect(result.first.id, 'exp-1');
      expect(result.first.description, 'Compra de materiales');
      expect(result.first.amount, 150.0);
      expect(result.first.category, ExpenseCategory.services);
    });

    test('save overwrites expense with same id', () async {
      // Arrange
      await adapter.save(sampleExpense);
      final updated = Expense(
        id: 'exp-1',
        description: 'Descripción actualizada',
        amount: 200.0,
        category: ExpenseCategory.other,
        date: DateTime(2025, 4, 1),
      );

      // Act
      await adapter.save(updated);
      final result = await adapter.getAll();

      // Assert
      expect(result.length, 1);
      expect(result.first.description, 'Descripción actualizada');
      expect(result.first.amount, 200.0);
    });

    test('delete removes expense by id', () async {
      // Arrange
      await adapter.save(sampleExpense);

      // Act
      await adapter.delete('exp-1');
      final result = await adapter.getAll();

      // Assert
      expect(result, isEmpty);
    });

    test('delete non-existent id does not throw', () async {
      // Arrange & Act & Assert
      expect(() => adapter.delete('non-existent'), returnsNormally);
    });

    test('save multiple expenses and retrieve all', () async {
      // Arrange
      final expense2 = Expense(
        id: 'exp-2',
        description: 'Software',
        amount: 500.0,
        category: ExpenseCategory.software,
        date: DateTime(2025, 4, 10),
      );

      // Act
      await adapter.save(sampleExpense);
      await adapter.save(expense2);
      final result = await adapter.getAll();

      // Assert
      expect(result.length, 2);
      expect(result.map((e) => e.id), containsAll(['exp-1', 'exp-2']));
    });
  });
}
