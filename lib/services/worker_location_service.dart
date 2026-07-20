import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lsf/config/app_config.dart';
import 'package:lsf/services/api_service.dart';

/// Periodically reports the worker's GPS position to the backend while a
/// job is in progress, so the customer's tracking screen can show a live
/// marker + route line instead of a static pin. Call [start] when a booking
/// is accepted, [stop] when it's completed/cancelled/rejected (or when no
/// accepted bookings remain).
class WorkerLocationService {
  static Timer? _timer;
  static LatLng? _simStart;
  static LatLng? _simDestination;
  static int _simStep = 0;
  static const int _simTotalSteps = 14;

  static bool get isTracking => _timer != null;

  // Pass [destination] (the customer's address) so demo mode has somewhere
  // to simulate approaching — see AppConfig.demoWorkerMovement. Ignored
  // when demo mode is off.
  static Future<void> start({
    Duration interval = const Duration(seconds: 15),
    LatLng? destination,
  }) async {
    if (_timer != null) return; // already running

    if (AppConfig.demoWorkerMovement && destination != null) {
      _startSimulated(destination);
      return;
    }

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
    _simStart = null;
    _simDestination = null;
    _simStep = 0;
  }

  // Demo mode for presentations: simulates the worker approaching the
  // customer's address over a series of quick ticks instead of reading real
  // GPS, so live tracking can be shown without two people actually walking
  // around. The customer's tracking screen needs no changes — it just reads
  // whatever position gets reported here, real or simulated.
  static void _startSimulated(LatLng destination) {
    final random = Random();
    // Start ~1.5-3km away in a pseudo-random direction so the approach is
    // visible on the map rather than starting right on top of the pin.
    final angle = random.nextDouble() * 2 * pi;
    final distanceDegrees = 0.014 + random.nextDouble() * 0.014;
    _simStart = LatLng(
      destination.latitude + distanceDegrees * cos(angle),
      destination.longitude + distanceDegrees * sin(angle),
    );
    _simDestination = destination;
    _simStep = 0;

    _reportSimulatedTick();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _reportSimulatedTick(),
    );
  }

  static Future<void> _reportSimulatedTick() async {
    final start = _simStart;
    final destination = _simDestination;
    if (start == null || destination == null) return;

    final t = (_simStep / _simTotalSteps).clamp(0.0, 1.0);
    final lat = start.latitude + (destination.latitude - start.latitude) * t;
    final lng = start.longitude + (destination.longitude - start.longitude) * t;

    if (_simStep >= _simTotalSteps) {
      _timer?.cancel();
      _timer = null;
    } else {
      _simStep++;
    }

    try {
      await ApiService.putRequest('worker-auth/location', {
        'latitude': lat,
        'longitude': lng,
      }, auth: true);
    } catch (e) {
      debugPrint(
        'WorkerLocationService: failed to report simulated location: $e',
      );
    }
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
