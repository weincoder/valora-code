import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/domain/models/friend/friend.dart';
import 'package:valora_code/domain/models/friend/friend_exception.dart';
import 'package:valora_code/domain/usecase/friend/delete_friend_use_case.dart';
import 'package:valora_code/domain/usecase/friend/get_all_friends_use_case.dart';
import 'package:valora_code/domain/usecase/friend/get_friend_by_id_use_case.dart';
import 'package:valora_code/domain/usecase/friend/save_friend_use_case.dart';
import 'package:valora_code/config/providers/friend_provider.dart';

class _MockGetAll extends Mock implements GetAllFriendsUseCase {}

class _MockGetById extends Mock implements GetFriendByIdUseCase {}

class _MockSave extends Mock implements SaveFriendUseCase {}

class _MockDelete extends Mock implements DeleteFriendUseCase {}

void main() {
  late _MockGetAll mockGetAll;
  late _MockGetById mockGetById;
  late _MockSave mockSave;
  late _MockDelete mockDelete;

  setUpAll(() {
    registerFallbackValue(
      const Friend(
        id: 'fb',
        fullName: 'FB',
        knowledgeAreas: [],
        hourlyRate: 0,
        currency: 'COP',
      ),
    );
  });

  const friends = [
    Friend(
      id: 'f-1',
      fullName: 'María',
      knowledgeAreas: ['Flutter'],
      hourlyRate: 80000,
      currency: 'COP',
    ),
  ];

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        friendProvider.overrideWith(
          (_) => FriendNotifier(mockGetAll, mockGetById, mockSave, mockDelete),
        ),
      ],
    );
  }

  setUp(() {
    mockGetAll = _MockGetAll();
    mockGetById = _MockGetById();
    mockSave = _MockSave();
    mockDelete = _MockDelete();
  });

  group('FriendNotifier.load', () {
    test('should populate friends on successful load', () async {
      // Arrange
      when(() => mockGetAll.execute()).thenAnswer((_) async => friends);
      final container = makeContainer();

      // Act
      await container.read(friendProvider.notifier).load();

      // Assert
      final state = container.read(friendProvider);
      expect(state.friends.length, 1);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      container.dispose();
    });

    test('should set error state when load fails', () async {
      // Arrange
      when(() => mockGetAll.execute()).thenThrow(Exception('DB error'));
      final container = makeContainer();

      // Act
      await container.read(friendProvider.notifier).load();

      // Assert
      final state = container.read(friendProvider);
      expect(state.error, isNotNull);
      expect(state.isLoading, isFalse);
      container.dispose();
    });
  });

  group('FriendNotifier.save', () {
    test('should reload friends after successful save', () async {
      // Arrange
      when(() => mockSave.execute(any())).thenAnswer((_) async {});
      when(() => mockGetAll.execute()).thenAnswer((_) async => friends);
      final container = makeContainer();

      // Act
      await container.read(friendProvider.notifier).save(friends.first);

      // Assert
      verify(() => mockSave.execute(friends.first)).called(1);
      container.dispose();
    });

    test('should set error state when save throws FriendException', () async {
      // Arrange
      when(
        () => mockSave.execute(any()),
      ).thenThrow(const FriendException('El nombre es requerido'));
      when(() => mockGetAll.execute()).thenAnswer((_) async => []);
      final container = makeContainer();

      // Act
      await container.read(friendProvider.notifier).save(friends.first);

      // Assert
      final state = container.read(friendProvider);
      expect(state.error, isNotNull);
      container.dispose();
    });
  });

  group('FriendNotifier.delete', () {
    test('should reload friends after successful delete', () async {
      // Arrange
      when(() => mockDelete.execute('f-1')).thenAnswer((_) async {});
      when(() => mockGetAll.execute()).thenAnswer((_) async => []);
      final container = makeContainer();

      // Act
      await container.read(friendProvider.notifier).delete('f-1');

      // Assert
      verify(() => mockDelete.execute('f-1')).called(1);
      container.dispose();
    });
  });

  group('FriendNotifier.generateId', () {
    test('should return non-empty UUID', () async {
      when(() => mockGetAll.execute()).thenAnswer((_) async => []);
      final container = makeContainer();
      await container.read(friendProvider.notifier).load();

      final id = container.read(friendProvider.notifier).generateId();

      expect(id, isNotEmpty);
      expect(id.length, 36);
      container.dispose();
    });
  });
}
