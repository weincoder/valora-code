import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/config/providers/expense_provider.dart';
import 'package:valora_code/config/providers/product_item_provider.dart';
import 'package:valora_code/config/providers/sale_record_provider.dart';
import 'package:valora_code/domain/models/expense/gateway/expense_gateway.dart';
import 'package:valora_code/domain/models/product_item/gateway/product_item_gateway.dart';
import 'package:valora_code/domain/models/product/gateway/product_gateway.dart';
import 'package:valora_code/domain/models/product/product.dart';
import 'package:valora_code/domain/models/sale_record/gateway/sale_record_gateway.dart';
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
import 'package:valora_code/ui/pages/home/home_page.dart';

class _MockItemGateway extends Mock implements ProductItemGateway {}

class _MockMarginGateway extends Mock implements ProductGateway {}

class _MockSaleGateway extends Mock implements SaleRecordGateway {}

class _MockExpenseGateway extends Mock implements ExpenseGateway {}

void main() {
  setUpAll(() {
    registerFallbackValue(const Product(productionCost: 0, salePrice: 0));
  });

  testWidgets('HomePage renders app bar with title', (
    WidgetTester tester,
  ) async {
    // Arrange
    final mockItemGateway = _MockItemGateway();
    final mockMarginGateway = _MockMarginGateway();
    final mockSaleGateway = _MockSaleGateway();
    final mockExpenseGateway = _MockExpenseGateway();

    when(() => mockItemGateway.getAll()).thenAnswer((_) async => []);
    when(() => mockSaleGateway.getAll()).thenAnswer((_) async => []);
    when(() => mockExpenseGateway.getAll()).thenAnswer((_) async => []);

    final container = ProviderContainer(
      overrides: [
        productItemProvider.overrideWith(
          (_) => ProductItemNotifier(
            getAll: GetAllProductItemsUseCase(gateway: mockItemGateway),
            save: SaveProductItemUseCase(gateway: mockItemGateway),
            delete: DeleteProductItemUseCase(gateway: mockItemGateway),
            calcPrice: CalculateProductPriceUseCase(),
            calcMargin: CalculateProfitMarginUseCase(
              gateway: mockMarginGateway,
            ),
          ),
        ),
        saleRecordProvider.overrideWith(
          (_) => SaleRecordNotifier(
            getAll: GetAllSaleRecordsUseCase(gateway: mockSaleGateway),
            save: SaveSaleRecordUseCase(gateway: mockSaleGateway),
            delete: DeleteSaleRecordUseCase(gateway: mockSaleGateway),
          ),
        ),
        expenseProvider.overrideWith(
          (_) => ExpenseNotifier(
            getAll: GetAllExpensesUseCase(gateway: mockExpenseGateway),
            save: SaveExpenseUseCase(gateway: mockExpenseGateway),
            delete: DeleteExpenseUseCase(gateway: mockExpenseGateway),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Act
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pump();

    // Assert
    expect(find.text('ValoraCode'), findsOneWidget);
  });
}
