import '../../models/product_item/gateway/product_item_gateway.dart';

class DeleteProductItemUseCase {
  final ProductItemGateway gateway;

  DeleteProductItemUseCase({required this.gateway});

  Future<void> execute(String id) {
    return gateway.delete(id);
  }
}
