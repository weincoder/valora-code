import '../friend.dart';

abstract class FriendGateway {
  Future<List<Friend>> getAll();
  Future<Friend?> getById(String id);
  Future<void> save(Friend friend);
  Future<void> delete(String id);
}
