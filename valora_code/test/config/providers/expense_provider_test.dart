import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/config/providers/expense_provider.dart';
import 'package:valora_code/domain/models/expense/expense.dart';
import 'package:valora_code/domain/models/expense/expense_category.dart';
import 'package:valora_code/domain/models/expense/gateway/expense_gateway.dart';
import 'package:valora_code/domain/usecase/expense/get_all_expenses_use_case.dart';
import 'package:valora_code/domain/usecase/expense/save_expense_use_case.dart';
import 'package:valora_code/domain/usecase/expense/delete_expense_use_case.dart';

class MockExpenseGateway extends Mock implements ExpenseGateway {}

final _sampleExpense = Expense(
  id: 'exp-test-1',
  description: 'Licencia Figma',
  amount: 300.0,
  category: ExpenseCategory.software,
  date: DateTime(2025, 5, 1),
);

ExpenseNotifier _makeNotifier(MockExpenseGateway gateway) {
  return ExpenseNotifier(
    getAll: GetAllExpensesUseCase(gateway: gateway),
    save: SaveExpenseUseCase(gateway: gateway),
    delete: DeleteExpenseUseCase(gateway: gateway),
  );
}

void main() {
  late MockExpenseGateway mockGateway;

  setUpAll(() {
    registerFallbackValue(_sampleExpense);
  });

  setUp(() {
    mockGateway = MockExpenseGateway();
  });

  group('ExpenseNotifier.load', () {
    test('should emit expenses from gateway after load', () async {
      // Arrange
      when(
        () => mockGateway.getAll(),
      ).thenAnswer((_) async => [_sampleExpense]);
      final container = ProviderContainer(
        overrides: [
          expenseProvider.overrideWith((_) => _makeNotifier(mockGateway)),
        ],
      );
      addTearDown(container.dispose);

      // Act
      await container.read(expenseProvider.notifier).load();

      // Assert
      final state = container.read(expenseProvider);
      expect(state.expenses, hasLength(1));
      expect(state.expenses.first.id, equals('exp-test-1'));
      expect(state.isLoading, isFalse);
    });

    test('should set error when gateway throws', () async {
      // Arrange
      when(() => mockGateway.getAll()).thenThrow(Exception('DB fail'));
      final container = ProviderContainer(
        overrides: [
          expenseProvider.overrideWith((_) => _makeNotifier(mockGateway)),
        ],
      );
      addTearDown(container.dispose);

      // Act
      await container.read(expenseProvider.notifier).load();

      // Assert
      final state = container.read(expenseProvider);
      expect(state.error, isNotNull);
      expect(state.expenses, isEmpty);
    });
  });

  group('ExpenseNotifier.delete', () {
    test('should call gateway.delete and reload', () async {
      // Arrange
      when(() => mockGateway.delete(any())).thenAnswer((_) async {});
      when(() => mockGateway.getAll()).thenAnswer((_) async => []);
      final container = ProviderContainer(
        overrides: [
          expenseProvider.overrideWith((_) => _makeNotifier(mockGateway)),
        ],
      );
      addTearDown(container.dispose);

      // Act
      await container.read(expenseProvider.notifier).delete('exp-test-1');

      // Assert
      verify(() => mockGateway.delete('exp-test-1')).called(1);
    });
  });
}
