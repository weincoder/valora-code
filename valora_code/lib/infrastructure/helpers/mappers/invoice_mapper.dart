import '../../../domain/models/invoice/invoice.dart';
import '../../../domain/models/invoice/invoice_line.dart';
import '../../../domain/models/invoice/issuer_snapshot.dart';
import '../../../domain/models/invoice/client_snapshot.dart';

Map<String, dynamic> invoiceToJson(Invoice invoice) => {
  'id': invoice.id,
  'invoiceNumber': invoice.invoiceNumber,
  'issuerSnapshot': _issuerSnapshotToJson(invoice.issuerSnapshot),
  'clientSnapshot': _clientSnapshotToJson(invoice.clientSnapshot),
  'createdAt': invoice.createdAt.toIso8601String(),
  'lines': invoice.lines.map(_invoiceLineToJson).toList(),
};

Invoice invoiceFromJson(Map<dynamic, dynamic> json) => Invoice(
  id: json['id'] as String,
  invoiceNumber: json['invoiceNumber'] as String,
  issuerSnapshot: _issuerSnapshotFromJson(json['issuerSnapshot'] as Map),
  clientSnapshot: _clientSnapshotFromJson(json['clientSnapshot'] as Map),
  createdAt: DateTime.parse(json['createdAt'] as String),
  lines: (json['lines'] as List)
      .map((l) => _invoiceLineFromJson(l as Map))
      .toList(),
);

Map<String, dynamic> _issuerSnapshotToJson(IssuerSnapshot s) => {
  'businessName': s.businessName,
  'nit': s.nit,
  'address': s.address,
  'invoicePrefix': s.invoicePrefix,
};

IssuerSnapshot _issuerSnapshotFromJson(Map json) => IssuerSnapshot(
  businessName: json['businessName'] as String,
  nit: json['nit'] as String,
  address: json['address'] as String,
  invoicePrefix: json['invoicePrefix'] as String,
);

Map<String, dynamic> _clientSnapshotToJson(ClientSnapshot s) => {
  'clientId': s.clientId,
  'fullName': s.fullName,
  'documentId': s.documentId,
  'email': s.email,
  'phone': s.phone,
  'imageBase64': s.imageBase64,
};

ClientSnapshot _clientSnapshotFromJson(Map json) => ClientSnapshot(
  clientId: json['clientId'] as String,
  fullName: json['fullName'] as String,
  documentId: json['documentId'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  imageBase64: json['imageBase64'] as String?,
);

Map<String, dynamic> _invoiceLineToJson(InvoiceLine l) => {
  'productItemId': l.productItemId,
  'itemName': l.itemName,
  'unitPrice': l.unitPrice,
  'quantity': l.quantity,
};

InvoiceLine _invoiceLineFromJson(Map json) => InvoiceLine(
  productItemId: (json['productItemId'] ?? json['catalogItemId']) as String,
  itemName: json['itemName'] as String,
  unitPrice: (json['unitPrice'] as num).toDouble(),
  quantity: json['quantity'] as int,
);
