import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/config/providers/product_provider.dart';
import 'package:valora_code/domain/models/product/product.dart';
import 'package:valora_code/domain/models/product/gateway/product_gateway.dart';
import 'package:valora_code/domain/usecase/calculate_profit_margin_use_case.dart';
import 'package:valora_code/ui/widgets/cost_calculator_form.dart';

class MockProductGateway extends Mock implements ProductGateway {}

Widget _buildApp(ProductNotifier notifier) {
  return ProviderScope(
    overrides: [productNotifierProvider.overrideWith((_) => notifier)],
    child: const MaterialApp(home: Scaffold(body: CostCalculatorForm())),
  );
}

void main() {
  late MockProductGateway mockGateway;
  late ProductNotifier notifier;

  setUpAll(() {
    registerFallbackValue(const Product(productionCost: 0, salePrice: 0));
  });

  setUp(() {
    mockGateway = MockProductGateway();
    notifier = ProductNotifier(
      useCase: CalculateProfitMarginUseCase(gateway: mockGateway),
    );
  });

  group('Find the page widgets', () {
    testWidgets(
      'should find production cost field, sale price field and calculate button',
      (tester) async {
        // Arrange
        await tester.pumpWidget(_buildApp(notifier));

        // Act & Assert
        expect(find.byKey(const Key('production-cost-field')), findsOneWidget);
        expect(find.byKey(const Key('sale-price-field')), findsOneWidget);
        expect(find.byKey(const Key('calculate-button')), findsOneWidget);
        expect(find.text('Calcular margen'), findsOneWidget);
      },
    );
  });

  group('Interaction with page widgets', () {
    testWidgets(
      'should show validation errors when fields are empty on submit',
      (tester) async {
        // Arrange
        await tester.pumpWidget(_buildApp(notifier));

        // Act
        await tester.tap(find.byKey(const Key('calculate-button')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Este campo es obligatorio'), findsWidgets);
      },
    );

    testWidgets('should show validation error when input is not a number', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_buildApp(notifier));

      // Act
      await tester.enterText(
        find.byKey(const Key('production-cost-field')),
        'abc',
      );
      await tester.enterText(find.byKey(const Key('sale-price-field')), 'xyz');
      await tester.tap(find.byKey(const Key('calculate-button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ingresa un número válido'), findsWidgets);
    });
  });

  group('Test Page Experience', () {
    testWidgets(
      'should call calculate on notifier when form is valid and button is tapped',
      (tester) async {
        // Arrange
        when(() => mockGateway.calculateProfitMargin(any())).thenReturn(50.0);
        await tester.pumpWidget(_buildApp(notifier));

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
        verify(() => mockGateway.calculateProfitMargin(any())).called(1);
      },
    );

    testWidgets(
      'should not call calculate when a field contains a negative value',
      (tester) async {
        // Arrange
        await tester.pumpWidget(_buildApp(notifier));

        // Act
        await tester.enterText(
          find.byKey(const Key('production-cost-field')),
          '-10',
        );
        await tester.enterText(
          find.byKey(const Key('sale-price-field')),
          '100',
        );
        await tester.tap(find.byKey(const Key('calculate-button')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('El valor no puede ser negativo'), findsOneWidget);
        verifyNever(() => mockGateway.calculateProfitMargin(any()));
      },
    );
  });
}
