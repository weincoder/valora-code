import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/config/providers/sale_record_provider.dart';
import 'package:valora_code/domain/models/sale_record/gateway/sale_record_gateway.dart';
import 'package:valora_code/domain/models/sale_record/sale_record.dart';
import 'package:valora_code/domain/usecase/sale_record/delete_sale_record_use_case.dart';
import 'package:valora_code/domain/usecase/sale_record/get_all_sale_records_use_case.dart';
import 'package:valora_code/domain/usecase/sale_record/save_sale_record_use_case.dart';
import 'package:valora_code/ui/pages/sale_record/sale_list_page.dart';

class _MockSaleGateway extends Mock implements SaleRecordGateway {}

final _sampleRecord = SaleRecord(
  id: 'sale-1',
  productItemId: 'prod-1',
  productTitle: 'Desarrollo web',
  quantity: 1,
  unitPrice: 600.0,
  totalAmount: 600.0,
  date: DateTime(2025, 4, 1),
);

Widget _buildApp({List<SaleRecord> records = const []}) {
  final mock = _MockSaleGateway();
  when(() => mock.getAll()).thenAnswer((_) async => records);
  when(() => mock.save(any())).thenAnswer((_) async {});
  when(() => mock.delete(any())).thenAnswer((_) async {});

  return ProviderScope(
    overrides: [
      saleRecordProvider.overrideWith(
        (_) => SaleRecordNotifier(
          getAll: GetAllSaleRecordsUseCase(gateway: mock),
          save: SaveSaleRecordUseCase(gateway: mock),
          delete: DeleteSaleRecordUseCase(gateway: mock),
        ),
      ),
    ],
    child: const MaterialApp(home: SaleListPage()),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_sampleRecord);
  });

  group('Find the page widgets', () {
    testWidgets('should find AppBar with Ventas title', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.text('Ventas'), findsOneWidget);
    });

    testWidgets('should show empty state when no records', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());
      await tester.pump(); // process microtask
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // complete async load

      // Act & Assert
      expect(find.byKey(const Key('sales-empty-text')), findsOneWidget);
    });
  });

  group('Interaction with page widgets', () {
    testWidgets('should show list when records exist', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp(records: [_sampleRecord]));
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byKey(const Key('sales-list')), findsOneWidget);
    });

    testWidgets('should show sale record card with product title', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_buildApp(records: [_sampleRecord]));
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byKey(const Key('sale-record-card-sale-1')), findsOneWidget);
      expect(find.text('Desarrollo web'), findsOneWidget);
    });
  });

  group('Test Page Experience', () {
    testWidgets('should show delete confirmation dialog', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp(records: [_sampleRecord]));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Eliminar venta'), findsOneWidget);
    });

    testWidgets('should dismiss delete dialog on cancel', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp(records: [_sampleRecord]));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Eliminar venta'), findsNothing);
    });
  });
}
