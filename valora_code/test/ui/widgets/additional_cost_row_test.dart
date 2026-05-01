import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valora_code/ui/widgets/additional_cost_row.dart';

Widget _buildRow({
  required int index,
  required TextEditingController labelCtrl,
  required TextEditingController amountCtrl,
  required VoidCallback onRemove,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Form(
        child: AdditionalCostRow(
          index: index,
          labelController: labelCtrl,
          amountController: amountCtrl,
          onRemove: onRemove,
        ),
      ),
    ),
  );
}

void main() {
  group('Find the page widgets', () {
    testWidgets('should find label field, amount field and remove button', (
      tester,
    ) async {
      // Arrange
      final labelCtrl = TextEditingController();
      final amountCtrl = TextEditingController();
      await tester.pumpWidget(
        _buildRow(
          index: 0,
          labelCtrl: labelCtrl,
          amountCtrl: amountCtrl,
          onRemove: () {},
        ),
      );

      // Act & Assert
      expect(find.byKey(const Key('additional-cost-row-0')), findsOneWidget);
      expect(find.byKey(const Key('cost-label-0')), findsOneWidget);
      expect(find.byKey(const Key('cost-amount-0')), findsOneWidget);
      expect(find.byKey(const Key('remove-cost-0')), findsOneWidget);
    });
  });

  group('Interaction with page widgets', () {
    testWidgets('should call onRemove when remove button is tapped', (
      tester,
    ) async {
      // Arrange
      var removed = false;
      final labelCtrl = TextEditingController();
      final amountCtrl = TextEditingController();
      await tester.pumpWidget(
        _buildRow(
          index: 1,
          labelCtrl: labelCtrl,
          amountCtrl: amountCtrl,
          onRemove: () => removed = true,
        ),
      );

      // Act
      await tester.tap(find.byKey(const Key('remove-cost-1')));
      await tester.pumpAndSettle();

      // Assert
      expect(removed, isTrue);
    });

    testWidgets('should accept text in label and amount fields', (
      tester,
    ) async {
      // Arrange
      final labelCtrl = TextEditingController();
      final amountCtrl = TextEditingController();
      await tester.pumpWidget(
        _buildRow(
          index: 0,
          labelCtrl: labelCtrl,
          amountCtrl: amountCtrl,
          onRemove: () {},
        ),
      );

      // Act
      await tester.enterText(find.byKey(const Key('cost-label-0')), 'Hosting');
      await tester.enterText(find.byKey(const Key('cost-amount-0')), '50.0');

      // Assert
      expect(labelCtrl.text, equals('Hosting'));
      expect(amountCtrl.text, equals('50.0'));
    });
  });

  group('Test Page Experience', () {
    testWidgets(
      'should show validation errors when fields are empty on form submit',
      (tester) async {
        // Arrange
        final formKey = GlobalKey<FormState>();
        final labelCtrl = TextEditingController();
        final amountCtrl = TextEditingController();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: Column(
                  children: [
                    AdditionalCostRow(
                      index: 0,
                      labelController: labelCtrl,
                      amountController: amountCtrl,
                      onRemove: () {},
                    ),
                    ElevatedButton(
                      onPressed: () => formKey.currentState!.validate(),
                      child: const Text('Validar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Validar'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Ingresa un concepto'), findsOneWidget);
        expect(find.text('Requerido'), findsOneWidget);
      },
    );
  });
}
