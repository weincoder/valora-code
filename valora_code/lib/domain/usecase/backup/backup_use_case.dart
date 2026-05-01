import '../../models/backup/gateway/backup_gateway.dart';

class BackupUseCase {
  final BackupGateway gateway;

  BackupUseCase({required this.gateway});

  Future<String> export() {
    return gateway.exportToJson();
  }

  Future<void> import(String jsonContent) {
    if (jsonContent.trim().isEmpty) {
      throw ArgumentError('El contenido del backup no puede estar vacío');
    }
    return gateway.importFromJson(jsonContent);
  }
}
