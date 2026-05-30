import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lsf/config/app_config.dart';
import 'package:lsf/dataset/mock_service.dart';
import 'package:lsf/templates/service card/service_model.dart';
import 'api_service.dart';
import 'response_handler.dart';
import 'auth_exception.dart';

class ServiceServices {
  //Get All Services
  static Future<List<ServiceModel>> getAllServices({
    String? category,
    String? sort,
  }) async {
    //Offline Mode
    if (AppConfig.offlineMode) {
      await Future.delayed(Duration(seconds: 5));
      var list = MockService.getServices();

      if (category != null) {
        list = list.where((service) => service.category == category).toList();
      }

      if (sort == 'popular') {
        list.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
      } else if (sort == 'newest') {
        // Sort by newest
      } else if (sort == 'most_expensive') {
        list.sort((a, b) => b.price.compareTo(a.price));
      } else if (sort == 'lowest_price') {
        list.sort((a, b) => a.price.compareTo(b.price));
      }

      return list;
    }

    //Online Mode
    try {
      String endpoint = 'services';
      final parameters = <String>[];

      if (category != null) parameters.add('category=$category');
      if (sort != null) {
        final apiSort = sort == 'most_expensive'
            ? 'price-desc'
            : sort == 'lowest_price'
                ? 'price-asc'
                : sort;
        parameters.add('sort=$apiSort');
      }

      if (parameters.isNotEmpty) endpoint += '?${parameters.join('&')}';

      final response = await ApiService.getRequest(endpoint);

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.body);
          List<dynamic> list;
          if (decoded is List) {
            list = decoded;
          } else if (decoded is Map<String, dynamic>) {
            list = (decoded['data'] ?? decoded['services'] ?? []) as List<dynamic>;
          } else {
            list = [];
          }
          return list
              .whereType<Map<String, dynamic>>()
              .map((json) => ServiceModel.fromJson(json))
              .toList();
        } catch (e) {
          debugPrint('Parse error: $e');
          return [];
        }
      }

      debugPrint('Failed to fetch services: status ${response.statusCode}');
      return [];
    } on AuthException catch (e) {
      debugPrint('Auth error: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Failed to fetch services: $e');
      return [];
    }
  }

  //Get single Service
  static Future<ServiceModel?> getSingleService(int id) async {
    try {
      final response = await ApiService.getRequest('services/$id');

      if (response.statusCode == 200) {
        try {
          final data = ResponseHandler.parseJson(response.body);
          return ServiceModel.fromJson(data);
        } on ApiException catch (e) {
          debugPrint('Parse error: ${e.message}');
          return null;
        }
      }

      debugPrint('Service not found: status ${response.statusCode}');
      return null;
    } on AuthException catch (e) {
      debugPrint('Auth error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Failed to fetch service: $e');
      return null;
    }
  }
}
