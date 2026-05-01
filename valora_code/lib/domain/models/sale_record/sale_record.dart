class SaleRecord {
  final String id;
  final String productItemId;
  final String productTitle;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final DateTime date;
  final String? notes;

  const SaleRecord({
    required this.id,
    required this.productItemId,
    required this.productTitle,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.date,
    this.notes,
  });

  SaleRecord copyWith({
    String? id,
    String? productItemId,
    String? productTitle,
    int? quantity,
    double? unitPrice,
    double? totalAmount,
    DateTime? date,
    String? notes,
    bool clearNotes = false,
  }) {
    return SaleRecord(
      id: id ?? this.id,
      productItemId: productItemId ?? this.productItemId,
      productTitle: productTitle ?? this.productTitle,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      date: date ?? this.date,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }
}
