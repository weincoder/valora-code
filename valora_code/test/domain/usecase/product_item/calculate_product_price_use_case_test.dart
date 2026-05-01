import 'package:flutter_test/flutter_test.dart';
import 'package:valora_code/domain/models/additional_cost/additional_cost.dart';
import 'package:valora_code/domain/usecase/product_item/calculate_product_price_use_case.dart';

void main() {
  late CalculateProductPriceUseCase useCase;

  setUp(() {
    useCase = CalculateProductPriceUseCase();
  });

  group('execute', () {
    test('should return labor cost only when additionalCosts is empty', () {
      // Arrange
      const hourlyRate = 50.0;
      const estimatedHours = 8.0;
      const additionalCosts = <AdditionalCost>[];

      // Act
      final result = useCase.execute(
        hourlyRate: hourlyRate,
        estimatedHours: estimatedHours,
        additionalCosts: additionalCosts,
      );

      // Assert
      expect(result, equals(400.0));
    });

    test('should sum labor cost and all additional costs', () {
      // Arrange
      const hourlyRate = 50.0;
      const estimatedHours = 4.0;
      final additionalCosts = [
        const AdditionalCost(label: 'Hosting', amount: 30.0),
        const AdditionalCost(label: 'Licencias', amount: 20.0),
      ];

      // Act
      final result = useCase.execute(
        hourlyRate: hourlyRate,
        estimatedHours: estimatedHours,
        additionalCosts: additionalCosts,
      );

      // Assert
      expect(result, equals(250.0));
    });

    test('should return zero when all values are zero', () {
      // Arrange
      const hourlyRate = 0.0;
      const estimatedHours = 0.0;
      const additionalCosts = <AdditionalCost>[];

      // Act
      final result = useCase.execute(
        hourlyRate: hourlyRate,
        estimatedHours: estimatedHours,
        additionalCosts: additionalCosts,
      );

      // Assert
      expect(result, equals(0.0));
    });
  });
}
