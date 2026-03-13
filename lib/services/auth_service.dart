import 'dart:convert';
import 'package:http/http.dart';

import 'api_service.dart';

class AuthService {
  //Customer Register
  static Future<Map<String, dynamic>> customerRegister({
    required String lastName,
    required String firstName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await ApiService.postRequest('/auth/register', {
      'last_name': lastName,
      'first_name': firstName,
      'email': email,
      'phone': phone,
      'password': password,
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await ApiService.saveToken(data['token']);
    }

    return data;
  }

  //Customer Login
  static Future<Map<String, dynamic>> customerLogin({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.postRequest('/user-auth/login', {
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
    final response = await ApiService.postRequest('/worker-auth/login', {
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
    await ApiService.postRequest('/worker-auth/logout', {}, auth: true);
    await ApiService.clearToken();
  }
}
