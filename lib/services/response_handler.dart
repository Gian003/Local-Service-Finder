import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Handles safe JSON decoding and response validation
class ResponseHandler {
  /// Safely decodes JSON and validates response structure
  /// Returns decoded data on success, throws ApiException on failure
  static Map<String, dynamic> parseJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(
          message: 'Invalid response format: expected JSON object',
          statusCode: 0,
        );
      }
      return decoded;
    } on FormatException catch (e) {
      debugPrint('JSON Parse Error: $e');
      throw ApiException(
        message: 'Failed to parse response: ${e.message}',
        statusCode: 0,
      );
    }
  }

  /// Safely decodes JSON array
  static List<dynamic> parseJsonArray(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        throw ApiException(
          message: 'Invalid response format: expected JSON array',
          statusCode: 0,
        );
      }
      return decoded;
    } on FormatException catch (e) {
      debugPrint('JSON Array Parse Error: $e');
      throw ApiException(
        message: 'Failed to parse response array: ${e.message}',
        statusCode: 0,
      );
    }
  }

  /// Validates required fields exist in response
  static void validateFields(
    Map<String, dynamic> data,
    List<String> requiredFields,
  ) {
    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        throw ApiException(
          message: 'Missing required field: $field',
          statusCode: 0,
        );
      }
    }
  }

  /// Safely get nested value with default fallback
  static dynamic getValue(
    Map<String, dynamic> data,
    String path, {
    dynamic defaultValue,
  }) {
    final keys = path.split('.');
    dynamic current = data;

    for (final key in keys) {
      if (current is Map && current.containsKey(key)) {
        current = current[key];
      } else {
        return defaultValue;
      }
    }

    return current ?? defaultValue;
  }

  /// Safely get string value
  static String getString(
    Map<String, dynamic> data,
    String key, {
    String defaultValue = '',
  }) {
    final value = data[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// Safely get int value
  static int getInt(
    Map<String, dynamic> data,
    String key, {
    int defaultValue = 0,
  }) {
    final value = data[key];
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Safely get double value
  static double getDouble(
    Map<String, dynamic> data,
    String key, {
    double defaultValue = 0.0,
  }) {
    final value = data[key];
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Safely get bool value
  static bool getBool(
    Map<String, dynamic> data,
    String key, {
    bool defaultValue = false,
  }) {
    final value = data[key];
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value != 0;
    return defaultValue;
  }

  /// Safely get list value
  static List<dynamic> getList(
    Map<String, dynamic> data,
    String key, {
    List<dynamic> defaultValue = const [],
  }) {
    final value = data[key];
    if (value == null) return defaultValue;
    if (value is List) return value;
    return defaultValue;
  }
}

/// Custom exception for API/response errors
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic originalError;

  ApiException({
    required this.message,
    required this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}
