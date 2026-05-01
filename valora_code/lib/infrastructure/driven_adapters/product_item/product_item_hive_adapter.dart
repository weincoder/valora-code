import 'package:hive_flutter/hive_flutter.dart';
import '../../../domain/models/product_item/product_item.dart';
import '../../../domain/models/product_item/gateway/product_item_gateway.dart';
import '../../helpers/mappers/product_item_mapper.dart';

class ProductItemHiveAdapter implements ProductItemGateway {
  static const String _boxName = 'products';

  Future<Box> get _box async => Hive.openBox(_boxName);

  @override
  Future<List<ProductItem>> getAll() async {
    final box = await _box;
    return box.values.map((e) => productItemFromJson(e as Map)).toList();
  }

  @override
  Future<void> save(ProductItem item) async {
    final box = await _box;
    await box.put(item.id, productItemToJson(item));
  }

  @override
  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<void> clear() async {
    final box = await _box;
    await box.clear();
  }
}
