import '../../models/client/client.dart';
import '../../models/client/client_exception.dart';
import '../../models/client/gateway/client_gateway.dart';

class SaveClientUseCase {
  final ClientGateway _gateway;

  SaveClientUseCase(this._gateway);

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  Future<void> execute(Client client) async {
    if (client.fullName.trim().isEmpty) {
      throw const ClientException('El nombre es requerido');
    }
    if (client.documentId.trim().isEmpty) {
      throw const ClientException('El número de documento es requerido');
    }
    if (!_emailRegex.hasMatch(client.email)) {
      throw const ClientException('El formato del email no es válido');
    }
    if (client.phone.trim().isEmpty) {
      throw const ClientException('El teléfono es requerido');
    }

    final existing = await _gateway.getByDocumentId(client.documentId);
    if (existing != null && existing.id != client.id) {
      throw const ClientException(
        'Ya existe un cliente con ese número de documento',
      );
    }

    await _gateway.save(client);
  }
}
