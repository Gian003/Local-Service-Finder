import 'dart:convert';
import 'package:lsf/config/app_config.dart';
import 'package:lsf/dataset/mock_service.dart';
import 'package:lsf/templates/service card/service_model.dart';
import 'api_service.dart';

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
        list = list.where((sort) => sort.category == category).toList();
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
    String endpoint = 'services';
    final parameters = <String>[];

    if (category != null) parameters.add('category=$category');
    if (sort != null) parameters.add('sort=$sort');

    if (parameters.isNotEmpty) endpoint += '?${parameters.join('&')}';

    final response = await ApiService.getRequest(endpoint);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    }

    return [];
  }

  //Get single Service
  static Future<ServiceModel?> getSingleService(int id) async {
    final response = await ApiService.getRequest('services/$id');

    if (response.statusCode == 200) {
      return ServiceModel.fromJson(jsonDecode(response.body));
    }

    return null;
  }
}
