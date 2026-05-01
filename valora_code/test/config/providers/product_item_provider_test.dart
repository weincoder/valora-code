import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/config/providers/product_item_provider.dart';
import 'package:valora_code/domain/models/additional_cost/additional_cost.dart';
import 'package:valora_code/domain/models/product_item/product_item.dart';
import 'package:valora_code/domain/models/product_item/gateway/product_item_gateway.dart';
import 'package:valora_code/domain/usecase/product_item/get_all_product_items_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/save_product_item_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/delete_product_item_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/calculate_product_price_use_case.dart';
import 'package:valora_code/domain/models/product/product.dart';
import 'package:valora_code/domain/models/product/gateway/product_gateway.dart';
import 'package:valora_code/domain/usecase/calculate_profit_margin_use_case.dart';

class MockProductItemGateway extends Mock implements ProductItemGateway {}

class MockProductGateway extends Mock implements ProductGateway {}

final _sampleItem = ProductItem(
  id: 'test-1',
  title: 'App',
  description: 'Descripción',
  hourlyRate: 50,
  estimatedHours: 8,
  additionalCosts: const [AdditionalCost(label: 'Hosting', amount: 30)],
  salePrice: 600,
  profitMargin: 25,
  createdAt: DateTime(2025, 1, 1),
);

ProductItemNotifier _makeNotifier(
  MockProductItemGateway mockItemGateway,
  MockProductGateway mockMarginGateway,
) {
  return ProductItemNotifier(
    getAll: GetAllProductItemsUseCase(gateway: mockItemGateway),
    save: SaveProductItemUseCase(gateway: mockItemGateway),
    delete: DeleteProductItemUseCase(gateway: mockItemGateway),
    calcPrice: CalculateProductPriceUseCase(),
    calcMargin: CalculateProfitMarginUseCase(gateway: mockMarginGateway),
  );
}

void main() {
  late MockProductItemGateway mockItemGateway;
  late MockProductGateway mockMarginGateway;

  setUpAll(() {
    registerFallbackValue(_sampleItem);
    registerFallbackValue(const Product(productionCost: 0, salePrice: 0));
  });

  setUp(() {
    mockItemGateway = MockProductItemGateway();
    mockMarginGateway = MockProductGateway();
  });

  group('ProductItemNotifier.load', () {
    test('should emit items from gateway after load', () async {
      // Arrange
      when(
        () => mockItemGateway.getAll(),
      ).thenAnswer((_) async => [_sampleItem]);
      when(() => mockMarginGateway.calculateProfitMargin(any())).thenReturn(25);
      final container = ProviderContainer(
        overrides: [
          productItemProvider.overrideWith(
            (_) => _makeNotifier(mockItemGateway, mockMarginGateway),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Act
      await container.read(productItemProvider.notifier).load();

      // Assert
      final state = container.read(productItemProvider);
      expect(state.items, hasLength(1));
      expect(state.items.first.id, equals('test-1'));
      expect(state.isLoading, isFalse);
    });

    test('should emit error when gateway throws', () async {
      // Arrange
      when(() => mockItemGateway.getAll()).thenThrow(Exception('DB error'));
      when(() => mockMarginGateway.calculateProfitMargin(any())).thenReturn(25);
      final container = ProviderContainer(
        overrides: [
          productItemProvider.overrideWith(
            (_) => _makeNotifier(mockItemGateway, mockMarginGateway),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Act
      await container.read(productItemProvider.notifier).load();

      // Assert
      final state = container.read(productItemProvider);
      expect(state.error, isNotNull);
      expect(state.isLoading, isFalse);
    });
  });

  group('ProductItemNotifier.delete', () {
    test('should call gateway.delete and reload list', () async {
      // Arrange
      when(() => mockItemGateway.delete(any())).thenAnswer((_) async {});
      when(() => mockItemGateway.getAll()).thenAnswer((_) async => []);
      when(() => mockMarginGateway.calculateProfitMargin(any())).thenReturn(25);
      final container = ProviderContainer(
        overrides: [
          productItemProvider.overrideWith(
            (_) => _makeNotifier(mockItemGateway, mockMarginGateway),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Act
      await container.read(productItemProvider.notifier).delete('test-1');

      // Assert
      verify(() => mockItemGateway.delete('test-1')).called(1);
      expect(container.read(productItemProvider).items, isEmpty);
    });
  });
}
