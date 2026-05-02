import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/config/providers/expense_provider.dart';
import 'package:valora_code/domain/models/expense/expense.dart';
import 'package:valora_code/domain/models/expense/expense_category.dart';
import 'package:valora_code/domain/models/expense/gateway/expense_gateway.dart';
import 'package:valora_code/domain/usecase/expense/delete_expense_use_case.dart';
import 'package:valora_code/domain/usecase/expense/get_all_expenses_use_case.dart';
import 'package:valora_code/domain/usecase/expense/save_expense_use_case.dart';
import 'package:valora_code/ui/pages/expense/expense_list_page.dart';

class _MockExpenseGateway extends Mock implements ExpenseGateway {}

final _sampleExpense = Expense(
  id: 'exp-1',
  description: 'Hosting',
  amount: 100.0,
  category: ExpenseCategory.services,
  date: DateTime(2025, 3, 1),
);

Widget _buildApp({List<Expense> expenses = const []}) {
  final mock = _MockExpenseGateway();
  when(() => mock.getAll()).thenAnswer((_) async => expenses);
  when(() => mock.save(any())).thenAnswer((_) async {});
  when(() => mock.delete(any())).thenAnswer((_) async {});

  return ProviderScope(
    overrides: [
      expenseProvider.overrideWith(
        (_) => ExpenseNotifier(
          getAll: GetAllExpensesUseCase(gateway: mock),
          save: SaveExpenseUseCase(gateway: mock),
          delete: DeleteExpenseUseCase(gateway: mock),
        ),
      ),
    ],
    child: const MaterialApp(home: ExpenseListPage()),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_sampleExpense);
  });

  group('Find the page widgets', () {
    testWidgets('should find AppBar with Gastos title', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.text('Gastos'), findsOneWidget);
    });

    testWidgets('should show empty state when no expenses', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());
      await tester.pump(); // process microtask
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // complete async load

      // Act & Assert
      expect(find.byKey(const Key('expenses-empty-text')), findsOneWidget);
    });
  });

  group('Interaction with page widgets', () {
    testWidgets('should show list when expenses exist', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp(expenses: [_sampleExpense]));
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byKey(const Key('expenses-list')), findsOneWidget);
    });

    testWidgets('should show expense description in card', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp(expenses: [_sampleExpense]));
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.text('Hosting'), findsOneWidget);
    });
  });

  group('Test Page Experience', () {
    testWidgets('should show delete confirmation dialog on delete tap', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_buildApp(expenses: [_sampleExpense]));
      await tester.pumpAndSettle();

      // Act — tap the delete icon in the card
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Eliminar gasto'), findsOneWidget);
    });

    testWidgets('should dismiss delete dialog on cancel', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp(expenses: [_sampleExpense]));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Eliminar gasto'), findsNothing);
    });
  });
}
