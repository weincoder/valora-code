import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:valora_code/domain/models/sale_record/sale_record.dart';
import 'package:valora_code/infrastructure/driven_adapters/sale_record/sale_record_hive_adapter.dart';

void main() {
  late SaleRecordHiveAdapter adapter;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_sale_test_');
    Hive.init(tempDir.path);
  });

  setUp(() {
    adapter = SaleRecordHiveAdapter();
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk('sale_records');
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  final sampleRecord = SaleRecord(
    id: 'sale-1',
    productItemId: 'prod-1',
    productTitle: 'Desarrollo web',
    quantity: 2,
    unitPrice: 600.0,
    totalAmount: 1200.0,
    date: DateTime(2025, 4, 5),
    notes: 'Cliente feliz',
  );

  group('SaleRecordHiveAdapter', () {
    test('getAll returns empty list when box is empty', () async {
      // Arrange & Act
      final result = await adapter.getAll();

      // Assert
      expect(result, isEmpty);
    });

    test('save persists a sale record and getAll returns it', () async {
      // Arrange & Act
      await adapter.save(sampleRecord);
      final result = await adapter.getAll();

      // Assert
      expect(result.length, 1);
      expect(result.first.id, 'sale-1');
      expect(result.first.productTitle, 'Desarrollo web');
      expect(result.first.quantity, 2);
      expect(result.first.unitPrice, 600.0);
      expect(result.first.totalAmount, 1200.0);
    });

    test('save preserves notes', () async {
      // Arrange & Act
      await adapter.save(sampleRecord);
      final result = await adapter.getAll();

      // Assert
      expect(result.first.notes, 'Cliente feliz');
    });

    test('save overwrites record with same id', () async {
      // Arrange
      await adapter.save(sampleRecord);
      final updated = SaleRecord(
        id: 'sale-1',
        productItemId: 'prod-2',
        productTitle: 'Diseño gráfico',
        quantity: 1,
        unitPrice: 300.0,
        totalAmount: 300.0,
        date: DateTime(2025, 5, 1),
      );

      // Act
      await adapter.save(updated);
      final result = await adapter.getAll();

      // Assert
      expect(result.length, 1);
      expect(result.first.productTitle, 'Diseño gráfico');
      expect(result.first.quantity, 1);
    });

    test('delete removes record by id', () async {
      // Arrange
      await adapter.save(sampleRecord);

      // Act
      await adapter.delete('sale-1');
      final result = await adapter.getAll();

      // Assert
      expect(result, isEmpty);
    });

    test('delete non-existent id does not throw', () async {
      // Arrange & Act & Assert
      expect(() => adapter.delete('non-existent'), returnsNormally);
    });

    test('save multiple records and retrieve all', () async {
      // Arrange
      final record2 = SaleRecord(
        id: 'sale-2',
        productItemId: 'prod-3',
        productTitle: 'Consultoría',
        quantity: 3,
        unitPrice: 200.0,
        totalAmount: 600.0,
        date: DateTime(2025, 6, 1),
      );

      // Act
      await adapter.save(sampleRecord);
      await adapter.save(record2);
      final result = await adapter.getAll();

      // Assert
      expect(result.length, 2);
      expect(result.map((e) => e.id), containsAll(['sale-1', 'sale-2']));
    });
  });
}
