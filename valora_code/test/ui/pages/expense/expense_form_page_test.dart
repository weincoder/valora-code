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
import 'package:valora_code/ui/pages/expense/expense_form_page.dart';

class _MockExpenseGateway extends Mock implements ExpenseGateway {}

final _sampleExpense = Expense(
  id: 'exp-test-1',
  description: 'Licencia software',
  amount: 150.0,
  category: ExpenseCategory.software,
  date: DateTime(2025, 5, 1),
);

Widget _buildApp({
  String? expenseId,
  List<Expense> initialExpenses = const [],
}) {
  final mock = _MockExpenseGateway();
  when(() => mock.getAll()).thenAnswer((_) async => initialExpenses);
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
    child: MaterialApp(home: ExpenseFormPage(expenseId: expenseId)),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_sampleExpense);
  });

  group('Find the page widgets', () {
    testWidgets('should find AppBar with Registrar gasto title', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.text('Registrar gasto'), findsAtLeastNWidgets(1));
    });

    testWidgets('should find description and amount fields', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('expense-description')), findsOneWidget);
      expect(find.byKey(const Key('expense-amount')), findsOneWidget);
    });

    testWidgets('should find category dropdown', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('expense-category')), findsOneWidget);
    });

    testWidgets('should find date picker tile', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('expense-date')), findsOneWidget);
    });

    testWidgets('should find save button', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('expense-save-btn')), findsOneWidget);
      expect(find.text('Registrar gasto'), findsAtLeastNWidgets(1));
    });
  });

  group('Interaction with page widgets', () {
    testWidgets('should show validation error when description is empty', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act
      await tester.tap(find.byKey(const Key('expense-save-btn')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ingresa una descripción'), findsOneWidget);
    });

    testWidgets('should show validation error when amount is invalid', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_buildApp());
      await tester.enterText(
        find.byKey(const Key('expense-description')),
        'Prueba',
      );

      // Act
      await tester.tap(find.byKey(const Key('expense-save-btn')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ingresa un monto válido'), findsOneWidget);
    });

    testWidgets('should accept text input in description field', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act
      await tester.enterText(
        find.byKey(const Key('expense-description')),
        'Hosting AWS',
      );
      await tester.pump();

      // Assert
      expect(find.text('Hosting AWS'), findsOneWidget);
    });
  });

  group('Test Page Experience', () {
    testWidgets('should show notes field', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('expense-notes')), findsOneWidget);
    });

    testWidgets('should display current date in date tile', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());
      final now = DateTime.now();

      // Act & Assert
      expect(
        find.textContaining('Fecha: ${now.day}/${now.month}/${now.year}'),
        findsOneWidget,
      );
    });
  });
}
