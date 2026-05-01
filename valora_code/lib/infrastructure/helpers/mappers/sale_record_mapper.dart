import '../../../domain/models/sale_record/sale_record.dart';

Map<String, dynamic> saleRecordToJson(SaleRecord r) => {
  'id': r.id,
  'productItemId': r.productItemId,
  'productTitle': r.productTitle,
  'quantity': r.quantity,
  'unitPrice': r.unitPrice,
  'totalAmount': r.totalAmount,
  'date': r.date.toIso8601String(),
  'notes': r.notes,
};

SaleRecord saleRecordFromJson(Map<dynamic, dynamic> map) => SaleRecord(
  id: map['id'] as String? ?? '',
  productItemId: map['productItemId'] as String? ?? '',
  productTitle: map['productTitle'] as String? ?? 'Sin título',
  quantity: (map['quantity'] as num?)?.toInt() ?? 1,
  unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
  totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
  date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
  notes: map['notes'] as String?,
);
