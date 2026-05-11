import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/domain/models/friend/friend.dart';
import 'package:valora_code/domain/models/friend/gateway/friend_gateway.dart';
import 'package:valora_code/domain/usecase/friend/get_friend_by_id_use_case.dart';

class _MockFriendGateway extends Mock implements FriendGateway {}

void main() {
  late _MockFriendGateway mockGateway;
  late GetFriendByIdUseCase useCase;

  setUp(() {
    mockGateway = _MockFriendGateway();
    useCase = GetFriendByIdUseCase(mockGateway);
  });

  group('GetFriendByIdUseCase.execute', () {
    const friend = Friend(
      id: 'f-001',
      fullName: 'María',
      knowledgeAreas: ['Flutter'],
      hourlyRate: 80000,
      currency: 'COP',
    );

    test('should return friend when found', () async {
      // Arrange
      when(() => mockGateway.getById('f-001')).thenAnswer((_) async => friend);

      // Act
      final result = await useCase.execute('f-001');

      // Assert
      expect(result, equals(friend));
    });

    test('should return null when friend not found', () async {
      // Arrange
      when(
        () => mockGateway.getById('not-found'),
      ).thenAnswer((_) async => null);

      // Act
      final result = await useCase.execute('not-found');

      // Assert
      expect(result, isNull);
    });
  });
}
