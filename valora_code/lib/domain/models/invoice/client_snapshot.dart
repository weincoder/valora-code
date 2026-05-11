class ClientSnapshot {
  final String clientId;
  final String fullName;
  final String documentId;
  final String email;
  final String phone;
  final String? imageBase64;

  const ClientSnapshot({
    required this.clientId,
    required this.fullName,
    required this.documentId,
    required this.email,
    required this.phone,
    this.imageBase64,
  });
}
