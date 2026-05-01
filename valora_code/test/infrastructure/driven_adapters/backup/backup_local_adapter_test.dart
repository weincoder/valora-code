import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/domain/models/additional_cost/additional_cost.dart';
import 'package:valora_code/domain/models/backup/backup_data.dart';
import 'package:valora_code/domain/models/expense/expense.dart';
import 'package:valora_code/domain/models/expense/expense_category.dart';
import 'package:valora_code/domain/models/expense/gateway/expense_gateway.dart';
import 'package:valora_code/domain/models/product_item/product_item.dart';
import 'package:valora_code/domain/models/product_item/gateway/product_item_gateway.dart';
import 'package:valora_code/domain/models/sale_record/sale_record.dart';
import 'package:valora_code/domain/models/sale_record/gateway/sale_record_gateway.dart';
import 'package:valora_code/infrastructure/driven_adapters/backup/backup_local_adapter.dart';
import 'package:valora_code/infrastructure/helpers/backup_serializer.dart';

class MockProductItemGateway extends Mock implements ProductItemGateway {}
class MockSaleRecordGateway extends Mock implements SaleRecordGateway {}
class MockExpenseGateway extends Mock implements ExpenseGateway {}

final _sampleProduct = ProductItem(
  id: 'prod-1',
  title: 'App móvil',
  description: 'Desarrollo',
  hourlyRate: 50.0,
  estimatedHours: 8.0,
  additionalCosts: const [AdditionalCost(label: 'Hosting', amount: 30.0)],
  salePrice: 500.0,
  profitMargin: 20.0,
  createdAt: DateTime(2025, 1, 1),
);

final _sampleSaleRecord = SaleRecord(
  id: 'sale-1',
  productItemId: 'prod-1',
  productTitle: 'App móvil',
  quantity: 1,
  unitPrice: 500.0,
  totalAmount: 500.0,
  date: DateTime(2025, 3, 10),
);

final _sampleExpense = Expense(
  id: 'exp-1',
  description: 'Hosting',
  amount: 100.0,
  category: ExpenseCategory.services,
  date: DateTime(2025, 3, 1),
);

void main() {
  late MockProductItemGateway mockProductGateway;
  late MockSaleRecordGateway mockSaleGateway;
  late MockExpenseGateway mockExpenseGateway;
  late BackupLocalAdapter adapter;

  setUpAll(() {
    registerFallbackValue(_sampleProduct);
    registerFallbackValue(_sampleSaleRecord);
    registerFallbackValue(_sampleExpense);
  });

  setUp(() {
    mockProductGateway = MockProductItemGateway();
    mockSaleGateway = MockSaleRecordGateway();
    mockExpenseGateway = MockExpenseGateway();
    adapter = BackupLocalAdapter(
      productItemGateway: mockProductGateway,
      saleRecordGateway: mockSaleGateway,
      expenseGateway: mockExpenseGateway,
    );
  });

  group('exportToJson', () {
    test('should return JSON string with all data from gateways', () async {
      // Arrange
      when(() => mockProductGateway.getAll()).thenAnswer((_) async => [_sampleProduct]);
      when(() => mockSaleGateway.getAll()).thenAnswer((_) async => [_sampleSaleRecord]);
      when(() => mockExpenseGateway.getAll()).thenAnswer((_) async => [_sampleExpense]);

      // Act
      final result = await adapter.exportToJson();

      // Assert
      expect(result, contains('"id":"prod-1"'));
      expect(result, contains('"sale-1"'));
      expect(result, contains('"exp-1"'));
      verify(() => mockProductGateway.getAll()).called(1);
    });
  });

  group('importFromJson', () {
    test('should clear existing data and restore all entities from JSON', () async {
      // Arrange
      final data = BackupData(
        products: [_sampleProduct],
        saleRecords: [_sampleSaleRecord],
        expenses: [_sampleExpense],
        version: '2.0.0',
        exportedAt: DateTime(2025, 5, 1),
      );
      final json = BackupSerializer.serialize(data);

      when(() => mockProductGateway.getAll()).thenAnswer((_) async => [_sampleProduct]);
      when(() => mockProductGateway.delete(any())).thenAnswer((_) async {});
      when(() => mockProductGateway.save(any())).thenAnswer((_) async {});
      when(() => mockSaleGateway.getAll()).thenAnswer((_) async => [_sampleSaleRecord]);
      when(() => mockSaleGateway.delete(any())).thenAnswer((_) async {});
      when(() => mockSaleGateway.save(any())).thenAnswer((_) async {});
      when(() => mockExpenseGateway.getAll()).thenAnswer((_) async => [_sampleExpense]);
      when(() => mockExpenseGateway.delete(any())).thenAnswer((_) async {});
      when(() => mockExpenseGateway.save(any())).thenAnswer((_) async {});

      // Act
      await adapter.importFromJson(json);

      // Assert
      verify(() => mockProductGateway.delete('prod-1')).called(1);
      verify(() => mockSaleGateway.delete('sale-1')).called(1);
      verify(() => mockExpenseGateway.delete('exp-1')).called(1);
      verify(() => mockProductGateway.save(any())).called(1);
      verify(() => mockSaleGateway.save(any())).called(1);
      verify(() => mockExpenseGateway.save(any())).called(1);
    });

    test('should throw when JSON is malformed', () async {
      // Arrange
      const badJson = 'NOT_VALID_JSON';

      // Act & Assert
      await expectLater(
        () => adapter.importFromJson(badJson),
        throwsA(isA<Exception>()),
      );
    });
  });
}
