import 'package:flutter_test/flutter_test.dart';
import 'package:valora_code/domain/models/product/product.dart';
import 'package:valora_code/domain/models/product/product_exception.dart';
import 'package:valora_code/infrastructure/driven_adapters/product/product_adapter.dart';

void main() {
  late ProductAdapter adapter;

  setUp(() {
    adapter = ProductAdapter();
  });

  group('calculateProfitMargin', () {
    test(
      'should return 50% margin when productionCost is half of salePrice',
      () {
        // Arrange
        const product = Product(productionCost: 50.0, salePrice: 100.0);

        // Act
        final result = adapter.calculateProfitMargin(product);

        // Assert
        expect(result, equals(50.0));
      },
    );

    test('should return 0% margin when productionCost equals salePrice', () {
      // Arrange
      const product = Product(productionCost: 100.0, salePrice: 100.0);

      // Act
      final result = adapter.calculateProfitMargin(product);

      // Assert
      expect(result, equals(0.0));
    });

    test('should return 100% margin when productionCost is zero', () {
      // Arrange
      const product = Product(productionCost: 0.0, salePrice: 100.0);

      // Act
      final result = adapter.calculateProfitMargin(product);

      // Assert
      expect(result, equals(100.0));
    });

    test(
      'should return negative margin when productionCost exceeds salePrice',
      () {
        // Arrange
        const product = Product(productionCost: 150.0, salePrice: 100.0);

        // Act
        final result = adapter.calculateProfitMargin(product);

        // Assert
        expect(result, equals(-50.0));
      },
    );

    test('should throw ProductException when salePrice is zero', () {
      // Arrange
      const product = Product(productionCost: 50.0, salePrice: 0.0);

      // Act
      void call() => adapter.calculateProfitMargin(product);

      // Assert
      expect(call, throwsA(isA<ProductException>()));
    });
  });
}
