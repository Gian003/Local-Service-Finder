/// Exception for authentication errors
class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'AuthException($statusCode): $message';
}

/// Exception for token-related errors
class TokenException implements Exception {
  final String message;

  TokenException({required this.message});

  @override
  String toString() => 'TokenException: $message';
}
