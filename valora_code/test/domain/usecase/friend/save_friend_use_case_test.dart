import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/domain/models/friend/friend.dart';
import 'package:valora_code/domain/models/friend/friend_exception.dart';
import 'package:valora_code/domain/models/friend/gateway/friend_gateway.dart';
import 'package:valora_code/domain/usecase/friend/save_friend_use_case.dart';

class _MockFriendGateway extends Mock implements FriendGateway {}

void main() {
  late _MockFriendGateway mockGateway;
  late SaveFriendUseCase useCase;

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

  const validFriend = Friend(
    id: 'f-001',
    fullName: 'María Gómez',
    knowledgeAreas: ['Flutter', 'Dart'],
    hourlyRate: 80000,
    currency: 'COP',
  );

  setUp(() {
    mockGateway = _MockFriendGateway();
    useCase = SaveFriendUseCase(mockGateway);
  });

  group('SaveFriendUseCase.execute', () {
    test('should save friend when all data is valid', () async {
      // Arrange
      when(() => mockGateway.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.execute(validFriend);

      // Assert
      verify(() => mockGateway.save(validFriend)).called(1);
    });

    test('should save friend with empty knowledgeAreas', () async {
      // Arrange
      const friend = Friend(
        id: 'f-002',
        fullName: 'Pedro',
        knowledgeAreas: [],
        hourlyRate: 0,
        currency: 'COP',
      );
      when(() => mockGateway.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.execute(friend);

      // Assert
      verify(() => mockGateway.save(friend)).called(1);
    });

    test('should save friend with USD currency', () async {
      // Arrange
      const friend = Friend(
        id: 'f-003',
        fullName: 'Ana',
        knowledgeAreas: ['React'],
        hourlyRate: 50,
        currency: 'USD',
      );
      when(() => mockGateway.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.execute(friend);

      // Assert
      verify(() => mockGateway.save(friend)).called(1);
    });

    test('should throw FriendException when fullName is blank', () async {
      // Arrange
      const friend = Friend(
        id: 'f-004',
        fullName: '   ',
        knowledgeAreas: [],
        hourlyRate: 1000,
        currency: 'COP',
      );

      // Act
      Future<void> call() => useCase.execute(friend);

      // Assert
      expect(call, throwsA(isA<FriendException>()));
      verifyNever(() => mockGateway.save(any()));
    });

    test('should throw FriendException when hourlyRate is negative', () async {
      // Arrange
      const friend = Friend(
        id: 'f-005',
        fullName: 'Luis',
        knowledgeAreas: [],
        hourlyRate: -1,
        currency: 'COP',
      );

      // Act
      Future<void> call() => useCase.execute(friend);

      // Assert
      expect(call, throwsA(isA<FriendException>()));
      verifyNever(() => mockGateway.save(any()));
    });

    test('should throw FriendException when currency is invalid', () async {
      // Arrange
      const friend = Friend(
        id: 'f-006',
        fullName: 'Carlos',
        knowledgeAreas: [],
        hourlyRate: 1000,
        currency: 'EUR',
      );

      // Act
      Future<void> call() => useCase.execute(friend);

      // Assert
      expect(call, throwsA(isA<FriendException>()));
      verifyNever(() => mockGateway.save(any()));
    });
  });
}
