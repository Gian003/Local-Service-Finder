import 'package:flutter/foundation.dart';
import 'package:lsf/models/review_model.dart';
import 'package:lsf/services/api_service.dart';
import 'package:lsf/services/auth_exception.dart';
import 'package:lsf/services/response_handler.dart';

class ReviewService {
  static Future<List<ReviewModel>> getWorkerReviews(int workerId) async {
    try {
      final response = await ApiService.getRequest(
        'reviews/worker/$workerId',
        auth: true,
      );

      if (response.statusCode == 200) {
        final list = ResponseHandler.parseJsonArray(response.body);
        return list
            .whereType<Map<String, dynamic>>()
            .map((json) => ReviewModel.fromJson(json))
            .toList();
      }

      return [];
    } on AuthException catch (e) {
      debugPrint('Auth error: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Failed to fetch reviews: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> submitReview({
    required int bookingId,
    required int workerId,
    required double rating,
    String? comment,
  }) async {
    try {
      final response = await ApiService.postRequest('reviews', {
        'booking_id': bookingId,
        'worker_id': workerId,
        'rating': rating,
        'comment': comment,
      }, auth: true);

      final data = ResponseHandler.parseJson(response.body);
      return {'status': response.statusCode, ...data};
    } on AuthException catch (e) {
      return {'status': e.statusCode ?? 0, 'message': e.message};
    } catch (e) {
      return {'status': 0, 'message': 'Failed to submit review: $e'};
    }
  }
}
