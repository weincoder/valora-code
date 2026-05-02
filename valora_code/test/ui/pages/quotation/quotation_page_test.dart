import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/config/providers/product_item_provider.dart';
import 'package:valora_code/domain/models/product/product.dart';
import 'package:valora_code/domain/models/product_item/gateway/product_item_gateway.dart';
import 'package:valora_code/domain/models/product_item/product_item.dart';
import 'package:valora_code/domain/usecase/calculate_profit_margin_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/calculate_product_price_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/delete_product_item_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/get_all_product_items_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/save_product_item_use_case.dart';
import 'package:valora_code/infrastructure/driven_adapters/product/product_adapter.dart';
import 'package:valora_code/ui/pages/quotation/quotation_page.dart';

class _MockProductItemGateway extends Mock implements ProductItemGateway {}

final _sampleProduct = ProductItem(
  id: 'prod-1',
  title: 'Diseño de logo',
  description: 'Identidad corporativa completa',
  hourlyRate: 45.0,
  estimatedHours: 8.0,
  additionalCosts: const [],
  salePrice: 500.0,
  profitMargin: 40.0,
  createdAt: DateTime(2025, 2, 1),
);

Widget _buildApp({List<ProductItem> items = const []}) {
  final mock = _MockProductItemGateway();
  when(() => mock.getAll()).thenAnswer((_) async => items);
  when(() => mock.save(any())).thenAnswer((_) async {});
  when(() => mock.delete(any())).thenAnswer((_) async {});

  return ProviderScope(
    overrides: [
      productItemProvider.overrideWith(
        (_) => ProductItemNotifier(
          getAll: GetAllProductItemsUseCase(gateway: mock),
          save: SaveProductItemUseCase(gateway: mock),
          delete: DeleteProductItemUseCase(gateway: mock),
          calcPrice: CalculateProductPriceUseCase(),
          calcMargin: CalculateProfitMarginUseCase(gateway: ProductAdapter()),
        ),
      ),
    ],
    child: const MaterialApp(home: QuotationPage()),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_sampleProduct);
    registerFallbackValue(const Product(productionCost: 0, salePrice: 0));
  });

  group('Find the page widgets', () {
    testWidgets('should find AppBar with Generar Cotización title', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.text('Generar Cotización'), findsOneWidget);
    });

    testWidgets('should find company name field', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('company-name-field')), findsOneWidget);
    });

    testWidgets('should find logo picker button', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('pick-logo-button')), findsOneWidget);
      expect(find.text('Agregar logo'), findsOneWidget);
    });

    testWidgets('should find generate PDF button', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('generate-pdf-button')), findsOneWidget);
      expect(find.text('Generar PDF'), findsOneWidget);
    });

    testWidgets('should find products list', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('quotation-products-list')), findsOneWidget);
    });
  });

  group('Interaction with page widgets', () {
    testWidgets('should accept company name input', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act
      await tester.enterText(
        find.byKey(const Key('company-name-field')),
        'Empresa ABC',
      );
      await tester.pump();

      // Assert
      expect(find.text('Empresa ABC'), findsOneWidget);
    });

    testWidgets('should show product checkbox when items loaded', (
      tester,
    ) async {
      // Arrange — use ProviderContainer to pre-load state before pump
      final mock = _MockProductItemGateway();
      when(() => mock.getAll()).thenAnswer((_) async => [_sampleProduct]);
      when(() => mock.save(any())).thenAnswer((_) async {});
      when(() => mock.delete(any())).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          productItemProvider.overrideWith(
            (_) => ProductItemNotifier(
              getAll: GetAllProductItemsUseCase(gateway: mock),
              save: SaveProductItemUseCase(gateway: mock),
              delete: DeleteProductItemUseCase(gateway: mock),
              calcPrice: CalculateProductPriceUseCase(),
              calcMargin: CalculateProfitMarginUseCase(
                gateway: ProductAdapter(),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(productItemProvider.notifier).load();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: QuotationPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byKey(const Key('quotation-check-prod-1')), findsOneWidget);
      expect(find.text('Diseño de logo'), findsOneWidget);
    });

    testWidgets(
      'should show snackbar when generate pdf with no products selected',
      (tester) async {
        // Arrange
        await tester.pumpWidget(_buildApp());
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byKey(const Key('generate-pdf-button')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Selecciona al menos un producto'), findsOneWidget);
      },
    );
  });

  group('Test Page Experience', () {
    testWidgets('should show selection hint text', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(
        find.text('Selecciona los productos para la cotización:'),
        findsOneWidget,
      );
    });
  });
}
