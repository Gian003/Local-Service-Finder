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

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parser,
  ) {
    try {
      // Validate required fields
      if (!json.containsKey('success')) {
        throw Exception('Missing required field: success');
      }

      final success = json['success'] == true;
      final statusCode = json['status_code'] ?? 0;

      if (success) {
        if (!json.containsKey('data')) {
          throw Exception('Missing data field for successful response');
        }
        return ApiResponse(
          success: true,
          statusCode: statusCode,
          data: parser(json['data']),
        );
      } else {
        return ApiResponse(
          success: false,
          statusCode: statusCode,
          message: json['message'] ?? 'Unknown error',
          error: json['error'],
        );
      }
    } catch (e) {
      throw Exception('Invalid response format: $e');
    }
  }
}