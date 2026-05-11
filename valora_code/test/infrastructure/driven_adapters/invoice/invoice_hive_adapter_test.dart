import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:valora_code/domain/models/invoice/invoice.dart';
import 'package:valora_code/domain/models/invoice/invoice_line.dart';
import 'package:valora_code/domain/models/invoice/issuer_snapshot.dart';
import 'package:valora_code/domain/models/invoice/client_snapshot.dart';
import 'package:valora_code/infrastructure/driven_adapters/invoice/invoice_hive_adapter.dart';

Invoice _buildInvoice(String id, String number) {
  return Invoice(
    id: id,
    invoiceNumber: number,
    issuerSnapshot: const IssuerSnapshot(
      businessName: 'Empresa',
      nit: '900-1',
      address: 'Calle',
      invoicePrefix: 'CC',
    ),
    clientSnapshot: const ClientSnapshot(
      clientId: 'cli-1',
      fullName: 'Cliente',
      documentId: '111',
      email: 'c@c.com',
      phone: '300',
    ),
    createdAt: DateTime(2024, 1, 1),
    lines: const [
      InvoiceLine(
        productItemId: 'item-1',
        itemName: 'Consultoría',
        unitPrice: 100000,
        quantity: 1,
      ),
    ],
  );
}

void main() {
  late Box<Map> box;
  late InvoiceHiveAdapter adapter;

  setUp(() async {
    Hive.init(null);
    box = await Hive.openBox<Map>('invoices');
    adapter = InvoiceHiveAdapter();
  });

  tearDown(() async {
    await box.clear();
    await box.close();
  });

  group('InvoiceHiveAdapter.getAll', () {
    test('should return empty list when no invoices saved', () async {
      // Arrange – empty box

      // Act
      final result = await adapter.getAll();

      // Assert
      expect(result, isEmpty);
    });

    test('should return saved invoices', () async {
      // Arrange
      final invoice = _buildInvoice('inv-1', 'CC-0001');
      await adapter.save(invoice);

      // Act
      final result = await adapter.getAll();

      // Assert
      expect(result.length, 1);
      expect(result.first.invoiceNumber, 'CC-0001');
    });
  });

  group('InvoiceHiveAdapter.getById', () {
    test('should return null when invoice does not exist', () async {
      // Arrange – empty box

      // Act
      final result = await adapter.getById('nonexistent');

      // Assert
      expect(result, isNull);
    });

    test('should return invoice with matching id', () async {
      // Arrange
      final invoice = _buildInvoice('inv-2', 'CC-0002');
      await adapter.save(invoice);

      // Act
      final result = await adapter.getById('inv-2');

      // Assert
      expect(result?.invoiceNumber, 'CC-0002');
      expect(result?.total, 100000.0);
    });
  });

  group('InvoiceHiveAdapter.save', () {
    test('should persist invoice and it can be retrieved', () async {
      // Arrange
      final invoice = _buildInvoice('inv-3', 'CC-0003');

      // Act
      await adapter.save(invoice);

      // Assert
      final retrieved = await adapter.getById('inv-3');
      expect(retrieved?.clientSnapshot.fullName, 'Cliente');
      expect(retrieved?.issuerSnapshot.businessName, 'Empresa');
    });
  });
}
