import 'package:lsf/services/api_service.dart';
import 'package:lsf/services/response_handler.dart';
import 'package:lsf/screens/roles/user-ui/navigation/home/notification/notification_model.dart';

class NotificationService {
  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await ApiService.getRequest(
        'notifications',
        auth: true,
      );
      if (response.statusCode == 200) {
        final data = ResponseHandler.parseJson(response.body);
        final notifications = ResponseHandler.getList(data, 'data');
        return notifications.map((n) => NotificationModel.fromJson(n)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Backend route: PUT /notifications/{id}/read
  static Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await ApiService.putRequest(
        'notifications/$notificationId/read',
        {},
        auth: true,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Backend route: PUT /notifications/read-all
  static Future<bool> markAllAsRead() async {
    try {
      final response = await ApiService.putRequest(
        'notifications/read-all',
        {},
        auth: true,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
