import 'package:connectivity_plus/connectivity_plus.dart';

/// Reports whether the device currently has a network interface up
/// (WiFi/mobile data). This doesn't guarantee the interface actually reaches
/// the internet (e.g. WiFi with no upstream), but it's enough to distinguish
/// "definitely offline" from "probably online" for the offline-mode banner
/// and read-through cache fallback.
class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();

  static Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  static Stream<bool> get onStatusChange {
    return _connectivity.onConnectivityChanged.map(
      (results) => results.any((result) => result != ConnectivityResult.none),
    );
  }
}
