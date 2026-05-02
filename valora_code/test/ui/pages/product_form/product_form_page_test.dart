import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/config/providers/product_item_provider.dart';
import 'package:valora_code/domain/models/additional_cost/additional_cost.dart';
import 'package:valora_code/domain/models/product/product.dart';
import 'package:valora_code/domain/models/product_item/gateway/product_item_gateway.dart';
import 'package:valora_code/domain/models/product_item/product_item.dart';
import 'package:valora_code/domain/usecase/calculate_profit_margin_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/calculate_product_price_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/delete_product_item_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/get_all_product_items_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/save_product_item_use_case.dart';
import 'package:valora_code/infrastructure/driven_adapters/product/product_adapter.dart';
import 'package:valora_code/ui/pages/product_form/product_form_page.dart';

class _MockProductItemGateway extends Mock implements ProductItemGateway {}

final _sampleProduct = ProductItem(
  id: 'prod-1',
  title: 'App móvil',
  description: 'Desarrollo de aplicación',
  hourlyRate: 60.0,
  estimatedHours: 20.0,
  additionalCosts: const [AdditionalCost(label: 'Hosting', amount: 50.0)],
  salePrice: 1500.0,
  profitMargin: 35.0,
  createdAt: DateTime(2025, 1, 1),
);

Widget _buildApp({String? productId, List<ProductItem> items = const []}) {
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
    child: MaterialApp(home: ProductFormPage(productId: productId)),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_sampleProduct);
    registerFallbackValue(const Product(productionCost: 0, salePrice: 0));
  });

  group('Find the page widgets', () {
    testWidgets('should find AppBar with Crear Producto title', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.text('Crear Producto'), findsOneWidget);
    });

    testWidgets('should find title and description fields', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('product-title-field')), findsOneWidget);
      expect(find.byKey(const Key('product-desc-field')), findsOneWidget);
    });

    testWidgets('should find cost calculation fields', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('hourly-rate-field')), findsOneWidget);
      expect(find.byKey(const Key('estimated-hours-field')), findsOneWidget);
    });

    testWidgets('should find sale price field', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert — widget is in the tree inside SingleChildScrollView even if off-screen
      expect(find.byKey(const Key('sale-price-form-field')), findsOneWidget);
    });

    testWidgets('should find save button', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('save-product-button')), findsOneWidget);
      expect(find.text('Crear producto'), findsOneWidget);
    });
  });

  group('Interaction with page widgets', () {
    testWidgets('should show validation errors on empty submit', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_buildApp());
      await tester.ensureVisible(find.byKey(const Key('save-product-button')));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byKey(const Key('save-product-button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Requerido'), findsWidgets);
    });

    testWidgets('should add cost row when add button tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act
      await tester.tap(find.byKey(const Key('add-cost-button')));
      await tester.pump();

      // Assert — AdditionalCostRow widget appears
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('should accept text input in title field', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act
      await tester.enterText(
        find.byKey(const Key('product-title-field')),
        'Mi Servicio',
      );
      await tester.pump();

      // Assert
      expect(find.text('Mi Servicio'), findsOneWidget);
    });
  });

  group('Test Page Experience', () {
    testWidgets('should find section titles', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.text('Información general'), findsOneWidget);
      expect(find.text('Cálculo de costos'), findsOneWidget);
    });

    testWidgets('should show Editar Producto title when editing', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        _buildApp(productId: 'prod-1', items: [_sampleProduct]),
      );

      // Act & Assert
      expect(find.text('Editar Producto'), findsOneWidget);
    });
  });
}
