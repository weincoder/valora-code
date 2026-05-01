import '../product.dart';

abstract class ProductGateway {
  double calculateProfitMargin(Product product);
}
