import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lsf/config/app_config.dart';
import 'package:lsf/dataset/mock_service.dart';
import 'package:lsf/services/local_db.dart';
import 'package:lsf/templates/service card/service_model.dart';
import 'api_service.dart';
import 'response_handler.dart';
import 'auth_exception.dart';

class ServiceServices {
  //Get All Services. isFromCache tells the caller whether this came from the
  //live API (false) or the local read-through cache after a failed request
  //(true), so the UI can show an "offline — showing saved data" banner.
  static Future<({List<ServiceModel> services, bool isFromCache})> getAllServices({
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

      return (services: list, isFromCache: false);
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
          final rawServices = list.whereType<Map<String, dynamic>>().toList();

          // Cache is best-effort — a failure here shouldn't fail the request
          // that already has a good response in hand.
          unawaited(LocalDb.cacheServices(rawServices));

          return (
            services: rawServices.map((json) => ServiceModel.fromJson(json)).toList(),
            isFromCache: false,
          );
        } catch (e) {
          debugPrint('Parse error: $e');
          return (services: <ServiceModel>[], isFromCache: false);
        }
      }

      debugPrint('Failed to fetch services: status ${response.statusCode}');
      return (
        services: await _cachedServicesFallback(category: category, sort: sort),
        isFromCache: true,
      );
    } on AuthException catch (e) {
      debugPrint('Auth error: ${e.message}');
      return (services: <ServiceModel>[], isFromCache: false);
    } catch (e) {
      debugPrint('Failed to fetch services (offline?): $e');
      return (
        services: await _cachedServicesFallback(category: category, sort: sort),
        isFromCache: true,
      );
    }
  }

  // Falls back to whatever was last successfully cached — used when the
  // network request above fails outright (no connectivity, server down).
  static Future<List<ServiceModel>> _cachedServicesFallback({
    String? category,
    String? sort,
  }) async {
    final cached = await LocalDb.getCachedServices();
    var list = cached.map((json) => ServiceModel.fromJson(json)).toList();

    if (category != null) {
      list = list.where((service) => service.category == category).toList();
    }

    if (sort == 'popular') {
      list.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    } else if (sort == 'most_expensive') {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else if (sort == 'lowest_price') {
      list.sort((a, b) => a.price.compareTo(b.price));
    }

    return list;
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
