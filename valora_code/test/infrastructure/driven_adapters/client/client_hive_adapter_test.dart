import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:valora_code/domain/models/client/client.dart';
import 'package:valora_code/infrastructure/driven_adapters/client/client_hive_adapter.dart';

void main() {
  late Box<Map> box;
  late ClientHiveAdapter adapter;

  setUp(() async {
    Hive.init(null);
    // Use an in-memory box for tests
    box = await Hive.openBox<Map>('clients');
    adapter = ClientHiveAdapter();
  });

  tearDown(() async {
    await box.clear();
    await box.close();
  });

  group('ClientHiveAdapter.getAll', () {
    test('should return empty list when box is empty', () async {
      // Arrange – box is already empty

      // Act
      final result = await adapter.getAll();

      // Assert
      expect(result, isEmpty);
    });

    test('should return all clients after saving', () async {
      // Arrange
      const client = Client(
        id: 'c-1',
        fullName: 'Test',
        documentId: '111',
        email: 't@t.com',
        phone: '300',
      );
      await adapter.save(client);

      // Act
      final result = await adapter.getAll();

      // Assert
      expect(result.length, 1);
      expect(result.first.id, 'c-1');
    });
  });

  group('ClientHiveAdapter.getById', () {
    test('should return null when client does not exist', () async {
      // Arrange – empty box

      // Act
      final result = await adapter.getById('nonexistent');

      // Assert
      expect(result, isNull);
    });

    test('should return client with matching id', () async {
      // Arrange
      const client = Client(
        id: 'c-2',
        fullName: 'Pedro',
        documentId: '222',
        email: 'p@p.com',
        phone: '301',
      );
      await adapter.save(client);

      // Act
      final result = await adapter.getById('c-2');

      // Assert
      expect(result?.fullName, 'Pedro');
    });
  });

  group('ClientHiveAdapter.getByDocumentId', () {
    test('should return null when documentId is not found', () async {
      // Arrange – empty box

      // Act
      final result = await adapter.getByDocumentId('000');

      // Assert
      expect(result, isNull);
    });

    test('should return client with matching documentId', () async {
      // Arrange
      const client = Client(
        id: 'c-3',
        fullName: 'Maria',
        documentId: '333',
        email: 'm@m.com',
        phone: '302',
      );
      await adapter.save(client);

      // Act
      final result = await adapter.getByDocumentId('333');

      // Assert
      expect(result?.id, 'c-3');
    });
  });

  group('ClientHiveAdapter.delete', () {
    test('should remove client from box', () async {
      // Arrange
      const client = Client(
        id: 'c-4',
        fullName: 'Luis',
        documentId: '444',
        email: 'l@l.com',
        phone: '303',
      );
      await adapter.save(client);

      // Act
      await adapter.delete('c-4');

      // Assert
      final result = await adapter.getById('c-4');
      expect(result, isNull);
    });
  });
}
