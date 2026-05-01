import '../../models/product_item/product_item.dart';
import '../../models/product_item/gateway/product_item_gateway.dart';

class SaveProductItemUseCase {
  final ProductItemGateway gateway;

  SaveProductItemUseCase({required this.gateway});

  Future<void> execute(ProductItem item) {
    return gateway.save(item);
  }
}
