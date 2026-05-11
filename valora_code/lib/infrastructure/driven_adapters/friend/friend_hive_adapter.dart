import 'package:hive/hive.dart';
import '../../../domain/models/friend/friend.dart';
import '../../../domain/models/friend/gateway/friend_gateway.dart';
import '../../helpers/mappers/friend_mapper.dart';

class FriendHiveAdapter implements FriendGateway {
  static const String _boxName = 'friends';

  Box<Map> get _box => Hive.box<Map>(_boxName);

  @override
  Future<List<Friend>> getAll() async {
    return _box.values.map(friendFromJson).toList();
  }

  @override
  Future<Friend?> getById(String id) async {
    final raw = _box.get(id);
    if (raw == null) return null;
    return friendFromJson(raw);
  }

  @override
  Future<void> save(Friend friend) async {
    await _box.put(friend.id, friendToJson(friend));
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
