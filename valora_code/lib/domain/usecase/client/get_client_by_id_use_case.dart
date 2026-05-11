import '../../models/client/client.dart';
import '../../models/client/gateway/client_gateway.dart';

class GetClientByIdUseCase {
  final ClientGateway _gateway;

  GetClientByIdUseCase(this._gateway);

  Future<Client?> execute(String id) => _gateway.getById(id);
}
