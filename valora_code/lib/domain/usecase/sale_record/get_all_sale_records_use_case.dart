import '../../models/sale_record/gateway/sale_record_gateway.dart';
import '../../models/sale_record/sale_record.dart';

class GetAllSaleRecordsUseCase {
  final SaleRecordGateway gateway;

  GetAllSaleRecordsUseCase({required this.gateway});

  Future<List<SaleRecord>> execute() => gateway.getAll();
}
