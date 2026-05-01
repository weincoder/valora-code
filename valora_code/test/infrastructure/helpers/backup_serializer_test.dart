import 'package:flutter_test/flutter_test.dart';
import 'package:valora_code/domain/models/additional_cost/additional_cost.dart';
import 'package:valora_code/domain/models/backup/backup_data.dart';
import 'package:valora_code/domain/models/expense/expense.dart';
import 'package:valora_code/domain/models/expense/expense_category.dart';
import 'package:valora_code/domain/models/product_item/product_item.dart';
import 'package:valora_code/domain/models/sale_record/sale_record.dart';
import 'package:valora_code/infrastructure/helpers/backup_serializer.dart';

final _sampleProduct = ProductItem(
  id: 'prod-1',
  title: 'App móvil',
  description: 'Desarrollo app iOS',
  hourlyRate: 60.0,
  estimatedHours: 10.0,
  additionalCosts: const [AdditionalCost(label: 'Hosting', amount: 50.0)],
  salePrice: 800.0,
  profitMargin: 25.0,
  createdAt: DateTime(2025, 3, 15),
);

final _sampleSaleRecord = SaleRecord(
  id: 'sale-1',
  productItemId: 'prod-1',
  productTitle: 'App móvil',
  quantity: 2,
  unitPrice: 800.0,
  totalAmount: 1600.0,
  date: DateTime(2025, 4, 10),
);

final _sampleExpense = Expense(
  id: 'exp-1',
  description: 'Adobe Suite',
  amount: 600.0,
  category: ExpenseCategory.software,
  date: DateTime(2025, 3, 5),
);

BackupData _makeBackupData({
  List<ProductItem>? products,
  List<SaleRecord>? saleRecords,
  List<Expense>? expenses,
}) {
  return BackupData(
    products: products ?? [_sampleProduct],
    saleRecords: saleRecords ?? [_sampleSaleRecord],
    expenses: expenses ?? [_sampleExpense],
    version: '2.0.0',
    exportedAt: DateTime(2025, 5, 1),
  );
}

void main() {
  group('BackupSerializer.serialize', () {
    test('should produce valid JSON string with all product fields', () {
      final data = _makeBackupData();
      final result = BackupSerializer.serialize(data);
      expect(result, contains('"version":"2.0.0"'));
      expect(result, contains('"id":"prod-1"'));
      expect(result, contains('"title":"App móvil"'));
    });

    test('should include saleRecords and expenses in JSON', () {
      final data = _makeBackupData();
      final result = BackupSerializer.serialize(data);
      expect(result, contains('"saleRecords"'));
      expect(result, contains('"sale-1"'));
      expect(result, contains('"expenses"'));
      expect(result, contains('"exp-1"'));
      expect(result, contains('"software"'));
    });

    test('should produce JSON with empty lists', () {
      final data = _makeBackupData(
        products: const [],
        saleRecords: const [],
        expenses: const [],
      );
      final result = BackupSerializer.serialize(data);
      expect(result, contains('"products":[]'));
      expect(result, contains('"saleRecords":[]'));
      expect(result, contains('"expenses":[]'));
    });
  });

  group('BackupSerializer.deserialize', () {
    test('should perform a lossless roundtrip serialization', () {
      final original = _makeBackupData();
      final json = BackupSerializer.serialize(original);
      final restored = BackupSerializer.deserialize(json);
      expect(restored.version, equals('2.0.0'));
      expect(restored.products, hasLength(1));
      expect(restored.products.first.id, equals('prod-1'));
      expect(restored.products.first.salePrice, equals(800.0));
      expect(restored.saleRecords, hasLength(1));
      expect(restored.saleRecords.first.id, equals('sale-1'));
      expect(restored.saleRecords.first.totalAmount, equals(1600.0));
      expect(restored.expenses, hasLength(1));
      expect(restored.expenses.first.id, equals('exp-1'));
      expect(restored.expenses.first.category, equals(ExpenseCategory.software));
    });

    test('should use fallback values when fields are missing', () {
      const minimalJson =
          '{"version":"1.0.0","exportedAt":"2025-01-01T00:00:00.000",'
          '"products":[{"id":"x"}]}';
      final result = BackupSerializer.deserialize(minimalJson);
      expect(result.products.first.title, equals('Sin título'));
      expect(result.products.first.hourlyRate, equals(0.0));
      expect(result.products.first.salePrice, equals(0.0));
      expect(result.products.first.additionalCosts, isEmpty);
      expect(result.saleRecords, isEmpty);
      expect(result.expenses, isEmpty);
    });

    test('should ignore legacy file paths as imageBase64', () {
      const json =
          '{"version":"1.0.0","exportedAt":"2025-01-01T00:00:00.000",'
          '"products":[{"id":"x","imageBase64":"/old/path/image.jpg"}]}';
      final result = BackupSerializer.deserialize(json);
      expect(result.products.first.imageBase64, isNull);
    });

    test('should fallback unknown expense category to other', () {
      const json =
          '{"version":"2.0.0","exportedAt":"2025-01-01T00:00:00.000",'
          '"products":[],"saleRecords":[],'
          '"expenses":[{"id":"e1","description":"Test","amount":100.0,'
          '"category":"unknown_cat","date":"2025-01-01T00:00:00.000"}]}';
      final result = BackupSerializer.deserialize(json);
      expect(result.expenses.first.category, equals(ExpenseCategory.other));
    });
  });
}
