import '../../../domain/models/product/product.dart';
import '../../../domain/models/product/product_exception.dart';
import '../../../domain/models/product/gateway/product_gateway.dart';

class ProductAdapter implements ProductGateway {
  @override
  double calculateProfitMargin(Product product) {
    if (product.salePrice == 0) {
      throw const ProductException('El precio de venta no puede ser cero');
    }
    return ((product.salePrice - product.productionCost) / product.salePrice) *
        100;
  }
}
