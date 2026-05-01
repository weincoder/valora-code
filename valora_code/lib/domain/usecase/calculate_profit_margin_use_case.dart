import '../models/product/product.dart';
import '../models/product/gateway/product_gateway.dart';

class CalculateProfitMarginUseCase {
  final ProductGateway gateway;

  CalculateProfitMarginUseCase({required this.gateway});

  double execute(Product product) {
    return gateway.calculateProfitMargin(product);
  }
}
