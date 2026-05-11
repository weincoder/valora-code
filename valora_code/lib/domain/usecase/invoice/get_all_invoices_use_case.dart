import '../../models/invoice/invoice.dart';
import '../../models/invoice/gateway/invoice_gateway.dart';

class GetAllInvoicesUseCase {
  final InvoiceGateway _gateway;

  GetAllInvoicesUseCase(this._gateway);

  Future<List<Invoice>> execute() => _gateway.getAll();
}
