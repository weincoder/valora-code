import '../../../domain/models/additional_cost/additional_cost.dart';
import '../../../domain/models/product_item/product_item.dart';

Map<String, dynamic> productItemToJson(ProductItem p) => {
  'id': p.id,
  'title': p.title,
  'description': p.description,
  'hourlyRate': p.hourlyRate,
  'estimatedHours': p.estimatedHours,
  'salePrice': p.salePrice,
  'profitMargin': p.profitMargin,
  'imageBase64': p.imageBase64,
  'createdAt': p.createdAt.toIso8601String(),
  'additionalCosts': p.additionalCosts
      .map((c) => {'label': c.label, 'amount': c.amount})
      .toList(),
};

ProductItem productItemFromJson(Map<dynamic, dynamic> map) {
  final imageRaw = map['imageBase64'] as String?;
  final imageBase64 =
      (imageRaw != null && imageRaw.length < 500 && imageRaw.startsWith('/'))
      ? null
      : imageRaw;

  return ProductItem(
    id: map['id'] as String? ?? '',
    title: map['title'] as String? ?? 'Sin título',
    description: map['description'] as String? ?? '',
    hourlyRate: (map['hourlyRate'] as num?)?.toDouble() ?? 0.0,
    estimatedHours: (map['estimatedHours'] as num?)?.toDouble() ?? 0.0,
    salePrice: (map['salePrice'] as num?)?.toDouble() ?? 0.0,
    profitMargin: (map['profitMargin'] as num?)?.toDouble() ?? 0.0,
    imageBase64: imageBase64,
    createdAt:
        DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    additionalCosts: _parseCosts(map['additionalCosts']),
  );
}

List<AdditionalCost> _parseCosts(dynamic raw) {
  if (raw == null) return [];
  return (raw as List<dynamic>).map((e) {
    final m = e as Map<dynamic, dynamic>;
    return AdditionalCost(
      label: m['label'] as String? ?? '',
      amount: (m['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }).toList();
}
