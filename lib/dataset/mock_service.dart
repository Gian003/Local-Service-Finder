import 'package:lsffend/templates/service%20card/service_model.dart';

class MockService {
  static List<ServiceModel> getServices() {
    return [
      ServiceModel(
        title: "title",
        workerName: "workerName",
        rating: 4.3,
        reviewCount: 500,
        price: 3000,
        discountPercent: 40,
        imageUrl: 'https://picsum.photos/200',
      ),
      ServiceModel(
        title: "title",
        workerName: "workerName",
        rating: 4.3,
        reviewCount: 500,
        price: 3000,
        discountPercent: 40,
        imageUrl: 'https://picsum.photos/200',
      ),
      ServiceModel(
        title: "title",
        workerName: "workerName",
        rating: 4.3,
        reviewCount: 500,
        price: 3000,
        discountPercent: 40,
        imageUrl: 'https://picsum.photos/200',
      ),
      ServiceModel(
        title: "title",
        workerName: "workerName",
        rating: 4.3,
        reviewCount: 500,
        price: 3000,
        discountPercent: 40,
        imageUrl: 'https://picsum.photos/200',
      ),
      ServiceModel(
        title: "title",
        workerName: "workerName",
        rating: 4.3,
        reviewCount: 500,
        price: 3000,
        discountPercent: 40,
        imageUrl: 'https://picsum.photos/200',
      ),
      ServiceModel(
        title: "title",
        workerName: "workerName",
        rating: 4.3,
        reviewCount: 500,
        price: 3000,
        discountPercent: 40,
        imageUrl: 'https://picsum.photos/200',
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
