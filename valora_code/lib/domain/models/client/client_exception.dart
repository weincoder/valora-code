class ClientException implements Exception {
  final String message;
  const ClientException(this.message);

  @override
  String toString() => 'ClientException: $message';
}
