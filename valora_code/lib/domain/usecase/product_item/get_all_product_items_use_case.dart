import '../../models/product_item/product_item.dart';
import '../../models/product_item/gateway/product_item_gateway.dart';

class GetAllProductItemsUseCase {
  final ProductItemGateway gateway;

  GetAllProductItemsUseCase({required this.gateway});

  Future<List<ProductItem>> execute() {
    return gateway.getAll();
  }
}
