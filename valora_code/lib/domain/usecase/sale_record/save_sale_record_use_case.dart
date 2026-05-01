import '../../models/sale_record/gateway/sale_record_gateway.dart';
import '../../models/sale_record/sale_record.dart';

class SaveSaleRecordUseCase {
  final SaleRecordGateway gateway;

  SaveSaleRecordUseCase({required this.gateway});

  Future<void> execute(SaleRecord record) => gateway.save(record);
}
