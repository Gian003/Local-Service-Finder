import 'dart:convert';
import 'package:lsffend/templates/service card/service_model.dart';
import 'api_service.dart';

class ServiceServices {
  //Get All Services
  static Future<List<ServiceModel>> getAllServices({
    String? category,
    String? sort,
  }) async {
    String endpoint = '/services';
    final parameters = <String>[];

    if (category != null) parameters.add('cateoory=$category');
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
    final response = await ApiService.getRequest('/services/$id');

    if (response.statusCode == 200) {
      return ServiceModel.fromJson(jsonDecode(response.body));
    }

    return null;
  }
}
