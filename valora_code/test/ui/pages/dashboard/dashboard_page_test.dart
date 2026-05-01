import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/config/providers/product_provider.dart';
import 'package:valora_code/domain/models/product/product.dart';
import 'package:valora_code/domain/models/product/product_exception.dart';
import 'package:valora_code/domain/models/product/gateway/product_gateway.dart';
import 'package:valora_code/domain/usecase/calculate_profit_margin_use_case.dart';
import 'package:valora_code/ui/pages/dashboard/dashboard_page.dart';

class MockProductGateway extends Mock implements ProductGateway {}

Widget _buildApp({
  required StateNotifierProvider<ProductNotifier, ProductState> provider,
}) {
  return ProviderScope(
    overrides: [
      productNotifierProvider.overrideWith((ref) {
        final mockGateway = MockProductGateway();
        when(() => mockGateway.calculateProfitMargin(any())).thenReturn(50.0);
        final useCase = CalculateProfitMarginUseCase(gateway: mockGateway);
        return ProductNotifier(useCase: useCase);
      }),
    ],
    child: const MaterialApp(home: DashboardPage()),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const Product(productionCost: 0, salePrice: 0));
  });

  group('Find the page widgets', () {
    testWidgets('should find AppBar with title "Calculadora de Costos"', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_buildApp(provider: productNotifierProvider));

      // Act & Assert
      expect(find.text('Calculadora de Costos'), findsOneWidget);
    });

    testWidgets('should find production cost and sale price fields', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_buildApp(provider: productNotifierProvider));

      // Act & Assert
      expect(find.byKey(const Key('production-cost-field')), findsOneWidget);
      expect(find.byKey(const Key('sale-price-field')), findsOneWidget);
    });

    testWidgets('should find calculate button', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp(provider: productNotifierProvider));

      // Act & Assert
      expect(find.byKey(const Key('calculate-button')), findsOneWidget);
    });

    testWidgets('should not show result card initially', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp(provider: productNotifierProvider));

      // Act & Assert
      expect(find.byKey(const Key('result-card')), findsNothing);
    });
  });

  group('Interaction with page widgets', () {
    testWidgets(
      'should show validation error when fields are empty and button is tapped',
      (tester) async {
        // Arrange
        await tester.pumpWidget(_buildApp(provider: productNotifierProvider));

        // Act
        await tester.tap(find.byKey(const Key('calculate-button')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Este campo es obligatorio'), findsWidgets);
      },
    );

    testWidgets('should accept numeric input in text fields', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp(provider: productNotifierProvider));

      // Act
      await tester.enterText(
        find.byKey(const Key('production-cost-field')),
        '50',
      );
      await tester.enterText(find.byKey(const Key('sale-price-field')), '100');

      // Assert
      expect(find.text('50'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
    });
  });

  group('Test Page Experience', () {
    testWidgets(
      'should display result card with profit margin after successful calculation',
      (tester) async {
        // Arrange
        await tester.pumpWidget(_buildApp(provider: productNotifierProvider));

        // Act
        await tester.enterText(
          find.byKey(const Key('production-cost-field')),
          '50',
        );
        await tester.enterText(
          find.byKey(const Key('sale-price-field')),
          '100',
        );
        await tester.tap(find.byKey(const Key('calculate-button')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byKey(const Key('result-card')), findsOneWidget);
        expect(find.byKey(const Key('profit-margin-text')), findsOneWidget);
      },
    );

    testWidgets('should display error card when ProductException is thrown', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productNotifierProvider.overrideWith((ref) {
              final mockGateway = MockProductGateway();
              when(() => mockGateway.calculateProfitMargin(any())).thenThrow(
                const ProductException('El precio de venta no puede ser cero'),
              );
              final useCase = CalculateProfitMarginUseCase(
                gateway: mockGateway,
              );
              return ProductNotifier(useCase: useCase);
            }),
          ],
          child: const MaterialApp(home: DashboardPage()),
        ),
      );

      // Act
      await tester.enterText(
        find.byKey(const Key('production-cost-field')),
        '50',
      );
      await tester.enterText(find.byKey(const Key('sale-price-field')), '0');
      await tester.tap(find.byKey(const Key('calculate-button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('error-card')), findsOneWidget);
      expect(find.byKey(const Key('error-message-text')), findsOneWidget);
    });
  });
}
