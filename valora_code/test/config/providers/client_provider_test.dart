import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/domain/models/client/client.dart';
import 'package:valora_code/domain/models/client/client_exception.dart';
import 'package:valora_code/domain/usecase/client/get_all_clients_use_case.dart';
import 'package:valora_code/domain/usecase/client/get_client_by_id_use_case.dart';
import 'package:valora_code/domain/usecase/client/save_client_use_case.dart';
import 'package:valora_code/config/providers/client_provider.dart';

class _MockGetAllClients extends Mock implements GetAllClientsUseCase {}

class _MockGetClientById extends Mock implements GetClientByIdUseCase {}

class _MockSaveClient extends Mock implements SaveClientUseCase {}

void main() {
  late _MockGetAllClients mockGetAll;
  late _MockGetClientById mockGetById;
  late _MockSaveClient mockSave;

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

  const clients = [
    Client(
      id: 'c-1',
      fullName: 'Ana',
      documentId: '111',
      email: 'a@a.com',
      phone: '300',
    ),
  ];

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        clientProvider.overrideWith(
          (_) => ClientNotifier(mockGetAll, mockGetById, mockSave),
        ),
      ],
    );
  }

  setUp(() {
    mockGetAll = _MockGetAllClients();
    mockGetById = _MockGetClientById();
    mockSave = _MockSaveClient();
  });

  group('ClientNotifier.load', () {
    test('should populate clients on successful load', () async {
      // Arrange
      when(() => mockGetAll.execute()).thenAnswer((_) async => clients);
      final container = makeContainer();

      // Act
      await container.read(clientProvider.notifier).load();

      // Assert
      final state = container.read(clientProvider);
      expect(state.clients.length, 1);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      container.dispose();
    });

    test('should set error state when load fails', () async {
      // Arrange
      when(() => mockGetAll.execute()).thenThrow(Exception('Fallo de carga'));
      final container = makeContainer();

      // Act
      await container.read(clientProvider.notifier).load();

      // Assert
      final state = container.read(clientProvider);
      expect(state.error, isNotNull);
      expect(state.isLoading, isFalse);
      container.dispose();
    });
  });

  group('ClientNotifier.save', () {
    test('should reload clients after successful save', () async {
      // Arrange
      when(() => mockGetAll.execute()).thenAnswer((_) async => clients);
      when(() => mockSave.execute(any())).thenAnswer((_) async {});
      final container = makeContainer();

      // Act
      await container.read(clientProvider.notifier).save(clients.first);

      // Assert
      verify(() => mockSave.execute(any())).called(1);
      verify(() => mockGetAll.execute()).called(greaterThan(0));
      container.dispose();
    });

    test('should set error when save throws ClientException', () async {
      // Arrange
      when(() => mockGetAll.execute()).thenAnswer((_) async => []);
      when(
        () => mockSave.execute(any()),
      ).thenThrow(const ClientException('Duplicado'));
      final container = makeContainer();

      // Act
      await container.read(clientProvider.notifier).save(clients.first);

      // Assert
      final state = container.read(clientProvider);
      expect(state.error, isNotNull);
      container.dispose();
    });
  });
}
