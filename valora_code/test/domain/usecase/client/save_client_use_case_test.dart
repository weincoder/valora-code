import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/domain/models/client/client.dart';
import 'package:valora_code/domain/models/client/client_exception.dart';
import 'package:valora_code/domain/models/client/gateway/client_gateway.dart';
import 'package:valora_code/domain/usecase/client/save_client_use_case.dart';

class _MockClientGateway extends Mock implements ClientGateway {}

void main() {
  late _MockClientGateway mockGateway;
  late SaveClientUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      const Client(
        id: 'fb',
        fullName: 'FB',
        documentId: '0',
        email: 'fb@fb.com',
        phone: '0',
      ),
    );
  });

  const validClient = Client(
    id: 'c-001',
    fullName: 'Ana Torres',
    documentId: '123456789',
    email: 'ana@example.com',
    phone: '3001234567',
  );

  setUp(() {
    mockGateway = _MockClientGateway();
    useCase = SaveClientUseCase(mockGateway);
  });

  group('SaveClientUseCase.execute', () {
    test('should save client when all data is valid', () async {
      // Arrange
      when(
        () => mockGateway.getByDocumentId(any()),
      ).thenAnswer((_) async => null);
      when(() => mockGateway.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.execute(validClient);

      // Assert
      verify(() => mockGateway.save(validClient)).called(1);
    });

    test('should throw ClientException when fullName is empty', () async {
      // Arrange
      const client = Client(
        id: 'c-002',
        fullName: '',
        documentId: '111',
        email: 'x@x.com',
        phone: '300',
      );

      // Act
      Future<void> call() => useCase.execute(client);

      // Assert
      expect(call, throwsA(isA<ClientException>()));
    });

    test('should throw ClientException when email format is invalid', () async {
      // Arrange
      const client = Client(
        id: 'c-003',
        fullName: 'Test',
        documentId: '222',
        email: 'not-an-email',
        phone: '300',
      );

      // Act
      Future<void> call() => useCase.execute(client);

      // Assert
      expect(call, throwsA(isA<ClientException>()));
    });

    test('should throw ClientException when documentId is duplicate', () async {
      // Arrange
      const existing = Client(
        id: 'c-other',
        fullName: 'Other',
        documentId: '123456789',
        email: 'other@example.com',
        phone: '300',
      );
      when(
        () => mockGateway.getByDocumentId('123456789'),
      ).thenAnswer((_) async => existing);

      // Act
      Future<void> call() => useCase.execute(validClient);

      // Assert
      expect(call, throwsA(isA<ClientException>()));
    });

    test('should allow updating client with same documentId', () async {
      // Arrange
      when(
        () => mockGateway.getByDocumentId(validClient.documentId),
      ).thenAnswer((_) async => validClient); // same id
      when(() => mockGateway.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.execute(validClient);

      // Assert
      verify(() => mockGateway.save(validClient)).called(1);
    });
  });
}
