class ServiceModel {
  final String title;
  final String workerName;
  final double rating;
  final int reviewCount;
  final double price;
  final String imageUrl;
  final double? discountPercent;

  const ServiceModel({
    required this.title,
    required this.workerName,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.imageUrl,
    this.discountPercent,
  });
}
