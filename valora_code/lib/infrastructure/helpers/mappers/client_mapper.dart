import '../../../domain/models/client/client.dart';

Map<String, dynamic> clientToJson(Client client) => {
  'id': client.id,
  'fullName': client.fullName,
  'documentId': client.documentId,
  'email': client.email,
  'phone': client.phone,
  'imageBase64': client.imageBase64,
};

Client clientFromJson(Map<dynamic, dynamic> json) => Client(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  documentId: json['documentId'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  imageBase64: json['imageBase64'] as String?,
);
