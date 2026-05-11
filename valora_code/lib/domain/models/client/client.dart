class Client {
  final String id;
  final String fullName;
  final String documentId;
  final String email;
  final String phone;
  final String? imageBase64;

  const Client({
    required this.id,
    required this.fullName,
    required this.documentId,
    required this.email,
    required this.phone,
    this.imageBase64,
  });

  Client copyWith({
    String? id,
    String? fullName,
    String? documentId,
    String? email,
    String? phone,
    String? imageBase64,
    bool clearImage = false,
  }) {
    return Client(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      documentId: documentId ?? this.documentId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageBase64: clearImage ? null : imageBase64 ?? this.imageBase64,
    );
  }
}
