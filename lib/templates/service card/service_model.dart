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
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      title: json['title'],
      workerName: json['worker']?['name'] ?? 'Unknwon Worker',
      rating: double.parse(json['worker']?['rating'].toString() ?? '0.0'),
      reviewCount: json['worker']?['review_count'] ?? 0,
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'] ?? '',
      discountPercent: json['discount_percent'] != null
          ? double.parse(json['discount_person'].toString())
          : null,
      category: json['category'],
    );
  }
}
