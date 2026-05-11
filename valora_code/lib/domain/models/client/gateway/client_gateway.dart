import '../client.dart';

abstract class ClientGateway {
  Future<List<Client>> getAll();
  Future<Client?> getById(String id);
  Future<Client?> getByDocumentId(String documentId);
  Future<void> save(Client client);
  Future<void> delete(String id);
}
