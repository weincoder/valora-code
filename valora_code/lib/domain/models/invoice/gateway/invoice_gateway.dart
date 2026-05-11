import '../invoice.dart';

abstract class InvoiceGateway {
  Future<List<Invoice>> getAll();
  Future<Invoice?> getById(String id);
  Future<void> save(Invoice invoice);
}
