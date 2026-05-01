import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/domain/models/sale_record/sale_record.dart';
import 'package:valora_code/domain/models/sale_record/gateway/sale_record_gateway.dart';
import 'package:valora_code/domain/usecase/sale_record/get_all_sale_records_use_case.dart';
import 'package:valora_code/domain/usecase/sale_record/save_sale_record_use_case.dart';
import 'package:valora_code/domain/usecase/sale_record/delete_sale_record_use_case.dart';

class MockSaleRecordGateway extends Mock implements SaleRecordGateway {}

final _sampleRecord = SaleRecord(
  id: 'sale-abc',
  productItemId: 'prod-1',
  productTitle: 'Diseño web',
  quantity: 1,
  unitPrice: 800.0,
  totalAmount: 800.0,
  date: DateTime(2025, 4, 20),
);

void main() {
  late MockSaleRecordGateway mockGateway;

  setUpAll(() {
    registerFallbackValue(_sampleRecord);
  });

  setUp(() {
    mockGateway = MockSaleRecordGateway();
  });

  group('GetAllSaleRecordsUseCase.execute', () {
    test('should return list of records from gateway', () async {
      // Arrange
      when(() => mockGateway.getAll()).thenAnswer((_) async => [_sampleRecord]);
      final useCase = GetAllSaleRecordsUseCase(gateway: mockGateway);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, hasLength(1));
      expect(result.first.id, equals('sale-abc'));
      verify(() => mockGateway.getAll()).called(1);
    });

    test('should return empty list when gateway returns nothing', () async {
      // Arrange
      when(() => mockGateway.getAll()).thenAnswer((_) async => []);
      final useCase = GetAllSaleRecordsUseCase(gateway: mockGateway);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isEmpty);
    });
  });

  group('SaveSaleRecordUseCase.execute', () {
    test('should call gateway.save with the given record', () async {
      // Arrange
      when(() => mockGateway.save(any())).thenAnswer((_) async {});
      final useCase = SaveSaleRecordUseCase(gateway: mockGateway);

      // Act
      await useCase.execute(_sampleRecord);

      // Assert
      verify(() => mockGateway.save(_sampleRecord)).called(1);
    });

    test('should propagate exception from gateway', () async {
      // Arrange
      when(() => mockGateway.save(any())).thenThrow(Exception('DB error'));
      final useCase = SaveSaleRecordUseCase(gateway: mockGateway);

      // Act & Assert
      await expectLater(
        () => useCase.execute(_sampleRecord),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('DeleteSaleRecordUseCase.execute', () {
    test('should call gateway.delete with the given id', () async {
      // Arrange
      when(() => mockGateway.delete(any())).thenAnswer((_) async {});
      final useCase = DeleteSaleRecordUseCase(gateway: mockGateway);

      // Act
      await useCase.execute('sale-abc');

      // Assert
      verify(() => mockGateway.delete('sale-abc')).called(1);
    });
  });
}
