import '../../models/client/client.dart';
import '../../models/client/gateway/client_gateway.dart';

class GetAllClientsUseCase {
  final ClientGateway _gateway;

  GetAllClientsUseCase(this._gateway);

  Future<List<Client>> execute() => _gateway.getAll();
}
