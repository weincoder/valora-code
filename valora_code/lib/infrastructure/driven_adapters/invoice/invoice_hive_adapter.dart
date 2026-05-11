import 'package:hive/hive.dart';
import '../../../domain/models/invoice/invoice.dart';
import '../../../domain/models/invoice/gateway/invoice_gateway.dart';
import '../../helpers/mappers/invoice_mapper.dart';

class InvoiceHiveAdapter implements InvoiceGateway {
  static const String _boxName = 'invoices';

  Box<Map> get _box => Hive.box<Map>(_boxName);

  @override
  Future<List<Invoice>> getAll() async {
    return _box.values.map((raw) => invoiceFromJson(raw)).toList();
  }

  @override
  Future<Invoice?> getById(String id) async {
    final raw = _box.get(id);
    if (raw == null) return null;
    return invoiceFromJson(raw);
  }

  @override
  Future<void> save(Invoice invoice) async {
    await _box.put(invoice.id, invoiceToJson(invoice));
  }
}
