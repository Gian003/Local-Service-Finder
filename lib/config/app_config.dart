// Pass secrets at build time:
//   flutter run --dart-define-from-file=.env
//   flutter build apk --dart-define-from-file=.env
// Copy .env.example to .env and fill in your values.
class AppConfig {
  static const String baseUrl = 'http://192.168.1.5:8000/api';
  static const bool offlineMode = false;

  // Flip to true for presentations/demos: card payments skip Stripe's
  // hosted payment sheet and confirm instantly with a Stripe test card,
  // so the credit-card flow can be shown end-to-end without entering a
  // real card or hitting any Stripe UI. Only works against a test-mode
  // secret key on the backend — flip back to false for real testing.
  static const bool demoCardPayments = false;

  // Flip to true for presentations/demos: the worker app reports a
  // simulated position approaching the customer's address instead of real
  // GPS, so live tracking can be demoed by one person without anyone
  // actually walking around. Flip back to false for real GPS testing.
  static const bool demoWorkerMovement = true;

  static const String pusherKey =
      String.fromEnvironment('PUSHER_KEY');
  static const String pusherCluster =
      String.fromEnvironment('PUSHER_CLUSTER', defaultValue: 'ap1');
  static const String stripePublishableKey =
      String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
  static const String googleMapsApiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY');
}
