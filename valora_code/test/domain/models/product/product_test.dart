import 'package:flutter_test/flutter_test.dart';
import 'package:valora_code/domain/models/product/product.dart';

void main() {
  group('Product', () {
    test('should create a Product with productionCost and salePrice', () {
      // Arrange
      const double productionCost = 50.0;
      const double salePrice = 100.0;

      // Act
      const product = Product(
        productionCost: productionCost,
        salePrice: salePrice,
      );

      // Assert
      expect(product.productionCost, equals(50.0));
      expect(product.salePrice, equals(100.0));
    });

    test('should allow productionCost equal to salePrice', () {
      // Arrange & Act
      const product = Product(productionCost: 100.0, salePrice: 100.0);

      // Assert
      expect(product.productionCost, equals(product.salePrice));
    });

    test('should allow zero values', () {
      // Arrange & Act
      const product = Product(productionCost: 0.0, salePrice: 0.0);

      // Assert
      expect(product.productionCost, equals(0.0));
      expect(product.salePrice, equals(0.0));
    });
  });
}
