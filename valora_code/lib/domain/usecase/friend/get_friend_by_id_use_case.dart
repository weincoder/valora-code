import '../../models/friend/friend.dart';
import '../../models/friend/gateway/friend_gateway.dart';

class GetFriendByIdUseCase {
  final FriendGateway _gateway;

  GetFriendByIdUseCase(this._gateway);

  Future<Friend?> execute(String id) => _gateway.getById(id);
}
