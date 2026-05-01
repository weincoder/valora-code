import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/domain/models/additional_cost/additional_cost.dart';
import 'package:valora_code/domain/models/product_item/product_item.dart';
import 'package:valora_code/domain/models/product_item/gateway/product_item_gateway.dart';
import 'package:valora_code/domain/usecase/product_item/get_all_product_items_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/save_product_item_use_case.dart';
import 'package:valora_code/domain/usecase/product_item/delete_product_item_use_case.dart';

class MockProductItemGateway extends Mock implements ProductItemGateway {}

final _sampleProduct = ProductItem(
  id: 'abc-123',
  title: 'App móvil',
  description: 'Desarrollo de app',
  hourlyRate: 50.0,
  estimatedHours: 10.0,
  additionalCosts: const [AdditionalCost(label: 'Hosting', amount: 30.0)],
  salePrice: 600.0,
  profitMargin: 20.0,
  createdAt: DateTime(2025, 1, 1),
);

void main() {
  late MockProductItemGateway mockGateway;

  setUpAll(() {
    registerFallbackValue(_sampleProduct);
  });

  setUp(() {
    mockGateway = MockProductItemGateway();
  });

  group('GetAllProductItemsUseCase.execute', () {
    test('should return list of products from gateway', () async {
      // Arrange
      when(
        () => mockGateway.getAll(),
      ).thenAnswer((_) async => [_sampleProduct]);
      final useCase = GetAllProductItemsUseCase(gateway: mockGateway);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, hasLength(1));
      expect(result.first.id, equals('abc-123'));
      verify(() => mockGateway.getAll()).called(1);
    });

    test('should return empty list when gateway returns no products', () async {
      // Arrange
      when(() => mockGateway.getAll()).thenAnswer((_) async => []);
      final useCase = GetAllProductItemsUseCase(gateway: mockGateway);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isEmpty);
    });
  });

  group('SaveProductItemUseCase.execute', () {
    test('should call gateway.save with the given product', () async {
      // Arrange
      when(() => mockGateway.save(any())).thenAnswer((_) async {});
      final useCase = SaveProductItemUseCase(gateway: mockGateway);

      // Act
      await useCase.execute(_sampleProduct);

      // Assert
      verify(() => mockGateway.save(_sampleProduct)).called(1);
    });

    test('should propagate exception from gateway', () async {
      // Arrange
      when(() => mockGateway.save(any())).thenThrow(Exception('DB error'));
      final useCase = SaveProductItemUseCase(gateway: mockGateway);

      // Act & Assert
      await expectLater(
        () => useCase.execute(_sampleProduct),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('DeleteProductItemUseCase.execute', () {
    test('should call gateway.delete with the given id', () async {
      // Arrange
      when(() => mockGateway.delete(any())).thenAnswer((_) async {});
      final useCase = DeleteProductItemUseCase(gateway: mockGateway);

      // Act
      await useCase.execute('abc-123');

      // Assert
      verify(() => mockGateway.delete('abc-123')).called(1);
    });

    test('should propagate exception from gateway when delete fails', () async {
      // Arrange
      when(() => mockGateway.delete(any())).thenThrow(Exception('Not found'));
      final useCase = DeleteProductItemUseCase(gateway: mockGateway);

      // Act & Assert
      await expectLater(
        () => useCase.execute('abc-123'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
