import 'package:flutter_test/flutter_test.dart';
import 'package:valora_code/domain/models/sale_record/sale_record.dart';

SaleRecord _makeSaleRecord({
  String id = 'sale-1',
  String productItemId = 'prod-1',
  String productTitle = 'App móvil',
  int quantity = 2,
  double unitPrice = 500.0,
  double totalAmount = 1000.0,
  DateTime? date,
  String? notes,
}) {
  return SaleRecord(
    id: id,
    productItemId: productItemId,
    productTitle: productTitle,
    quantity: quantity,
    unitPrice: unitPrice,
    totalAmount: totalAmount,
    date: date ?? DateTime(2025, 6, 15),
    notes: notes,
  );
}

void main() {
  group('SaleRecord', () {
    test('should create a SaleRecord with all required fields', () {
      // Arrange & Act
      final record = _makeSaleRecord();

      // Assert
      expect(record.id, equals('sale-1'));
      expect(record.productItemId, equals('prod-1'));
      expect(record.productTitle, equals('App móvil'));
      expect(record.quantity, equals(2));
      expect(record.unitPrice, equals(500.0));
      expect(record.totalAmount, equals(1000.0));
      expect(record.date, equals(DateTime(2025, 6, 15)));
      expect(record.notes, isNull);
    });

    test('should create a SaleRecord with optional notes', () {
      // Arrange & Act
      final record = _makeSaleRecord(notes: 'Pago anticipado');

      // Assert
      expect(record.notes, equals('Pago anticipado'));
    });

    group('copyWith', () {
      test('should return a new record with updated quantity', () {
        // Arrange
        final original = _makeSaleRecord();

        // Act
        final copy = original.copyWith(quantity: 5);

        // Assert
        expect(copy.quantity, equals(5));
        expect(copy.id, equals(original.id));
        expect(copy.productTitle, equals(original.productTitle));
      });

      test('should clear notes when clearNotes is true', () {
        // Arrange
        final original = _makeSaleRecord(notes: 'Alguna nota');

        // Act
        final copy = original.copyWith(clearNotes: true);

        // Assert
        expect(copy.notes, isNull);
      });

      test('should not change unchanged fields', () {
        // Arrange
        final original = _makeSaleRecord();

        // Act
        final copy = original.copyWith(unitPrice: 600.0);

        // Assert
        expect(copy.id, equals(original.id));
        expect(copy.productItemId, equals(original.productItemId));
        expect(copy.productTitle, equals(original.productTitle));
        expect(copy.quantity, equals(original.quantity));
        expect(copy.unitPrice, equals(600.0));
        expect(copy.totalAmount, equals(original.totalAmount));
        expect(copy.date, equals(original.date));
      });
    });
  });
}
