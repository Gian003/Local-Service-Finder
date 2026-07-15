import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lsf/services/api_service.dart';

/// Periodically reports the worker's GPS position to the backend while a
/// job is in progress, so the customer's tracking screen can show a live
/// marker + route line instead of a static pin. Call [start] when a booking
/// is accepted, [stop] when it's completed/cancelled/rejected (or when no
/// accepted bookings remain).
class WorkerLocationService {
  static Timer? _timer;

  static bool get isTracking => _timer != null;

  static Future<void> start({
    Duration interval = const Duration(seconds: 15),
  }) async {
    if (_timer != null) return; // already running

    if (!await _ensurePermission()) {
      debugPrint('WorkerLocationService: location permission not granted');
      return;
    }

    await _reportOnce();
    _timer = Timer.periodic(interval, (_) => _reportOnce());
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<void> _reportOnce() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      await ApiService.putRequest('worker-auth/location', {
        'latitude': position.latitude,
        'longitude': position.longitude,
      }, auth: true);
    } catch (e) {
      debugPrint('WorkerLocationService: failed to report location: $e');
    }
  }
}
