// Pass secrets at build time:
//   flutter run --dart-define-from-file=.env
//   flutter build apk --dart-define-from-file=.env
// Copy .env.example to .env and fill in your values.
class AppConfig {
  static const String baseUrl = 'http://192.168.1.3:8000/api';
  static const bool offlineMode = false;

  static const String pusherKey =
      String.fromEnvironment('PUSHER_KEY');
  static const String pusherCluster =
      String.fromEnvironment('PUSHER_CLUSTER', defaultValue: 'ap1');
  static const String stripePublishableKey =
      String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
  static const String googleMapsApiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY');
}
