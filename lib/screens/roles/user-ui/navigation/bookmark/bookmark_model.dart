class BookmarkModel{
  final int id;
  final String serviceType;
  final String serviceName;
  final String providerName;
  final String imageUrl;
  final DateTime? date;
  final String time;
  final double price;
  final String status;

  const BookmarkModel ({
    required this.id,
    required this.serviceType,
    required this.serviceName,
    required this.providerName,
    required this.imageUrl,
    required this.date,
    this.time = '',
    this.price = 0,
    required this.status,
  });
}