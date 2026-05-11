import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/domain/models/friend/friend.dart';
import 'package:valora_code/domain/models/friend/gateway/friend_gateway.dart';
import 'package:valora_code/domain/usecase/friend/get_all_friends_use_case.dart';

class _MockFriendGateway extends Mock implements FriendGateway {}

void main() {
  late _MockFriendGateway mockGateway;
  late GetAllFriendsUseCase useCase;

  setUp(() {
    mockGateway = _MockFriendGateway();
    useCase = GetAllFriendsUseCase(mockGateway);
  });

  group('GetAllFriendsUseCase.execute', () {
    test('should return empty list when no friends exist', () async {
      // Arrange
      when(() => mockGateway.getAll()).thenAnswer((_) async => []);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isEmpty);
      verify(() => mockGateway.getAll()).called(1);
    });

    test('should return all friends from gateway', () async {
      // Arrange
      const friends = [
        Friend(
          id: 'f-001',
          fullName: 'María',
          knowledgeAreas: ['Flutter'],
          hourlyRate: 80000,
          currency: 'COP',
        ),
        Friend(
          id: 'f-002',
          fullName: 'Pedro',
          knowledgeAreas: [],
          hourlyRate: 50,
          currency: 'USD',
        ),
      ];
      when(() => mockGateway.getAll()).thenAnswer((_) async => friends);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, equals(friends));
      expect(result.length, 2);
    });
  });
}
