import 'dart:convert';
import 'package:http/http.dart';
import 'package:lsffend/config/app_config.dart';
import 'package:lsffend/dataset/mock_service.dart';

import 'api_service.dart';

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
    final response = await ApiService.postRequest('user-auth/register', {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });

    final contentType = response.headers['content-Type'] ?? '';

    if (!contentType.contains('application/json')) {
      return {
        'status': response.statusCode,
        'message':
            'Server error _ recieved HTML instead of JSON. '
            'Chech if Laravel is running correctly.',
      };
    }

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await ApiService.saveToken(data['token']);
    }

    return {'status': response.statusCode, ...data};
  }

  //Customer Login
  static Future<Map<String, dynamic>> customerLogin({
    required String email,
    required String password,
  }) async {
    //OfflineMode
    if (AppConfig.offlineMode) {
      await Future.delayed(Duration(seconds: 5));
      final result = MockService.mockLogin(email, password);

      await ApiService.saveToken(result['token']);

      return result;
    }

    //OnlineMode
    final response = await ApiService.postRequest('user-auth/login', {
      'email': email,
      'password': password,
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await ApiService.saveToken(data['token']);
    }

    return {'status': response.statusCode, ...data};
  }

  //Worker Login
  static Future<Map<String, dynamic>> workerLogin({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.postRequest('worker-auth/login', {
      'email': email,
      'password': password,
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await ApiService.saveToken(data['token']);
    }

    return {'status': response.statusCode, ...data};
  }

  static Future<void> logout() async {
    await ApiService.postRequest('worker-auth/logout', {}, auth: true);
    await ApiService.clearToken();
  }
}
