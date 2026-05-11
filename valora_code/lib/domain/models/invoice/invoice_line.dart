class InvoiceLine {
  final String productItemId;
  final String itemName;
  final double unitPrice;
  final int quantity;

  const InvoiceLine({
    required this.productItemId,
    required this.itemName,
    required this.unitPrice,
    required this.quantity,
  });

  double get subtotal => unitPrice * quantity;
}
