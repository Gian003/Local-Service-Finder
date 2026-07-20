import 'package:lsf/services/type_converter.dart';

class ServiceModel {
  final int? id;
  final String title;
  final String workerName;
  final double rating;
  final int reviewCount;
  final double price;
  final String imageUrl;
  final double? discountPercent;
  final String? category;
  final String? description;
  final List<String>? galleryImages;
  final String? videoUrl;
  final int? workerId;
  final String? workerImage;

  const ServiceModel({
    this.id,
    required this.title,
    required this.workerName,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.imageUrl,
    this.discountPercent,
    this.category,
    this.description,
    this.galleryImages,
    this.videoUrl,
    this.workerId,
    this.workerImage,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final worker = json['worker'] as Map<String, dynamic>?;
    final firstName = worker?['first_name']?.toString() ?? '';
    final lastName = worker?['last_name']?.toString() ?? '';
    final workerName = firstName.isNotEmpty || lastName.isNotEmpty
        ? '$firstName $lastName'.trim()
        : 'Unknown';

    final galleryImages = json['gallery_images'];
    final gallery = galleryImages is List
        ? galleryImages.map((e) => e.toString()).toList()
        : <String>[];

    return ServiceModel(
      id: TypeConverter.toInt(json['id']),
      title: TypeConverter.makeString(json['title'], defaultValue: 'Unknown'),
      workerName: workerName,
      rating: TypeConverter.toDouble(worker?['rating'], defaultValue: 0.0),
      reviewCount: TypeConverter.toInt(worker?['review_count'], defaultValue: 0),
      price: TypeConverter.toDouble(json['price'], defaultValue: 0.0),
      imageUrl: TypeConverter.makeString(json['image_url'], defaultValue: ''),
      discountPercent: json['discount_percent'] != null
          ? TypeConverter.toDouble(json['discount_percent'])
          : null,
      category: json['category']?.toString(),
      description: json['description']?.toString(),
      workerId: TypeConverter.toInt(json['worker_id']),
      workerImage: worker?['profile_photo']?.toString(),
      galleryImages: gallery.isNotEmpty ? gallery : null,
      videoUrl: json['video_url']?.toString(),
    );
  }
}
