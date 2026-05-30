import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lsf/services/api_service.dart';
import 'response_handler.dart';
import 'auth_exception.dart';

class BookingService {
  // Step 1: Create Stripe PaymentIntent
  static Future<String?> createPaymentIntent({
    required int amount, // in centavos e.g. 150000
    required int serviceId,
  }) async {
    try {
      final response = await ApiService.postRequest('payment/intent', {
        'amount': amount,
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

  // Step 2: Process Stripe payment
  static Future<bool> processStripePayment({
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
      return true; // payment success
    } catch (e) {
      debugPrint('Stripe payment failed: $e');
      return false; // payment cancelled or failed
    }
  }

  // Step 3: Confirm booking in database
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
        try {
          final data = ResponseHandler.parseJson(response.body);
          debugPrint('Booking confirmed: ${data['id'] ?? 'unknown'}');
          return data['booking'];
        } on ApiException catch (e) {
          debugPrint('Parse error: ${e.message}');
          return false;
        }
      }

      debugPrint('Booking confirmation failed: status ${response.statusCode}');
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
