import 'package:lsffend/screens/navigation/bookmark/bookmark_model.dart';
import 'package:lsffend/screens/navigation/home/notification/notification_model.dart';
import 'package:lsffend/templates/service%20card/service_model.dart';

class MockService {
  static List<ServiceModel> getServices() {
    return [
      ServiceModel(
        title: "title",
        workerName: "workerName",
        rating: 6.3,
        reviewCount: 600,
        price: 1000,
        discountPercent: 40,
        imageUrl: 'https://picsum.photos/200',
      ),

      ServiceModel(
        title: "title",
        workerName: "workerName",
        rating: 5.3,
        reviewCount: 500,
        price: 2000,
        discountPercent: 40,
        imageUrl: 'https://picsum.photos/200',
      ),

      ServiceModel(
        title: "title",
        workerName: "workerName",
        rating: 4.3,
        reviewCount: 400,
        price: 3000,
        discountPercent: 40,
        imageUrl: 'https://picsum.photos/200',
      ),

      ServiceModel(
        title: "title",
        workerName: "workerName",
        rating: 3.3,
        reviewCount: 300,
        price: 4000,
        discountPercent: 40,
        imageUrl: 'https://picsum.photos/200',
      ),

      ServiceModel(
        title: "title",
        workerName: "workerName",
        rating: 2.3,
        reviewCount: 200,
        price: 5000,
        discountPercent: 40,
        imageUrl: 'https://picsum.photos/200',
      ),

      ServiceModel(
        title: "title",
        workerName: "workerName",
        rating: 1.3,
        reviewCount: 100,
        price: 6000,
        discountPercent: 40,
        imageUrl: 'https://picsum.photos/200',
      ),
    ];
  }

  static List<BookmarkModel> getBookmarks() {
    return [
      BookmarkModel(
        id: 1,
        serviceType: 'Service',
        serviceName: 'House Cleaning',
        providerName: 'John',
        imageUrl: 'https://picsum.photos/200',
        date: DateTime.now(),
        status: 'completed',
      ),

      BookmarkModel(
        id: 2,
        serviceType: 'Service',
        serviceName: 'Home Security Installation Services',
        providerName: 'David',
        imageUrl: 'https://picsum.photos/200',
        date: DateTime.now(),
        status: 'completed',
      ),

      BookmarkModel(
        id: 3,
        serviceType: 'Service',
        serviceName: 'Roof Cleaning Services',
        providerName: 'David',
        imageUrl: 'https://picsum.photos/200',
        date: DateTime.now(),
        status: 'completed',
      ),
    ];
  }

  static List<NotificationModel> getNotifications() {
    return [
      NotificationModel(
        id: 1,
        title: 'Payment Successful',
        message: 'You have made a service payment',
        type: 'payment',
        isRead: false,
        createdAt: DateTime.now(),
      ),

      NotificationModel(
        id: 2,
        title: 'Reminder',
        message: 'Your Booked service starts tomorrow',
        type: 'reminder',
        isRead: false,
        createdAt: DateTime.now(),
      ),

      NotificationModel(
        id: 3,
        title: 'Booking Confirmed',
        message: 'John accepted your booking request',
        type: 'booking',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),

      NotificationModel(
        id: 4,
        title: 'Service Completed',
        message: 'How was your experience with Joseph?',
        type: 'review',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  static Map<String, dynamic> mockLogin(String email, String password) {
    return {
      'status': 200,
      'message': 'Login successful',
      'token': 'mock_token_login',
      'user': {
        'id': 1,
        'first_name': 'John',
        'last_name': 'Doe',
        'email': email,
      },
    };
  }

  static Map<String, dynamic> mockRegister() {
    return {
      'status': 201,
      'message': 'Registration successful',
      'token': 'mock_token_register',
      'user': {'id': 1, 'first_name': 'John', 'last_name': 'Doe'},
    };
  }
}
