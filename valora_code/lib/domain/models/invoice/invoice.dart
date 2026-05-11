import 'invoice_line.dart';
import 'issuer_snapshot.dart';
import 'client_snapshot.dart';

class Invoice {
  final String id;
  final String invoiceNumber;
  final IssuerSnapshot issuerSnapshot;
  final ClientSnapshot clientSnapshot;
  final DateTime createdAt;
  final List<InvoiceLine> lines;

  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.issuerSnapshot,
    required this.clientSnapshot,
    required this.createdAt,
    required this.lines,
  });

  double get total => lines.fold(0.0, (sum, l) => sum + l.subtotal);
}
