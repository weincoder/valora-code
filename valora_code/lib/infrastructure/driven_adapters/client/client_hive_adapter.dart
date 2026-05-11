import 'package:hive/hive.dart';
import '../../../domain/models/client/client.dart';
import '../../../domain/models/client/gateway/client_gateway.dart';
import '../../helpers/mappers/client_mapper.dart';

class ClientHiveAdapter implements ClientGateway {
  static const String _boxName = 'clients';

  Box<Map> get _box => Hive.box<Map>(_boxName);

  @override
  Future<List<Client>> getAll() async {
    return _box.values.map((raw) => clientFromJson(raw)).toList();
  }

  @override
  Future<Client?> getById(String id) async {
    final raw = _box.get(id);
    if (raw == null) return null;
    return clientFromJson(raw);
  }

  @override
  Future<Client?> getByDocumentId(String documentId) async {
    try {
      final raw = _box.values.firstWhere((m) => m['documentId'] == documentId);
      return clientFromJson(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(Client client) async {
    await _box.put(client.id, clientToJson(client));
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
