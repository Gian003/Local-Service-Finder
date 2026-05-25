/// Exception for network-related errors
class NetworkException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  NetworkException({
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception for timeout errors
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  TimeoutException({
    required this.message,
    required this.timeout,
  });

  @override
  String toString() => 'TimeoutException: $message (timeout: ${timeout.inSeconds}s)';
}

/// Exception for connection errors
class ConnectionException implements Exception {
  final String message;

  ConnectionException({required this.message});

  @override
  String toString() => 'ConnectionException: $message';
}
