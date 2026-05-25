import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'network_exception.dart';

/// HTTP client with timeouts, retries, and error handling
class HttpClient {
  static const Duration defaultTimeout = Duration(seconds: 15);
  static const int maxRetries = 3;
  static const Duration initialRetryDelay = Duration(milliseconds: 500);

  /// Make a GET request with timeout and retry logic
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    Duration timeout = defaultTimeout,
    int retries = maxRetries,
  }) async {
    return _retryRequest(
      () => http.get(url, headers: headers).timeout(
            timeout,
            onTimeout: () {
              throw TimeoutException(
                message: 'GET request to $url timed out',
                timeout: timeout,
              );
            },
          ),
      retries: retries,
      url: url,
      method: 'GET',
    );
  }

  /// Make a POST request with timeout and retry logic
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = defaultTimeout,
    int retries = maxRetries,
  }) async {
    return _retryRequest(
      () => http.post(
        url,
        headers: headers,
        body: body,
      ).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException(
            message: 'POST request to $url timed out',
            timeout: timeout,
          );
        },
      ),
      retries: retries,
      url: url,
      method: 'POST',
    );
  }

  /// Make a PUT request with timeout and retry logic
  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = defaultTimeout,
    int retries = maxRetries,
  }) async {
    return _retryRequest(
      () => http.put(
        url,
        headers: headers,
        body: body,
      ).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException(
            message: 'PUT request to $url timed out',
            timeout: timeout,
          );
        },
      ),
      retries: retries,
      url: url,
      method: 'PUT',
    );
  }

  /// Make a DELETE request with timeout and retry logic
  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Duration timeout = defaultTimeout,
    int retries = maxRetries,
  }) async {
    return _retryRequest(
      () => http.delete(url, headers: headers).timeout(
            timeout,
            onTimeout: () {
              throw TimeoutException(
                message: 'DELETE request to $url timed out',
                timeout: timeout,
              );
            },
          ),
      retries: retries,
      url: url,
      method: 'DELETE',
    );
  }

  /// Internal retry logic with exponential backoff
  static Future<http.Response> _retryRequest(
    Future<http.Response> Function() request, {
    required int retries,
    required Uri url,
    required String method,
  }) async {
    int attempt = 0;
    Duration delay = initialRetryDelay;

    while (attempt <= retries) {
      try {
        debugPrint('📡 $method $url (attempt ${attempt + 1}/${ retries + 1})');
        final response = await request();
        debugPrint('✅ $method $url → ${response.statusCode}');
        return response;
      } on TimeoutException catch (e) {
        debugPrint('⏱️  $e');
        if (attempt < retries) {
          debugPrint('🔄 Retrying after ${delay.inMilliseconds}ms...');
          await Future.delayed(delay);
          delay *= 2; // Exponential backoff
          attempt++;
        } else {
          rethrow;
        }
      } on NetworkException catch (e) {
        debugPrint('❌ $e');
        if (attempt < retries) {
          debugPrint('🔄 Retrying after ${delay.inMilliseconds}ms...');
          await Future.delayed(delay);
          delay *= 2;
          attempt++;
        } else {
          rethrow;
        }
      } catch (e, st) {
        debugPrint('❌ Unexpected error: $e');
        debugPrintStack(stackTrace: st);
        throw NetworkException(
          message: 'Request failed: $e',
          originalError: e,
          stackTrace: st,
        );
      }
    }

    throw NetworkException(
      message: 'Max retries exceeded for $method $url',
    );
  }

  /// Check if error is retryable
  static bool isRetryable(dynamic error) {
    if (error is TimeoutException) return true;
    if (error is ConnectionException) return true;
    // Don't retry auth or client errors
    return false;
  }
}
