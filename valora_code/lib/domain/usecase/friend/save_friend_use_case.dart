import '../../models/friend/friend.dart';
import '../../models/friend/friend_exception.dart';
import '../../models/friend/gateway/friend_gateway.dart';

class SaveFriendUseCase {
  final FriendGateway _gateway;

  SaveFriendUseCase(this._gateway);

  static const _validCurrencies = {'COP', 'USD'};

  Future<void> execute(Friend friend) async {
    if (friend.fullName.trim().isEmpty) {
      throw const FriendException('El nombre es requerido');
    }
    if (friend.hourlyRate < 0) {
      throw const FriendException('El valor por hora no puede ser negativo');
    }
    if (!_validCurrencies.contains(friend.currency)) {
      throw const FriendException('La moneda debe ser COP o USD');
    }
    await _gateway.save(friend);
  }
}
