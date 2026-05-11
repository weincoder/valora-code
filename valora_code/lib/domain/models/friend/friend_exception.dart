class FriendException implements Exception {
  final String message;

  const FriendException(this.message);

  @override
  String toString() => 'FriendException: $message';
}
