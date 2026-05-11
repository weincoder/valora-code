import '../../models/friend/friend.dart';
import '../../models/friend/gateway/friend_gateway.dart';

class GetAllFriendsUseCase {
  final FriendGateway _gateway;

  GetAllFriendsUseCase(this._gateway);

  Future<List<Friend>> execute() => _gateway.getAll();
}
