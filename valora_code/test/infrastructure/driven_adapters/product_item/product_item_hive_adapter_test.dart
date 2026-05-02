import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:valora_code/domain/models/additional_cost/additional_cost.dart';
import 'package:valora_code/domain/models/product_item/product_item.dart';
import 'package:valora_code/infrastructure/driven_adapters/product_item/product_item_hive_adapter.dart';

void main() {
  late ProductItemHiveAdapter adapter;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_product_test_');
    Hive.init(tempDir.path);
  });

  setUp(() {
    adapter = ProductItemHiveAdapter();
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk('products');
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  final sampleItem = ProductItem(
    id: 'item-1',
    title: 'App móvil',
    description: 'Desarrollo iOS y Android',
    hourlyRate: 60.0,
    estimatedHours: 40.0,
    additionalCosts: const [AdditionalCost(label: 'Licencias', amount: 100.0)],
    salePrice: 2800.0,
    profitMargin: 40.0,
    createdAt: DateTime(2025, 1, 10),
  );

  group('ProductItemHiveAdapter', () {
    test('getAll returns empty list when box is empty', () async {
      // Arrange & Act
      final result = await adapter.getAll();

      // Assert
      expect(result, isEmpty);
    });

    test('save persists a product item and getAll returns it', () async {
      // Arrange & Act
      await adapter.save(sampleItem);
      final result = await adapter.getAll();

      // Assert
      expect(result.length, 1);
      expect(result.first.id, 'item-1');
      expect(result.first.title, 'App móvil');
      expect(result.first.hourlyRate, 60.0);
      expect(result.first.estimatedHours, 40.0);
    });

    test('save includes additional costs', () async {
      // Arrange & Act
      await adapter.save(sampleItem);
      final result = await adapter.getAll();

      // Assert
      expect(result.first.additionalCosts.length, 1);
      expect(result.first.additionalCosts.first.label, 'Licencias');
      expect(result.first.additionalCosts.first.amount, 100.0);
    });

    test('save overwrites product item with same id', () async {
      // Arrange
      await adapter.save(sampleItem);
      final updated = ProductItem(
        id: 'item-1',
        title: 'App actualizada',
        description: 'Nueva descripción',
        hourlyRate: 70.0,
        estimatedHours: 30.0,
        additionalCosts: const [],
        salePrice: 3000.0,
        profitMargin: 45.0,
        createdAt: DateTime(2025, 2, 1),
      );

      // Act
      await adapter.save(updated);
      final result = await adapter.getAll();

      // Assert
      expect(result.length, 1);
      expect(result.first.title, 'App actualizada');
      expect(result.first.hourlyRate, 70.0);
    });

    test('delete removes product item by id', () async {
      // Arrange
      await adapter.save(sampleItem);

      // Act
      await adapter.delete('item-1');
      final result = await adapter.getAll();

      // Assert
      expect(result, isEmpty);
    });

    test('delete non-existent id does not throw', () async {
      // Arrange & Act & Assert
      expect(() => adapter.delete('non-existent'), returnsNormally);
    });

    test('save multiple items and retrieve all', () async {
      // Arrange
      final item2 = ProductItem(
        id: 'item-2',
        title: 'Diseño web',
        description: 'Landing page',
        hourlyRate: 45.0,
        estimatedHours: 16.0,
        additionalCosts: const [],
        salePrice: 800.0,
        profitMargin: 35.0,
        createdAt: DateTime(2025, 3, 1),
      );

      // Act
      await adapter.save(sampleItem);
      await adapter.save(item2);
      final result = await adapter.getAll();

      // Assert
      expect(result.length, 2);
      expect(result.map((e) => e.id), containsAll(['item-1', 'item-2']));
    });
  });
}
