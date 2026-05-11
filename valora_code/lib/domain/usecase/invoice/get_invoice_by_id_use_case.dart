import '../../models/invoice/invoice.dart';
import '../../models/invoice/gateway/invoice_gateway.dart';

class GetInvoiceByIdUseCase {
  final InvoiceGateway _gateway;

  GetInvoiceByIdUseCase(this._gateway);

  Future<Invoice?> execute(String id) => _gateway.getById(id);
}
