import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/config/providers/sale_record_provider.dart';
import 'package:valora_code/domain/models/sale_record/sale_record.dart';
import 'package:valora_code/domain/models/sale_record/gateway/sale_record_gateway.dart';
import 'package:valora_code/domain/usecase/sale_record/get_all_sale_records_use_case.dart';
import 'package:valora_code/domain/usecase/sale_record/save_sale_record_use_case.dart';
import 'package:valora_code/domain/usecase/sale_record/delete_sale_record_use_case.dart';

class MockSaleRecordGateway extends Mock implements SaleRecordGateway {}

final _sampleRecord = SaleRecord(
  id: 'sale-test-1',
  productItemId: 'prod-1',
  productTitle: 'App web',
  quantity: 1,
  unitPrice: 1200.0,
  totalAmount: 1200.0,
  date: DateTime(2025, 6, 1),
);

SaleRecordNotifier _makeNotifier(MockSaleRecordGateway gateway) {
  return SaleRecordNotifier(
    getAll: GetAllSaleRecordsUseCase(gateway: gateway),
    save: SaveSaleRecordUseCase(gateway: gateway),
    delete: DeleteSaleRecordUseCase(gateway: gateway),
  );
}

void main() {
  late MockSaleRecordGateway mockGateway;

  setUpAll(() {
    registerFallbackValue(_sampleRecord);
  });

  setUp(() {
    mockGateway = MockSaleRecordGateway();
  });

  group('SaleRecordNotifier.load', () {
    test('should emit records from gateway after load', () async {
      // Arrange
      when(() => mockGateway.getAll()).thenAnswer((_) async => [_sampleRecord]);
      final container = ProviderContainer(
        overrides: [
          saleRecordProvider.overrideWith((_) => _makeNotifier(mockGateway)),
        ],
      );
      addTearDown(container.dispose);

      // Act
      await container.read(saleRecordProvider.notifier).load();

      // Assert
      final state = container.read(saleRecordProvider);
      expect(state.records, hasLength(1));
      expect(state.records.first.id, equals('sale-test-1'));
      expect(state.isLoading, isFalse);
    });

    test('should set error when gateway throws', () async {
      // Arrange
      when(() => mockGateway.getAll()).thenThrow(Exception('DB fail'));
      final container = ProviderContainer(
        overrides: [
          saleRecordProvider.overrideWith((_) => _makeNotifier(mockGateway)),
        ],
      );
      addTearDown(container.dispose);

      // Act
      await container.read(saleRecordProvider.notifier).load();

      // Assert
      final state = container.read(saleRecordProvider);
      expect(state.error, isNotNull);
      expect(state.records, isEmpty);
    });
  });

  group('SaleRecordNotifier.delete', () {
    test('should call gateway.delete and reload', () async {
      // Arrange
      when(() => mockGateway.delete(any())).thenAnswer((_) async {});
      when(() => mockGateway.getAll()).thenAnswer((_) async => []);
      final container = ProviderContainer(
        overrides: [
          saleRecordProvider.overrideWith((_) => _makeNotifier(mockGateway)),
        ],
      );
      addTearDown(container.dispose);

      // Act
      await container.read(saleRecordProvider.notifier).delete('sale-test-1');

      // Assert
      verify(() => mockGateway.delete('sale-test-1')).called(1);
    });
  });
}
