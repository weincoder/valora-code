import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/config/providers/product_item_provider.dart';
import 'package:valora_code/config/providers/sale_record_provider.dart';
import 'package:valora_code/domain/models/product/product.dart';
import 'package:valora_code/domain/models/product_item/gateway/product_item_gateway.dart';
import 'package:valora_code/domain/models/product_item/product_item.dart';
import 'package:valora_code/domain/models/sale_record/gateway/sale_record_gateway.dart';
import 'package:valora_code/domain/models/sale_record/sale_record.dart';
import 'package:valora_code/domain/usecase/calculate_profit_margin_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/calculate_product_price_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/delete_product_item_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/get_all_product_items_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/save_product_item_use_case.dart';
import 'package:valora_code/domain/usecase/sale_record/delete_sale_record_use_case.dart';
import 'package:valora_code/domain/usecase/sale_record/get_all_sale_records_use_case.dart';
import 'package:valora_code/domain/usecase/sale_record/save_sale_record_use_case.dart';
import 'package:valora_code/infrastructure/driven_adapters/product/product_adapter.dart';
import 'package:valora_code/ui/pages/sale_record/sale_record_form_page.dart';

class _MockProductItemGateway extends Mock implements ProductItemGateway {}

class _MockSaleGateway extends Mock implements SaleRecordGateway {}

final _sampleProduct = ProductItem(
  id: 'prod-1',
  title: 'Desarrollo web',
  description: 'Sitio web corporativo',
  hourlyRate: 50.0,
  estimatedHours: 10.0,
  additionalCosts: const [],
  salePrice: 600.0,
  profitMargin: 30.0,
  createdAt: DateTime(2025, 1, 1),
);

final _sampleRecord = SaleRecord(
  id: 'sale-1',
  productItemId: 'prod-1',
  productTitle: 'Desarrollo web',
  quantity: 1,
  unitPrice: 600.0,
  totalAmount: 600.0,
  date: DateTime(2025, 4, 1),
);

Widget _buildApp({
  List<ProductItem> products = const [],
  List<SaleRecord> records = const [],
}) {
  final mockItem = _MockProductItemGateway();
  final mockSale = _MockSaleGateway();
  when(() => mockItem.getAll()).thenAnswer((_) async => products);
  when(() => mockSale.getAll()).thenAnswer((_) async => records);
  when(() => mockSale.save(any())).thenAnswer((_) async {});
  when(() => mockSale.delete(any())).thenAnswer((_) async {});

  return ProviderScope(
    overrides: [
      productItemProvider.overrideWith(
        (_) => ProductItemNotifier(
          getAll: GetAllProductItemsUseCase(gateway: mockItem),
          save: SaveProductItemUseCase(gateway: mockItem),
          delete: DeleteProductItemUseCase(gateway: mockItem),
          calcPrice: CalculateProductPriceUseCase(),
          calcMargin: CalculateProfitMarginUseCase(gateway: ProductAdapter()),
        ),
      ),
      saleRecordProvider.overrideWith(
        (_) => SaleRecordNotifier(
          getAll: GetAllSaleRecordsUseCase(gateway: mockSale),
          save: SaveSaleRecordUseCase(gateway: mockSale),
          delete: DeleteSaleRecordUseCase(gateway: mockSale),
        ),
      ),
    ],
    child: const MaterialApp(home: SaleRecordFormPage()),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_sampleProduct);
    registerFallbackValue(_sampleRecord);
    registerFallbackValue(const Product(productionCost: 0, salePrice: 0));
  });

  group('Find the page widgets', () {
    testWidgets('should find AppBar with Registrar venta title', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.text('Registrar venta'), findsAtLeastNWidgets(1));
    });

    testWidgets('should find product dropdown', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('sale-product-dropdown')), findsOneWidget);
    });

    testWidgets('should find quantity and unit price fields', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('sale-quantity')), findsOneWidget);
      expect(find.byKey(const Key('sale-unit-price')), findsOneWidget);
    });

    testWidgets('should find save button', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('sale-save-btn')), findsOneWidget);
    });
  });

  group('Interaction with page widgets', () {
    testWidgets('should show validation error when no product selected', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act
      await tester.tap(find.byKey(const Key('sale-save-btn')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Selecciona un producto'), findsOneWidget);
    });

    testWidgets('should show quantity validation error', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());
      await tester.enterText(find.byKey(const Key('sale-quantity')), '0');

      // Act
      await tester.tap(find.byKey(const Key('sale-save-btn')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ingresa una cantidad válida'), findsOneWidget);
    });
  });

  group('Test Page Experience', () {
    testWidgets('should show date tile', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('sale-date')), findsOneWidget);
    });

    testWidgets('should show notes field', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('sale-notes')), findsOneWidget);
    });
  });
}
