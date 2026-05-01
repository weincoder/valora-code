import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/domain/models/product/product.dart';
import 'package:valora_code/domain/models/product/gateway/product_gateway.dart';
import 'package:valora_code/domain/usecase/calculate_profit_margin_use_case.dart';

class MockProductGateway extends Mock implements ProductGateway {}

void main() {
  late MockProductGateway mockGateway;
  late CalculateProfitMarginUseCase useCase;

  setUp(() {
    mockGateway = MockProductGateway();
    useCase = CalculateProfitMarginUseCase(gateway: mockGateway);
  });

  group('execute', () {
    test('should return profit margin from gateway when product is valid', () {
      // Arrange
      const product = Product(productionCost: 50.0, salePrice: 100.0);
      when(() => mockGateway.calculateProfitMargin(product)).thenReturn(50.0);

      // Act
      final result = useCase.execute(product);

      // Assert
      expect(result, equals(50.0));
      verify(() => mockGateway.calculateProfitMargin(product)).called(1);
    });

    test('should propagate exception thrown by gateway', () {
      // Arrange
      const product = Product(productionCost: 50.0, salePrice: 0.0);
      when(
        () => mockGateway.calculateProfitMargin(product),
      ).thenThrow(Exception('salePrice cannot be zero'));

      // Act
      void call() => useCase.execute(product);

      // Assert
      expect(call, throwsA(isA<Exception>()));
    });
  });
}
