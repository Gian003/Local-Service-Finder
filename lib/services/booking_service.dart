import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lsf/services/api_service.dart';
import 'response_handler.dart';
import 'auth_exception.dart';

class BookingService {
  // Step 1: Create Stripe PaymentIntent. The charge amount is computed
  // server-side from the Service price — the app has no say in what gets charged.
  static Future<String?> createPaymentIntent({
    required int serviceId,
  }) async {
    try {
      final response = await ApiService.postRequest('payment/intent', {
        'service_id': serviceId,
      }, auth: true);

      if (response.statusCode == 200) {
        try {
          final data = ResponseHandler.parseJson(response.body);
          final clientSecret = ResponseHandler.getString(data, 'client_secret');
          return clientSecret.isNotEmpty ? clientSecret : null;
        } on ApiException catch (e) {
          debugPrint('Parse error: ${e.message}');
          return null;
        }
      }
      return null;
    } on AuthException catch (e) {
      debugPrint('Auth error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Payment intent creation failed: $e');
      return null;
    }
  }

  // Step 2: Process Stripe payment. Returns the underlying PaymentIntent id
  // on success — the server needs this to verify the charge in confirmBooking
  // rather than just trusting that the app called it. Returns null if the
  // payment was cancelled or failed.
  static Future<String?> processStripePayment({
    required String clientSecret,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'lsf',
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // client_secret is always "{payment_intent_id}_secret_{secret}".
      return clientSecret.split('_secret_').first;
    } catch (e) {
      debugPrint('Stripe payment failed: $e');
      return null;
    }
  }

  // Step 3: Confirm booking in database. ApiService.postRequest attaches an
  // idempotency_key automatically — see its doc comment — which the server
  // uses to recognize "same attempt, response got lost" and return the
  // already-created booking instead of creating a duplicate.
  static Future<bool> confirmBooking({
    required int serviceId,
    required int workerId,
    required int addressId,
    required String scheduledAt,
    required double totalPrice,
    required String paymentMethod,
    String? paymentIntentId,
  }) async {
    try {
      final response = await ApiService.postRequest('booking/confirm', {
        'service_id': serviceId,
        'worker_id': workerId,
        'address_id': addressId,
        'scheduled_at': scheduledAt,
        'total_price': totalPrice,
        'payment_method': paymentMethod,
        'payment_intent_id': paymentIntentId,
      }, auth: true);

      if (response.statusCode == 201) {
        return true;
      }

      return false;
    } on AuthException catch (e) {
      debugPrint('Auth error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Booking confirmation failed: $e');
      return false;
    }
  }
}
