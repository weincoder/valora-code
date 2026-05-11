class InvoiceException implements Exception {
  final String message;
  const InvoiceException(this.message);

  @override
  String toString() => 'InvoiceException: $message';
}
