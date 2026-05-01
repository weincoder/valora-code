abstract class BackupGateway {
  Future<String> exportToJson();
  Future<void> importFromJson(String jsonContent);
}
