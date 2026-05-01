import '../../models/sale_record/gateway/sale_record_gateway.dart';

class DeleteSaleRecordUseCase {
  final SaleRecordGateway gateway;

  DeleteSaleRecordUseCase({required this.gateway});

  Future<void> execute(String id) => gateway.delete(id);
}
