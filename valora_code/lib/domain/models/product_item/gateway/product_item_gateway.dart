import '../product_item.dart';

abstract class ProductItemGateway {
  Future<List<ProductItem>> getAll();
  Future<void> save(ProductItem item);
  Future<void> delete(String id);
}
