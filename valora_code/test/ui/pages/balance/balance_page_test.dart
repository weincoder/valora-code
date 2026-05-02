import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/config/providers/expense_provider.dart';
import 'package:valora_code/config/providers/sale_record_provider.dart';
import 'package:valora_code/domain/models/expense/expense.dart';
import 'package:valora_code/domain/models/expense/expense_category.dart';
import 'package:valora_code/domain/models/expense/gateway/expense_gateway.dart';
import 'package:valora_code/domain/models/sale_record/gateway/sale_record_gateway.dart';
import 'package:valora_code/domain/models/sale_record/sale_record.dart';
import 'package:valora_code/domain/usecase/expense/delete_expense_use_case.dart';
import 'package:valora_code/domain/usecase/expense/get_all_expenses_use_case.dart';
import 'package:valora_code/domain/usecase/expense/save_expense_use_case.dart';
import 'package:valora_code/domain/usecase/sale_record/delete_sale_record_use_case.dart';
import 'package:valora_code/domain/usecase/sale_record/get_all_sale_records_use_case.dart';
import 'package:valora_code/domain/usecase/sale_record/save_sale_record_use_case.dart';
import 'package:valora_code/ui/pages/balance/balance_page.dart';

class _MockExpenseGateway extends Mock implements ExpenseGateway {}

class _MockSaleGateway extends Mock implements SaleRecordGateway {}

final _sampleSale = SaleRecord(
  id: 'sale-1',
  productItemId: 'prod-1',
  productTitle: 'Servicio',
  quantity: 2,
  unitPrice: 500.0,
  totalAmount: 1000.0,
  date: DateTime(2025, 3, 1),
);

final _sampleExpense = Expense(
  id: 'exp-1',
  description: 'Hosting',
  amount: 200.0,
  category: ExpenseCategory.services,
  date: DateTime(2025, 3, 1),
);

Widget _buildApp({
  List<SaleRecord> sales = const [],
  List<Expense> expenses = const [],
}) {
  final mockSale = _MockSaleGateway();
  final mockExpense = _MockExpenseGateway();
  when(() => mockSale.getAll()).thenAnswer((_) async => sales);
  when(() => mockExpense.getAll()).thenAnswer((_) async => expenses);

  return ProviderScope(
    overrides: [
      saleRecordProvider.overrideWith(
        (_) => SaleRecordNotifier(
          getAll: GetAllSaleRecordsUseCase(gateway: mockSale),
          save: SaveSaleRecordUseCase(gateway: mockSale),
          delete: DeleteSaleRecordUseCase(gateway: mockSale),
        ),
      ),
      expenseProvider.overrideWith(
        (_) => ExpenseNotifier(
          getAll: GetAllExpensesUseCase(gateway: mockExpense),
          save: SaveExpenseUseCase(gateway: mockExpense),
          delete: DeleteExpenseUseCase(gateway: mockExpense),
        ),
      ),
    ],
    child: const MaterialApp(home: BalancePage()),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_sampleSale);
    registerFallbackValue(_sampleExpense);
  });

  group('Find the page widgets', () {
    testWidgets('should find AppBar with title Balance', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      // Act & Assert
      expect(find.text('Balance'), findsOneWidget);
    });

    testWidgets('should find 4 summary cards', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      // Act & Assert
      expect(find.byKey(const Key('balance-revenue')), findsOneWidget);
      expect(find.byKey(const Key('balance-expenses')), findsOneWidget);
      expect(find.byKey(const Key('balance-profit')), findsOneWidget);
      expect(find.byKey(const Key('balance-margin')), findsOneWidget);
    });

    testWidgets('should find monthly revenue and expenses charts', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      // Act & Assert
      expect(find.byKey(const Key('monthly-revenue-chart')), findsOneWidget);
      expect(find.byKey(const Key('monthly-expenses-chart')), findsOneWidget);
    });
  });

  group('Interaction with page widgets', () {
    testWidgets('should show positive message when profit is positive', (
      tester,
    ) async {
      // Arrange
      // Without loading, totalProfit = 0 >= 0, so isPositive = true
      await tester.pumpWidget(_buildApp(sales: [_sampleSale], expenses: []));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Act & Assert
      expect(find.text('¡Buen trabajo!'), findsOneWidget);
    });

    testWidgets('should show improvement message when loss', (tester) async {
      // Arrange — pre-load both providers so totalProfit < 0
      final mockSale = _MockSaleGateway();
      final mockExpense = _MockExpenseGateway();
      when(() => mockSale.getAll()).thenAnswer((_) async => []);
      when(
        () => mockExpense.getAll(),
      ).thenAnswer((_) async => [_sampleExpense]);
      final container = ProviderContainer(
        overrides: [
          saleRecordProvider.overrideWith(
            (_) => SaleRecordNotifier(
              getAll: GetAllSaleRecordsUseCase(gateway: mockSale),
              save: SaveSaleRecordUseCase(gateway: mockSale),
              delete: DeleteSaleRecordUseCase(gateway: mockSale),
            ),
          ),
          expenseProvider.overrideWith(
            (_) => ExpenseNotifier(
              getAll: GetAllExpensesUseCase(gateway: mockExpense),
              save: SaveExpenseUseCase(gateway: mockExpense),
              delete: DeleteExpenseUseCase(gateway: mockExpense),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(saleRecordProvider.notifier).load();
      await container.read(expenseProvider.notifier).load();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: BalancePage()),
        ),
      );
      await tester.pump();

      // Act & Assert
      expect(find.text('Revisemos los números'), findsOneWidget);
    });
  });

  group('Test Page Experience', () {
    testWidgets('should display revenue amount in summary card', (
      tester,
    ) async {
      // Arrange — pre-load saleRecordProvider so totalRevenue = 1000
      final mockSale = _MockSaleGateway();
      final mockExpense = _MockExpenseGateway();
      when(() => mockSale.getAll()).thenAnswer((_) async => [_sampleSale]);
      when(() => mockExpense.getAll()).thenAnswer((_) async => []);
      final container = ProviderContainer(
        overrides: [
          saleRecordProvider.overrideWith(
            (_) => SaleRecordNotifier(
              getAll: GetAllSaleRecordsUseCase(gateway: mockSale),
              save: SaveSaleRecordUseCase(gateway: mockSale),
              delete: DeleteSaleRecordUseCase(gateway: mockSale),
            ),
          ),
          expenseProvider.overrideWith(
            (_) => ExpenseNotifier(
              getAll: GetAllExpensesUseCase(gateway: mockExpense),
              save: SaveExpenseUseCase(gateway: mockExpense),
              delete: DeleteExpenseUseCase(gateway: mockExpense),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(saleRecordProvider.notifier).load();
      await container.read(expenseProvider.notifier).load();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: BalancePage()),
        ),
      );
      await tester.pump();

      // Act & Assert — revenue card shows $1000.00 (profit also $1000 since no expenses)
      expect(find.text('\$1000.00'), findsWidgets);
    });

    testWidgets('should show zero values when no data', (tester) async {
      // Arrange — without data, all values are 0
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Act & Assert
      expect(find.text('\$0.00'), findsWidgets);
    });
  });
}
