import 'package:hive_flutter/hive_flutter.dart';
import '../../../domain/models/sale_record/sale_record.dart';
import '../../../domain/models/sale_record/gateway/sale_record_gateway.dart';
import '../../helpers/mappers/sale_record_mapper.dart';

class SaleRecordHiveAdapter implements SaleRecordGateway {
  static const String _boxName = 'sale_records';

  Future<Box> get _box async => Hive.openBox(_boxName);

  @override
  Future<List<SaleRecord>> getAll() async {
    final box = await _box;
    return box.values.map((e) => saleRecordFromJson(e as Map)).toList();
  }

  @override
  Future<void> save(SaleRecord record) async {
    final box = await _box;
    await box.put(record.id, saleRecordToJson(record));
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
