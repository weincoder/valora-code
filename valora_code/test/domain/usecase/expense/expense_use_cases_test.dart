import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/domain/models/expense/expense.dart';
import 'package:valora_code/domain/models/expense/expense_category.dart';
import 'package:valora_code/domain/models/expense/gateway/expense_gateway.dart';
import 'package:valora_code/domain/usecase/expense/get_all_expenses_use_case.dart';
import 'package:valora_code/domain/usecase/expense/save_expense_use_case.dart';
import 'package:valora_code/domain/usecase/expense/delete_expense_use_case.dart';

class MockExpenseGateway extends Mock implements ExpenseGateway {}

final _sampleExpense = Expense(
  id: 'exp-abc',
  description: 'Adobe Suite',
  amount: 600.0,
  category: ExpenseCategory.software,
  date: DateTime(2025, 3, 5),
);

void main() {
  late MockExpenseGateway mockGateway;

  setUpAll(() {
    registerFallbackValue(_sampleExpense);
  });

  setUp(() {
    mockGateway = MockExpenseGateway();
  });

  group('GetAllExpensesUseCase.execute', () {
    test('should return list of expenses from gateway', () async {
      // Arrange
      when(
        () => mockGateway.getAll(),
      ).thenAnswer((_) async => [_sampleExpense]);
      final useCase = GetAllExpensesUseCase(gateway: mockGateway);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, hasLength(1));
      expect(result.first.id, equals('exp-abc'));
      verify(() => mockGateway.getAll()).called(1);
    });

    test('should return empty list when gateway returns nothing', () async {
      // Arrange
      when(() => mockGateway.getAll()).thenAnswer((_) async => []);
      final useCase = GetAllExpensesUseCase(gateway: mockGateway);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isEmpty);
    });
  });

  group('SaveExpenseUseCase.execute', () {
    test('should call gateway.save with the given expense', () async {
      // Arrange
      when(() => mockGateway.save(any())).thenAnswer((_) async {});
      final useCase = SaveExpenseUseCase(gateway: mockGateway);

      // Act
      await useCase.execute(_sampleExpense);

      // Assert
      verify(() => mockGateway.save(_sampleExpense)).called(1);
    });

    test('should propagate exception from gateway', () async {
      // Arrange
      when(() => mockGateway.save(any())).thenThrow(Exception('DB error'));
      final useCase = SaveExpenseUseCase(gateway: mockGateway);

      // Act & Assert
      await expectLater(
        () => useCase.execute(_sampleExpense),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('DeleteExpenseUseCase.execute', () {
    test('should call gateway.delete with the given id', () async {
      // Arrange
      when(() => mockGateway.delete(any())).thenAnswer((_) async {});
      final useCase = DeleteExpenseUseCase(gateway: mockGateway);

      // Act
      await useCase.execute('exp-abc');

      // Assert
      verify(() => mockGateway.delete('exp-abc')).called(1);
    });
  });
}
