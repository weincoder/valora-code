import '../../../domain/models/friend/friend.dart';

Map<String, dynamic> friendToJson(Friend friend) => {
  'id': friend.id,
  'fullName': friend.fullName,
  'knowledgeAreas': friend.knowledgeAreas,
  'hourlyRate': friend.hourlyRate,
  'currency': friend.currency,
  'imageBase64': friend.imageBase64,
};

Friend friendFromJson(Map<dynamic, dynamic> json) => Friend(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  knowledgeAreas: (json['knowledgeAreas'] as List? ?? [])
      .map((e) => e as String)
      .toList(),
  hourlyRate: (json['hourlyRate'] as num).toDouble(),
  currency: (json['currency'] as String?) ?? 'COP',
  imageBase64: json['imageBase64'] as String?,
);
