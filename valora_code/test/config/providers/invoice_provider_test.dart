import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/domain/models/client/client.dart';
import 'package:valora_code/domain/models/invoice/invoice.dart';
import 'package:valora_code/domain/models/invoice/invoice_exception.dart';
import 'package:valora_code/domain/models/invoice/invoice_line.dart';
import 'package:valora_code/domain/models/invoice/issuer_snapshot.dart';
import 'package:valora_code/domain/models/invoice/client_snapshot.dart';
import 'package:valora_code/domain/usecase/invoice/create_invoice_use_case.dart';
import 'package:valora_code/domain/usecase/invoice/get_all_invoices_use_case.dart';
import 'package:valora_code/domain/usecase/invoice/get_invoice_by_id_use_case.dart';
import 'package:valora_code/config/providers/invoice_provider.dart';

class _MockCreateInvoice extends Mock implements CreateInvoiceUseCase {}

class _MockGetAllInvoices extends Mock implements GetAllInvoicesUseCase {}

class _MockGetInvoiceById extends Mock implements GetInvoiceByIdUseCase {}

Invoice _buildInvoice(String id) => Invoice(
  id: id,
  invoiceNumber: 'CC-0001',
  issuerSnapshot: const IssuerSnapshot(
    businessName: 'Emp',
    nit: '1',
    address: 'Dir',
    invoicePrefix: 'CC',
  ),
  clientSnapshot: const ClientSnapshot(
    clientId: 'cli-1',
    fullName: 'Cliente',
    documentId: '111',
    email: 'c@c.com',
    phone: '300',
  ),
  createdAt: DateTime(2024),
  lines: const [
    InvoiceLine(
      productItemId: 'i1',
      itemName: 'X',
      unitPrice: 1000,
      quantity: 1,
    ),
  ],
);

const testClient = Client(
  id: 'cli-1',
  fullName: 'Cliente',
  documentId: '111',
  email: 'c@c.com',
  phone: '300',
);

void main() {
  late _MockCreateInvoice mockCreate;
  late _MockGetAllInvoices mockGetAll;
  late _MockGetInvoiceById mockGetById;

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
    registerFallbackValue(
      const InvoiceLine(
        productItemId: 'fb',
        itemName: 'FB',
        unitPrice: 0,
        quantity: 1,
      ),
    );
  });

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        invoiceProvider.overrideWith(
          (_) => InvoiceNotifier(mockCreate, mockGetAll, mockGetById),
        ),
      ],
    );
  }

  setUp(() {
    mockCreate = _MockCreateInvoice();
    mockGetAll = _MockGetAllInvoices();
    mockGetById = _MockGetInvoiceById();
  });

  group('InvoiceNotifier.load', () {
    test('should populate invoices on successful load', () async {
      // Arrange
      when(
        () => mockGetAll.execute(),
      ).thenAnswer((_) async => [_buildInvoice('inv-1')]);
      final container = makeContainer();

      // Act
      await container.read(invoiceProvider.notifier).load();

      // Assert
      final state = container.read(invoiceProvider);
      expect(state.invoices.length, 1);
      expect(state.isLoading, isFalse);
      container.dispose();
    });
  });

  group('InvoiceNotifier.addLine / removeLine', () {
    test('should add a line to draftLines', () async {
      // Arrange
      when(() => mockGetAll.execute()).thenAnswer((_) async => []);
      final container = makeContainer();
      // wait for initial load
      await container.read(invoiceProvider.notifier).load();

      const line = InvoiceLine(
        productItemId: 'i1',
        itemName: 'Servicio',
        unitPrice: 50000,
        quantity: 2,
      );

      // Act
      container.read(invoiceProvider.notifier).addLine(line);

      // Assert
      expect(container.read(invoiceProvider).draftLines.length, 1);
      container.dispose();
    });

    test('should remove a line at given index', () async {
      // Arrange
      when(() => mockGetAll.execute()).thenAnswer((_) async => []);
      final container = makeContainer();
      await container.read(invoiceProvider.notifier).load();

      const line = InvoiceLine(
        productItemId: 'i1',
        itemName: 'X',
        unitPrice: 1000,
        quantity: 1,
      );
      container.read(invoiceProvider.notifier).addLine(line);

      // Act
      container.read(invoiceProvider.notifier).removeLine(0);

      // Assert
      expect(container.read(invoiceProvider).draftLines, isEmpty);
      container.dispose();
    });
  });

  group('InvoiceNotifier.createInvoice', () {
    test('should clear draft and reload after successful creation', () async {
      // Arrange
      when(
        () => mockGetAll.execute(),
      ).thenAnswer((_) async => [_buildInvoice('inv-1')]);
      when(
        () => mockCreate.execute(
          client: any(named: 'client'),
          lines: any(named: 'lines'),
        ),
      ).thenAnswer((_) async => _buildInvoice('new-inv'));
      final container = makeContainer();
      await container.read(invoiceProvider.notifier).load();
      container
          .read(invoiceProvider.notifier)
          .addLine(
            const InvoiceLine(
              productItemId: 'i1',
              itemName: 'X',
              unitPrice: 1000,
              quantity: 1,
            ),
          );

      // Act
      await container.read(invoiceProvider.notifier).createInvoice(testClient);

      // Assert
      final state = container.read(invoiceProvider);
      expect(state.draftLines, isEmpty);
      expect(state.error, isNull);
      container.dispose();
    });

    test('should set error when createInvoice throws', () async {
      // Arrange
      when(() => mockGetAll.execute()).thenAnswer((_) async => []);
      when(
        () => mockCreate.execute(
          client: any(named: 'client'),
          lines: any(named: 'lines'),
        ),
      ).thenThrow(const InvoiceException('Sin líneas'));
      final container = makeContainer();
      await container.read(invoiceProvider.notifier).load();

      // Act
      await container.read(invoiceProvider.notifier).createInvoice(testClient);

      // Assert
      expect(container.read(invoiceProvider).error, isNotNull);
      container.dispose();
    });
  });
}
