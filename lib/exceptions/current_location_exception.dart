class CurrentLocationException implements Exception {
  final String message;

  CurrentLocationException(this.message);

  @override
  String toString() {
    return message;
  }
}
