class ProductsException implements Exception {
  final String message;

  ProductsException(this.message);

  @override
  String toString() {
    return message;
  }
}
