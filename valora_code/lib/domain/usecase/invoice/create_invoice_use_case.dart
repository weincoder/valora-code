import 'package:uuid/uuid.dart';
import '../../models/client/client.dart';
import '../../models/invoice/invoice.dart';
import '../../models/invoice/invoice_exception.dart';
import '../../models/invoice/invoice_line.dart';
import '../../models/invoice/issuer_snapshot.dart';
import '../../models/invoice/client_snapshot.dart';
import '../../models/invoice/gateway/invoice_gateway.dart';
import '../../models/issuer_config/gateway/issuer_config_gateway.dart';

class CreateInvoiceUseCase {
  final InvoiceGateway _invoiceGateway;
  final IssuerConfigGateway _issuerConfigGateway;

  CreateInvoiceUseCase(this._invoiceGateway, this._issuerConfigGateway);

  /// [lines] should contain draft lines from the UI state.
  /// [client] is the selected client.
  Future<Invoice> execute({
    required Client client,
    required List<InvoiceLine> lines,
  }) async {
    if (lines.isEmpty) {
      throw const InvoiceException(
        'La cuenta de cobro debe tener al menos una línea',
      );
    }
    for (final line in lines) {
      if (line.quantity <= 0) {
        throw const InvoiceException(
          'La cantidad de cada línea debe ser mayor a cero',
        );
      }
    }

    final config = await _issuerConfigGateway.get();
    if (config == null) {
      throw const InvoiceException(
        'Debe configurar los datos del emisor antes de crear una cuenta',
      );
    }

    final invoiceNumber = config.formattedNextNumber;

    final issuerSnapshot = IssuerSnapshot(
      businessName: config.businessName,
      nit: config.nit,
      address: config.address,
      invoicePrefix: config.invoicePrefix,
    );

    final clientSnapshot = ClientSnapshot(
      clientId: client.id,
      fullName: client.fullName,
      documentId: client.documentId,
      email: client.email,
      phone: client.phone,
      imageBase64: client.imageBase64,
    );

    final invoice = Invoice(
      id: const Uuid().v4(),
      invoiceNumber: invoiceNumber,
      issuerSnapshot: issuerSnapshot,
      clientSnapshot: clientSnapshot,
      createdAt: DateTime.now(),
      lines: List.unmodifiable(lines),
    );

    await _invoiceGateway.save(invoice);

    // Increment consecutive — accepted risk for single-user offline app (A-001, A-008).
    await _issuerConfigGateway.save(
      config.copyWith(nextConsecutive: config.nextConsecutive + 1),
    );

    return invoice;
  }
}
