import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
import 'package:valora_code/ui/pages/movements/movements_page.dart';

class _MockSaleGateway extends Mock implements SaleRecordGateway {}

class _MockExpenseGateway extends Mock implements ExpenseGateway {}

final _sampleRecord = SaleRecord(
  id: 'sale-mov-1',
  productItemId: 'prod-1',
  productTitle: 'Desarrollo web',
  quantity: 2,
  unitPrice: 500.0,
  totalAmount: 1000.0,
  date: DateTime(2025, 5, 1),
);

final _sampleExpense = Expense(
  id: 'exp-mov-1',
  description: 'Adobe CC',
  amount: 60.0,
  category: ExpenseCategory.software,
  date: DateTime(2025, 5, 1),
);

Widget _buildApp({
  List<SaleRecord> records = const [],
  List<Expense> expenses = const [],
}) {
  final mockSale = _MockSaleGateway();
  final mockExpense = _MockExpenseGateway();

  when(() => mockSale.getAll()).thenAnswer((_) async => records);
  when(() => mockSale.save(any())).thenAnswer((_) async {});
  when(() => mockSale.delete(any())).thenAnswer((_) async {});
  when(() => mockExpense.getAll()).thenAnswer((_) async => expenses);
  when(() => mockExpense.save(any())).thenAnswer((_) async {});
  when(() => mockExpense.delete(any())).thenAnswer((_) async {});

  final router = GoRouter(
    initialLocation: '/movements',
    routes: [
      GoRoute(path: '/movements', builder: (_, _) => const MovementsPage()),
      GoRoute(path: '/sale/:id', builder: (_, _) => const Scaffold()),
    ],
  );

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
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_sampleRecord);
    registerFallbackValue(_sampleExpense);
  });

  group('MovementsPage', () {
    testWidgets('renders AppBar with title', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Movimientos'), findsOneWidget);
    });

    testWidgets('shows income and expense toggle buttons', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Ingresos'), findsOneWidget);
      expect(find.text('Gastos'), findsOneWidget);
    });

    testWidgets('shows empty income state by default', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('sales-empty-text')), findsOneWidget);
    });

    testWidgets('shows owl header for income type', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Revisando tus ingresos...'), findsOneWidget);
    });

    testWidgets('tapping Gastos tab switches to expense view', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Gastos'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Calculando tus gastos...'), findsOneWidget);
      expect(find.byKey(const Key('expenses-empty-text')), findsOneWidget);
    });

    testWidgets('shows sale records list when data is loaded', (tester) async {
      await tester.pumpWidget(_buildApp(records: [_sampleRecord]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('sales-list')), findsOneWidget);
      expect(find.text('Desarrollo web'), findsOneWidget);
    });

    testWidgets('shows expense list when switching to expenses tab with data', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(expenses: [_sampleExpense]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Gastos'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('expenses-list')), findsOneWidget);
      expect(find.text('Adobe CC'), findsOneWidget);
    });

    testWidgets('shows delete confirmation dialog for sale', (tester) async {
      await tester.pumpWidget(_buildApp(records: [_sampleRecord]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();

      expect(find.text('Eliminar venta'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('cancelling delete dialog keeps record', (tester) async {
      await tester.pumpWidget(_buildApp(records: [_sampleRecord]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();

      await tester.tap(find.text('Cancelar'));
      await tester.pump();

      expect(find.text('Desarrollo web'), findsOneWidget);
    });

    testWidgets('shows delete dialog for expense', (tester) async {
      await tester.pumpWidget(_buildApp(expenses: [_sampleExpense]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Gastos'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();

      expect(find.text('Eliminar gasto'), findsOneWidget);
    });
  });
}
