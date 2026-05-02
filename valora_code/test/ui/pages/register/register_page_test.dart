import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:valora_code/config/providers/expense_provider.dart';
import 'package:valora_code/config/providers/product_item_provider.dart';
import 'package:valora_code/config/providers/sale_record_provider.dart';
import 'package:valora_code/domain/models/additional_cost/additional_cost.dart';
import 'package:valora_code/domain/models/expense/expense.dart';
import 'package:valora_code/domain/models/expense/expense_category.dart';
import 'package:valora_code/domain/models/expense/gateway/expense_gateway.dart';
import 'package:valora_code/domain/models/product/gateway/product_gateway.dart';
import 'package:valora_code/domain/models/product/product.dart';
import 'package:valora_code/domain/models/product_item/gateway/product_item_gateway.dart';
import 'package:valora_code/domain/models/product_item/product_item.dart';
import 'package:valora_code/domain/models/sale_record/gateway/sale_record_gateway.dart';
import 'package:valora_code/domain/models/sale_record/sale_record.dart';
import 'package:valora_code/domain/usecase/calculate_profit_margin_use_case.dart';
import 'package:valora_code/domain/usecase/expense/delete_expense_use_case.dart';
import 'package:valora_code/domain/usecase/expense/get_all_expenses_use_case.dart';
import 'package:valora_code/domain/usecase/expense/save_expense_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/calculate_product_price_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/delete_product_item_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/get_all_product_items_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/save_product_item_use_case.dart';
import 'package:valora_code/domain/usecase/sale_record/delete_sale_record_use_case.dart';
import 'package:valora_code/domain/usecase/sale_record/get_all_sale_records_use_case.dart';
import 'package:valora_code/domain/usecase/sale_record/save_sale_record_use_case.dart';
import 'package:valora_code/ui/pages/register/register_page.dart';

class _MockProductItemGateway extends Mock implements ProductItemGateway {}

class _MockProductGateway extends Mock implements ProductGateway {}

class _MockSaleGateway extends Mock implements SaleRecordGateway {}

class _MockExpenseGateway extends Mock implements ExpenseGateway {}

final _sampleItem = ProductItem(
  id: 'item-1',
  title: 'Desarrollo web',
  description: 'Sitio web',
  hourlyRate: 50.0,
  estimatedHours: 10.0,
  additionalCosts: const [AdditionalCost(label: 'Hosting', amount: 20)],
  salePrice: 600.0,
  profitMargin: 30.0,
  createdAt: DateTime(2025, 1, 1),
);

final _sampleRecord = SaleRecord(
  id: 'sale-reg-1',
  productItemId: 'item-1',
  productTitle: 'Desarrollo web',
  quantity: 1,
  unitPrice: 600.0,
  totalAmount: 600.0,
  date: DateTime(2025, 5, 1),
);

final _sampleExpense = Expense(
  id: 'exp-reg-1',
  description: 'Adobe CC',
  amount: 50.0,
  category: ExpenseCategory.software,
  date: DateTime(2025, 5, 1),
);

Widget _buildApp({
  List<ProductItem> items = const [],
  List<SaleRecord> records = const [],
  List<Expense> expenses = const [],
}) {
  final mockItems = _MockProductItemGateway();
  final mockMargin = _MockProductGateway();
  final mockSale = _MockSaleGateway();
  final mockExpense = _MockExpenseGateway();

  when(() => mockItems.getAll()).thenAnswer((_) async => items);
  when(() => mockItems.save(any())).thenAnswer((_) async {});
  when(() => mockItems.delete(any())).thenAnswer((_) async {});
  when(() => mockMargin.calculateProfitMargin(any())).thenReturn(30);
  when(() => mockSale.getAll()).thenAnswer((_) async => records);
  when(() => mockSale.save(any())).thenAnswer((_) async {});
  when(() => mockSale.delete(any())).thenAnswer((_) async {});
  when(() => mockExpense.getAll()).thenAnswer((_) async => expenses);
  when(() => mockExpense.save(any())).thenAnswer((_) async {});
  when(() => mockExpense.delete(any())).thenAnswer((_) async {});

  final router = GoRouter(
    initialLocation: '/register',
    routes: [
      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
    ],
  );

  return ProviderScope(
    overrides: [
      productItemProvider.overrideWith(
        (_) => ProductItemNotifier(
          getAll: GetAllProductItemsUseCase(gateway: mockItems),
          save: SaveProductItemUseCase(gateway: mockItems),
          delete: DeleteProductItemUseCase(gateway: mockItems),
          calcPrice: CalculateProductPriceUseCase(),
          calcMargin: CalculateProfitMarginUseCase(gateway: mockMargin),
        ),
      ),
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
    registerFallbackValue(_sampleItem);
    registerFallbackValue(const Product(productionCost: 0, salePrice: 0));
    registerFallbackValue(_sampleRecord);
    registerFallbackValue(_sampleExpense);
  });

  group('RegisterPage', () {
    testWidgets('renders AppBar with title', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Nuevo registro'), findsOneWidget);
    });

    testWidgets('shows type toggle with sale and expense options', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Ingreso / Venta'), findsOneWidget);
      expect(find.text('Gasto'), findsOneWidget);
    });

    testWidgets('shows sale form fields by default', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('sale-quantity')), findsOneWidget);
      expect(find.byKey(const Key('sale-unit-price')), findsOneWidget);
    });

    testWidgets('shows sale form with product dropdown', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('sale-product-dropdown')), findsOneWidget);
    });

    testWidgets('switching to expense tab shows expense form', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Gasto'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('expense-description')), findsOneWidget);
      expect(find.byKey(const Key('expense-amount')), findsOneWidget);
    });

    testWidgets('expense form shows category dropdown', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Gasto'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('expense-category')), findsOneWidget);
    });

    testWidgets('shows Registrar venta button in sale form', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Registrar venta'), findsOneWidget);
    });

    testWidgets('shows Registrar gasto button in expense form', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Gasto'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Registrar gasto'), findsOneWidget);
    });

    testWidgets('sale form shows product item in dropdown when loaded', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(items: [_sampleItem]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Open the dropdown to see the menu items
      await tester.tap(find.byKey(const Key('sale-product-dropdown')));
      await tester.pump();

      expect(find.text('Desarrollo web'), findsAtLeastNWidgets(1));
    });

    testWidgets('sale form validates empty fields on submit', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.ensureVisible(find.text('Registrar venta'));
      await tester.tap(find.text('Registrar venta'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Selecciona un producto'), findsAtLeastNWidgets(1));
    });

    testWidgets('expense form validates empty fields on submit', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Gasto'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.ensureVisible(find.text('Registrar gasto'));
      await tester.tap(find.text('Registrar gasto'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Ingresa descripción'), findsAtLeastNWidgets(1));
    });
  });
}
