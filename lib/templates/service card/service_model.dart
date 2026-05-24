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
    this.workerId,
    this.workerImage,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      title: json['title'] ?? 'Unknown',
      workerName: json['worker']?['first_name'] != null
          ? '${json['worker']['first_name']} ${json['worker']['last_name']}'
          : json['worker']?? 'Unknown',

      rating: json['worker']?['rating'] != null
          ? double.tryParse(json['worker']['rating'].toString()) ?? 0.0
          : 0.0,

      reviewCount: json['worker']?['review_count'] ?? 0,

      price: json['price'] != null
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,

      imageUrl: json['image_url'] ?? '',

      discountPercent: json['discount_percent'] != null
          ? double.tryParse(json['discount_percent'].toString())
          : null,

      category: json['category'],
      description: json['description'],
      workerId: json['worker_id'],
      workerImage: json['worker']?['profile_photo'],

      galleryImages: json['gallery_images'] != null
          ? List<String>.from(json['gallery_images'])
          : [],
    );
  }
}
