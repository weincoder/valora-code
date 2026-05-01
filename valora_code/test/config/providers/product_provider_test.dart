import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/config/providers/product_provider.dart';
import 'package:valora_code/domain/models/product/product.dart';
import 'package:valora_code/domain/models/product/product_exception.dart';
import 'package:valora_code/domain/models/product/gateway/product_gateway.dart';
import 'package:valora_code/domain/usecase/calculate_profit_margin_use_case.dart';

class MockProductGateway extends Mock implements ProductGateway {}

void main() {
  late MockProductGateway mockGateway;
  late CalculateProfitMarginUseCase useCase;

  setUpAll(() {
    registerFallbackValue(const Product(productionCost: 0, salePrice: 0));
  });

  setUp(() {
    mockGateway = MockProductGateway();
    useCase = CalculateProfitMarginUseCase(gateway: mockGateway);
  });

  group('ProductState', () {
    test('should have default values on initial state', () {
      // Arrange & Act
      const state = ProductState();

      // Assert
      expect(state.profitMargin, isNull);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('should copyWith updating isLoading', () {
      // Arrange
      const state = ProductState();

      // Act
      final updated = state.copyWith(isLoading: true);

      // Assert
      expect(updated.isLoading, isTrue);
      expect(updated.profitMargin, isNull);
    });
  });

  group('ProductNotifier.calculate', () {
    test('should emit state with profitMargin when calculation succeeds', () {
      // Arrange
      when(() => mockGateway.calculateProfitMargin(any())).thenReturn(50.0);
      final container = ProviderContainer(
        overrides: [
          productNotifierProvider.overrideWith(
            (ref) => ProductNotifier(useCase: useCase),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Act
      container.read(productNotifierProvider.notifier).calculate(50.0, 100.0);

      // Assert
      final state = container.read(productNotifierProvider);
      expect(state.profitMargin, equals(50.0));
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test(
      'should emit state with errorMessage when ProductException is thrown',
      () {
        // Arrange
        when(() => mockGateway.calculateProfitMargin(any())).thenThrow(
          const ProductException('El precio de venta no puede ser cero'),
        );
        final container = ProviderContainer(
          overrides: [
            productNotifierProvider.overrideWith(
              (ref) => ProductNotifier(useCase: useCase),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Act
        container.read(productNotifierProvider.notifier).calculate(50.0, 0.0);

        // Assert
        final state = container.read(productNotifierProvider);
        expect(state.profitMargin, isNull);
        expect(state.isLoading, isFalse);
        expect(
          state.errorMessage,
          equals('El precio de venta no puede ser cero'),
        );
      },
    );

    test(
      'should emit generic errorMessage when unexpected exception is thrown',
      () {
        // Arrange
        when(
          () => mockGateway.calculateProfitMargin(any()),
        ).thenThrow(Exception('unexpected'));
        final container = ProviderContainer(
          overrides: [
            productNotifierProvider.overrideWith(
              (ref) => ProductNotifier(useCase: useCase),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Act
        container.read(productNotifierProvider.notifier).calculate(50.0, 100.0);

        // Assert
        final state = container.read(productNotifierProvider);
        expect(state.errorMessage, equals('Ocurrió un error inesperado'));
      },
    );
  });
}
