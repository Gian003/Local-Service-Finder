import 'package:lsf/models/booking_model.dart';
import 'package:lsf/screens/roles/user-ui/navigation/bookmark/bookmark_model.dart';
import 'package:lsf/screens/roles/user-ui/navigation/home/notification/notification_model.dart';
import 'package:lsf/templates/service%20card/service_model.dart';

class MockService {
  static List<ServiceModel> getServices() {
    return [
      ServiceModel(
        id: 1,
        title: "House Cleaning",
        workerName: "John Reyes",
        rating: 6.3,
        reviewCount: 600,
        price: 1000,
        imageUrl: 'https://picsum.photos/200',
        discountPercent: 40,
        category: 'cleaning',
        description: 'This is a description of the service.',
        galleryImages: [
          'https://picsum.photos/200',
          'https://picsum.photos/200',
          'https://picsum.photos/200',
        ],
      ),

      ServiceModel(
        id: 2,
        title: "Plumbing Repair",
        workerName: "Joseph Santos",
        rating: 5.3,
        reviewCount: 500,
        price: 2000,
        imageUrl: 'https://picsum.photos/200',
        discountPercent: 40,
        category: 'cleaning',
        description: 'This is a description of the service.',
        galleryImages: [
          'https://picsum.photos/200',
          'https://picsum.photos/200',
          'https://picsum.photos/200',
        ],
      ),

      ServiceModel(
        id: 3,
        title: "House Painting",
        workerName: "Michael Brown",
        rating: 4.3,
        reviewCount: 400,
        price: 3000,
        imageUrl: 'https://picsum.photos/200',
        discountPercent: 40,
        category: 'cleaning',
        description: 'This is a description of the service.',
        galleryImages: [
          'https://picsum.photos/200',
          'https://picsum.photos/200',
          'https://picsum.photos/200',
        ],
      ),

      ServiceModel(
        id: 4,
        title: "Janitorial Services",
        workerName: "Emily Davis",
        rating: 3.3,
        reviewCount: 300,
        price: 4000,
        imageUrl: 'https://picsum.photos/200',
        discountPercent: 40,
        category: 'cleaning',
        description: 'This is a description of the service.',
        galleryImages: [
          'https://picsum.photos/200',
          'https://picsum.photos/200',
          'https://picsum.photos/200',
        ],
      ),

      ServiceModel(
        id: 5,
        title: "Gardening Services",
        workerName: "Jessica Wilson",
        rating: 2.3,
        reviewCount: 200,
        price: 5000,
        imageUrl: 'https://picsum.photos/200',
        discountPercent: 40,
        category: 'cleaning',
        description: 'This is a description of the service.',
        galleryImages: [
          'https://picsum.photos/200',
          'https://picsum.photos/200',
          'https://picsum.photos/200',
        ],
      ),

      ServiceModel(
        id: 6,
        title: "Roof Cleaning Services",
        workerName: "David Lee",
        rating: 1.3,
        reviewCount: 100,
        price: 6000,
        imageUrl: 'https://picsum.photos/200',
        discountPercent: 40,
        category: 'cleaning',
        description: 'This is a description of the service.',
        galleryImages: [
          'https://picsum.photos/200',
          'https://picsum.photos/200',
          'https://picsum.photos/200',
        ],
      ),
    ];
  }

  static List<Map<String, dynamic>> getReviews(int serviceId) {
    return [
      {
        'id': 1,
        'user_name': 'John Doe',
        'user_image': 'https://picsum.photos/200',
        'rating': 4.5,
        'comment': 'Great service! Highly recommend.',
        'date': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': 2,
        'user_name': 'Jane Smith',
        'user_image': 'https://picsum.photos/200',
        'rating': 4.0,
        'comment': 'Good service, but could be faster.',
        'date': DateTime.now().subtract(const Duration(days: 2)),
      },

      {
        'id': 3,
        'user_name': 'Michael Brown',
        'user_image': 'https://picsum.photos/200',
        'rating': 5.0,
        'comment': 'Excellent service! Will use again.',
        'date': DateTime.now().subtract(const Duration(days: 3)),
      },
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

  static final List<BookingModel> _bookings = [];

  static List<BookingModel> getBookings() => _bookings;

  static void addBooking(BookingModel booking) {
    _bookings.add(booking);
  }
}
