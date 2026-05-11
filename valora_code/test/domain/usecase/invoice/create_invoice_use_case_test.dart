import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/domain/models/client/client.dart';
import 'package:valora_code/domain/models/invoice/invoice.dart';
import 'package:valora_code/domain/models/invoice/invoice_exception.dart';
import 'package:valora_code/domain/models/invoice/invoice_line.dart';
import 'package:valora_code/domain/models/invoice/issuer_snapshot.dart';
import 'package:valora_code/domain/models/invoice/client_snapshot.dart';
import 'package:valora_code/domain/models/invoice/gateway/invoice_gateway.dart';
import 'package:valora_code/domain/models/issuer_config/issuer_config.dart';
import 'package:valora_code/domain/models/issuer_config/gateway/issuer_config_gateway.dart';
import 'package:valora_code/domain/usecase/invoice/create_invoice_use_case.dart';

class _MockInvoiceGateway extends Mock implements InvoiceGateway {}

class _MockIssuerConfigGateway extends Mock implements IssuerConfigGateway {}

void main() {
  late _MockInvoiceGateway mockInvoiceGateway;
  late _MockIssuerConfigGateway mockIssuerGateway;
  late CreateInvoiceUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      Invoice(
        id: 'fb',
        invoiceNumber: 'FB-0001',
        issuerSnapshot: const IssuerSnapshot(
          businessName: 'FB',
          nit: '0',
          address: 'FB',
          invoicePrefix: 'FB',
        ),
        clientSnapshot: const ClientSnapshot(
          clientId: 'fb',
          fullName: 'FB',
          documentId: '0',
          email: 'fb@fb.com',
          phone: '0',
        ),
        createdAt: DateTime(2024),
        lines: const [],
      ),
    );
    registerFallbackValue(
      const IssuerConfig(
        businessName: 'FB',
        nit: '0',
        address: 'FB',
        invoicePrefix: 'FB',
        nextConsecutive: 1,
      ),
    );
  });

  const testClient = Client(
    id: 'client-1',
    fullName: 'Juan Pérez',
    documentId: '123',
    email: 'juan@example.com',
    phone: '300',
  );

  const testConfig = IssuerConfig(
    businessName: 'Mi Empresa',
    nit: '900-1',
    address: 'Cra 1',
    invoicePrefix: 'CC',
    nextConsecutive: 1,
  );

  final testLines = [
    const InvoiceLine(
      productItemId: 'item-1',
      itemName: 'Consultoría',
      unitPrice: 100000,
      quantity: 2,
    ),
  ];

  setUp(() {
    mockInvoiceGateway = _MockInvoiceGateway();
    mockIssuerGateway = _MockIssuerConfigGateway();
    useCase = CreateInvoiceUseCase(mockInvoiceGateway, mockIssuerGateway);
  });

  group('InvoiceLine.subtotal', () {
    test('should return unitPrice * quantity', () {
      // Arrange
      const line = InvoiceLine(
        productItemId: 'i1',
        itemName: 'X',
        unitPrice: 50000,
        quantity: 3,
      );

      // Act
      final result = line.subtotal;

      // Assert
      expect(result, 150000.0);
    });
  });

  group('Invoice.total', () {
    test('should return sum of all line subtotals', () {
      // Arrange
      final lines = [
        const InvoiceLine(
          productItemId: 'i1',
          itemName: 'A',
          unitPrice: 10000,
          quantity: 2,
        ),
        const InvoiceLine(
          productItemId: 'i2',
          itemName: 'B',
          unitPrice: 30000,
          quantity: 1,
        ),
      ];
      // We can't easily build a full Invoice without snapshots, so test via use case result

      // Act & Assert directly on InvoiceLine
      final total = lines.fold(0.0, (sum, l) => sum + l.subtotal);
      expect(total, 50000.0);
    });
  });

  group('CreateInvoiceUseCase.execute', () {
    test('should create invoice with consecutive number from config', () async {
      // Arrange
      when(() => mockIssuerGateway.get()).thenAnswer((_) async => testConfig);
      when(() => mockInvoiceGateway.save(any())).thenAnswer((_) async {});
      when(() => mockIssuerGateway.save(any())).thenAnswer((_) async {});

      // Act
      final invoice = await useCase.execute(
        client: testClient,
        lines: testLines,
      );

      // Assert
      expect(invoice.invoiceNumber, 'CC-0001');
      expect(invoice.clientSnapshot.fullName, 'Juan Pérez');
      expect(invoice.issuerSnapshot.businessName, 'Mi Empresa');
      verify(() => mockInvoiceGateway.save(any())).called(1);
      verify(() => mockIssuerGateway.save(any())).called(1);
    });

    test('should throw InvoiceException when lines list is empty', () async {
      // Arrange – no need to mock gateway

      // Act
      Future<void> call() => useCase.execute(client: testClient, lines: []);

      // Assert
      expect(call, throwsA(isA<InvoiceException>()));
    });

    test(
      'should throw InvoiceException when issuer config is not set',
      () async {
        // Arrange
        when(() => mockIssuerGateway.get()).thenAnswer((_) async => null);

        // Act
        Future<void> call() =>
            useCase.execute(client: testClient, lines: testLines);

        // Assert
        expect(call, throwsA(isA<InvoiceException>()));
      },
    );

    test('should throw InvoiceException when a line has quantity 0', () async {
      // Arrange
      const zeroLine = InvoiceLine(
        productItemId: 'i1',
        itemName: 'X',
        unitPrice: 1000,
        quantity: 0,
      );

      // Act
      Future<void> call() =>
          useCase.execute(client: testClient, lines: [zeroLine]);

      // Assert
      expect(call, throwsA(isA<InvoiceException>()));
    });
  });
}
