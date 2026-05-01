class ProductException implements Exception {
  final String message;
  const ProductException(this.message);

  @override
  String toString() => 'ProductException: $message';
}
