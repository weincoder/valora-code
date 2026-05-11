import '../../models/friend/gateway/friend_gateway.dart';

class DeleteFriendUseCase {
  final FriendGateway _gateway;

  DeleteFriendUseCase(this._gateway);

  Future<void> execute(String id) => _gateway.delete(id);
}
