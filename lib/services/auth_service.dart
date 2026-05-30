import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lsf/config/app_config.dart';
import 'package:lsf/dataset/mock_service.dart';
import 'api_service.dart';
import 'response_handler.dart';
import 'auth_exception.dart';

class AuthService {
  //Customer Register
  static Future<Map<String, dynamic>> customerRegister({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    //OfflineMode
    if (AppConfig.offlineMode) {
      await Future.delayed(Duration(seconds: 5));
      return MockService.mockRegister();
    }

    //OnlineMode
    try {
      final response = await ApiService.postRequest('user-auth/register', {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'password_confirmation': password,
      });

      final contentType = response.headers['content-type'] ?? '';

      if (!contentType.contains('application/json')) {
        return {
          'status': response.statusCode,
          'message':
              'Server error: received HTML instead of JSON. '
              'Check if Laravel is running correctly.',
        };
      }

      try {
        final data = ResponseHandler.parseJson(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final token = ResponseHandler.getString(data, 'token');
          if (token.isNotEmpty) {
            await ApiService.saveToken(token);
          }
        }

        return {'status': response.statusCode, ...data};
      } on ApiException catch (e) {
        return {
          'status': response.statusCode,
          'message': 'Failed to parse response: ${e.message}',
        };
      }
    } on AuthException catch (e) {
      return {'status': e.statusCode ?? 0, 'message': e.message};
    } catch (e) {
      return {'status': 0, 'message': 'Registration failed: $e'};
    }
  }

  //Customer Login
  static Future<Map<String, dynamic>> customerLogin({
    required String email,
    required String password,
    required String role,
  }) async {
    //OfflineMode
    if (AppConfig.offlineMode) {
      await Future.delayed(Duration(milliseconds: 500));
      final result = MockService.mockLogin(email, password);

      await ApiService.saveToken(result['token']);
      await ApiService.saveRole(role);

      return result;
    }

    //Online Mode
    try {
      final endPoint = role == 'worker'
          ? 'worker-auth/login'
          : 'user-auth/login';

      final response = await ApiService.postRequest(endPoint, {
        'email': email,
        'password': password,
      });

      try {
        final data = ResponseHandler.parseJson(response.body);

        if (response.statusCode == 200) {
          final token = ResponseHandler.getString(data, 'token');
          if (token.isNotEmpty) {
            await ApiService.saveToken(token);
            await ApiService.saveRole(role);
          }
        }

        return {'status': response.statusCode, ...data};
      } on ApiException catch (e) {
        return {
          'status': response.statusCode,
          'message': 'Failed to parse response: ${e.message}',
        };
      }
    } on AuthException catch (e) {
      return {'status': e.statusCode ?? 0, 'message': e.message};
    } catch (e) {
      return {'status': 0, 'message': 'Login failed: $e'};
    }
  }

  //Logout
  static Future<void> logout({String role = 'customer'}) async {
    if (!AppConfig.offlineMode) {
      final endpoint = role == 'worker'
          ? 'worker-auth/logout'
          : 'user-auth/logout';
      try {
        await ApiService.postRequest(endpoint, {}, auth: true);
      } catch (e) {
        debugPrint('Logout API error: $e');
      }
    }

    await ApiService.clearAll();
  }
}
