class ApiResponse<T> {
  final bool success;
  final int statusCode;
  final String? message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    required this.statusCode,
    this.message,
    this.data,
    this.error,
  });

  // Infers success from HTTP status code — no 'success' field required from backend.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parser, {
    int statusCode = 0,
  }) {
    try {
      final success = json.containsKey('success')
          ? json['success'] == true
          : statusCode >= 200 && statusCode < 300;

      final resolvedStatusCode =
          (json['status_code'] as int?) ?? statusCode;

      if (success && json.containsKey('data')) {
        return ApiResponse(
          success: true,
          statusCode: resolvedStatusCode,
          data: parser(json['data'] as Map<String, dynamic>),
        );
      }

      return ApiResponse(
        success: success,
        statusCode: resolvedStatusCode,
        message: json['message']?.toString() ?? (success ? null : 'Unknown error'),
        error: json['error']?.toString(),
      );
    } catch (e) {
      throw Exception('Invalid response format: $e');
    }
  }
}
