import 'package:lsf/services/type_converter.dart';

class ReviewModel {
  final int id;
  final double rating;
  final String? comment;
  final String userName;
  final String? userImage;
  final DateTime? createdAt;

  const ReviewModel({
    required this.id,
    required this.rating,
    this.comment,
    required this.userName,
    this.userImage,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final firstName = user?['first_name']?.toString() ?? '';
    final lastName = user?['last_name']?.toString() ?? '';
    final userName = firstName.isNotEmpty || lastName.isNotEmpty
        ? '$firstName $lastName'.trim()
        : 'Anonymous';

    return ReviewModel(
      id: TypeConverter.toInt(json['id']),
      rating: TypeConverter.toDouble(json['rating'], defaultValue: 0.0),
      comment: json['comment']?.toString(),
      userName: userName,
      userImage: user?['profile_photo']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
