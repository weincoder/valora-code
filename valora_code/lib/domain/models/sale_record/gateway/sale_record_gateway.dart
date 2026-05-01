import '../sale_record.dart';

abstract class SaleRecordGateway {
  Future<List<SaleRecord>> getAll();
  Future<void> save(SaleRecord record);
  Future<void> delete(String id);
}
