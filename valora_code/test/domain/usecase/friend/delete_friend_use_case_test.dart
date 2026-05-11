import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/domain/models/friend/gateway/friend_gateway.dart';
import 'package:valora_code/domain/usecase/friend/delete_friend_use_case.dart';

class _MockFriendGateway extends Mock implements FriendGateway {}

void main() {
  late _MockFriendGateway mockGateway;
  late DeleteFriendUseCase useCase;

  setUp(() {
    mockGateway = _MockFriendGateway();
    useCase = DeleteFriendUseCase(mockGateway);
  });

  group('DeleteFriendUseCase.execute', () {
    test('should delegate delete to gateway', () async {
      // Arrange
      when(() => mockGateway.delete('f-001')).thenAnswer((_) async {});

      // Act
      await useCase.execute('f-001');

      // Assert
      verify(() => mockGateway.delete('f-001')).called(1);
    });

    test('should pass correct id to gateway', () async {
      // Arrange
      when(() => mockGateway.delete(any())).thenAnswer((_) async {});

      // Act
      await useCase.execute('some-uuid-123');

      // Assert
      verify(() => mockGateway.delete('some-uuid-123')).called(1);
    });
  });
}
