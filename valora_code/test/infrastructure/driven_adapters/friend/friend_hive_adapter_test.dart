import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:valora_code/domain/models/friend/friend.dart';
import 'package:valora_code/infrastructure/driven_adapters/friend/friend_hive_adapter.dart';

void main() {
  late Box<Map> box;
  late FriendHiveAdapter adapter;

  setUp(() async {
    Hive.init(null);
    box = await Hive.openBox<Map>('friends');
    adapter = FriendHiveAdapter();
  });

  tearDown(() async {
    await box.clear();
    await box.close();
  });

  const friend1 = Friend(
    id: 'f-1',
    fullName: 'María Gómez',
    knowledgeAreas: ['Flutter', 'Dart'],
    hourlyRate: 80000,
    currency: 'COP',
  );

  const friend2 = Friend(
    id: 'f-2',
    fullName: 'Pedro López',
    knowledgeAreas: ['React'],
    hourlyRate: 50,
    currency: 'USD',
  );

  group('FriendHiveAdapter.getAll', () {
    test('should return empty list when box is empty', () async {
      final result = await adapter.getAll();
      expect(result, isEmpty);
    });

    test('should return all saved friends', () async {
      await adapter.save(friend1);
      await adapter.save(friend2);

      final result = await adapter.getAll();

      expect(result.length, 2);
      expect(result.map((f) => f.id), containsAll(['f-1', 'f-2']));
    });
  });

  group('FriendHiveAdapter.getById', () {
    test('should return null when friend does not exist', () async {
      final result = await adapter.getById('nonexistent');
      expect(result, isNull);
    });

    test('should return friend with matching id', () async {
      await adapter.save(friend1);

      final result = await adapter.getById('f-1');

      expect(result?.fullName, 'María Gómez');
      expect(result?.currency, 'COP');
    });
  });

  group('FriendHiveAdapter.save', () {
    test('should persist friend correctly', () async {
      await adapter.save(friend1);

      final result = await adapter.getById('f-1');

      expect(result?.id, 'f-1');
      expect(result?.knowledgeAreas, ['Flutter', 'Dart']);
      expect(result?.hourlyRate, 80000.0);
    });

    test('should overwrite friend when same id', () async {
      await adapter.save(friend1);
      final updated = friend1.copyWith(fullName: 'María Actualizada');
      await adapter.save(updated);

      final result = await adapter.getById('f-1');

      expect(result?.fullName, 'María Actualizada');
    });

    test('should persist null imageBase64 correctly', () async {
      await adapter.save(friend1);

      final result = await adapter.getById('f-1');

      expect(result?.imageBase64, isNull);
    });
  });

  group('FriendHiveAdapter.delete', () {
    test('should remove friend from box', () async {
      await adapter.save(friend1);
      await adapter.delete('f-1');

      final result = await adapter.getById('f-1');

      expect(result, isNull);
    });

    test('should not throw when deleting nonexistent id', () async {
      expect(() => adapter.delete('nonexistent'), returnsNormally);
    });
  });
}
