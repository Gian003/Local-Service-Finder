class BookingModel {
  final int     id;
  final String  serviceName;
  final String  workerName;
  final String? workerImage;
  final String  date;
  final String  time;
  final double  totalPrice;
  final String  status;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int?    workerId;

  const BookingModel({
    required this.id,
    required this.serviceName,
    required this.workerName,
    this.workerImage,
    required this.date,
    required this.time,
    required this.totalPrice,
    required this.status,
    this.address,
    this.latitude,
    this.longitude,
    this.workerId,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id:          json['id'],
      serviceName: json['service']?['title'] ?? '',
      workerName:  json['worker']?['name']   ?? '',
      workerImage: json['worker']?['profile_photo'],
      date:        json['scheduled_at']?.toString().split(' ')[0] ?? '',
      time:        json['scheduled_at']?.toString().split(' ')[1] ?? '',
      totalPrice:  double.parse(json['total_price'].toString()),
      status:      json['status'] ?? 'pending',
      address:     json['address']?['address'],
      latitude:    json['latitude']  != null
          ? double.parse(json['latitude'].toString())
          : null,
      longitude:   json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : null,
      workerId:    json['worker_id'],
    );
  }
}