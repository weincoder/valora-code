import 'package:hive/hive.dart';
import '../../../domain/models/issuer_config/issuer_config.dart';
import '../../../domain/models/issuer_config/gateway/issuer_config_gateway.dart';
import '../../helpers/mappers/issuer_config_mapper.dart';

class IssuerConfigHiveAdapter implements IssuerConfigGateway {
  static const String _boxName = 'issuer_config';
  static const String _key = 'issuer_config';

  Box<Map> get _box => Hive.box<Map>(_boxName);

  @override
  Future<IssuerConfig?> get() async {
    final raw = _box.get(_key);
    if (raw == null) return null;
    return issuerConfigFromJson(raw);
  }

  @override
  Future<void> save(IssuerConfig config) async {
    await _box.put(_key, issuerConfigToJson(config));
  }
}
