import 'package:lsf/services/type_converter.dart';

class BookingModel {
  final int id;
  final String serviceName;
  final String workerName;
  final String? workerImage;
  final String date;
  final String time;
  final double totalPrice;
  final String status;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int? workerId;

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
    final scheduledAt = json['scheduled_at'];
    final date = TypeConverter.extractDate(scheduledAt, defaultValue: '');
    final time = TypeConverter.extractTime(scheduledAt, defaultValue: '');

    final latitude = json['latitude'];
    final longitude = json['longitude'];

    return BookingModel(
      id: TypeConverter.toInt(json['id']),
      serviceName: json['service']?['title']?.toString() ?? '',
      workerName: '${json['worker']?['first_name'] ?? ''} ${json['worker']?['last_name'] ?? ''}'.trim(),
      workerImage: json['worker']?['profile_photo']?.toString(),
      date: date,
      time: time,
      totalPrice: TypeConverter.toDouble(json['total_price'], defaultValue: 0.0),
      status: json['status']?.toString() ?? 'pending',
      address: json['address']?['address']?.toString(),
      latitude: latitude != null ? TypeConverter.toDouble(latitude) : null,
      longitude: longitude != null ? TypeConverter.toDouble(longitude) : null,
      workerId: TypeConverter.toInt(json['worker_id']),
    );
  }
}