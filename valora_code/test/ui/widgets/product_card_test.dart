import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valora_code/domain/models/additional_cost/additional_cost.dart';
import 'package:valora_code/domain/models/product_item/product_item.dart';
import 'package:valora_code/ui/widgets/product_card.dart';

final _product = ProductItem(
  id: 'p1',
  title: 'App iOS',
  description: 'Aplicación nativa para iPhone',
  hourlyRate: 60.0,
  estimatedHours: 10.0,
  additionalCosts: const [AdditionalCost(label: 'Hosting', amount: 50)],
  salePrice: 800.0,
  profitMargin: 30.0,
  createdAt: DateTime(2025, 1, 1),
);

void main() {
  group('Find the page widgets', () {
    testWidgets('should find title, description and price badge', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: _product, onTap: () {}),
          ),
        ),
      );

      // Act & Assert
      expect(find.byKey(const Key('product-card-p1')), findsOneWidget);
      expect(find.byKey(const Key('product-title-p1')), findsOneWidget);
      expect(find.text('App iOS'), findsOneWidget);
      expect(find.text('Aplicación nativa para iPhone'), findsOneWidget);
    });

    testWidgets('should show price and margin badges', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: _product, onTap: () {}),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('\$800.00'), findsOneWidget);
      expect(find.text('30.0% margen'), findsOneWidget);
    });

    testWidgets('should not show image when imageBase64 is null', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: _product, onTap: () {}),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(Image), findsNothing);
    });
  });

  group('Interaction with page widgets', () {
    testWidgets('should call onTap when card is tapped', (tester) async {
      // Arrange
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: _product, onTap: () => tapped = true),
          ),
        ),
      );

      // Act
      await tester.tap(find.byKey(const Key('product-card-p1')));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, isTrue);
    });
  });

  group('Test Page Experience', () {
    testWidgets('should truncate long description to two lines', (
      tester,
    ) async {
      // Arrange
      final longDesc = 'A' * 300;
      final product = _product.copyWith(description: longDesc);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: product, onTap: () {}),
          ),
        ),
      );

      // Act & Assert — Text widget with maxLines:2 exists and doesn't overflow
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final descWidget = textWidgets.firstWhere(
        (t) => t.maxLines == 2,
        orElse: () => const Text(''),
      );
      expect(descWidget.maxLines, equals(2));
    });
  });
}
