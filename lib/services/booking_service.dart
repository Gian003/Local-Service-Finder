import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lsffend/services/api_service.dart';

class BookingService {
  // Step 1: Create Stripe PaymentIntent
  static Future<String?> createPaymentIntent({
    required int amount,     // in centavos e.g. 150000
    required int serviceId,
  }) async {
    final response = await ApiService.postRequest(
      '/payment/intent',
      {
        'amount'    : amount,
        'service_id': serviceId,
      },
      auth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['client_secret'];
    }
    return null;
  }

  // Step 2: Process Stripe payment
  static Future<bool> processStripePayment({
    required String clientSecret,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName:       'LSFFend',
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true; // payment success
    } catch (e) {
      return false; // payment cancelled or failed
    }
  }

  // Step 3: Confirm booking in database
  static Future<bool> confirmBooking({
    required int    serviceId,
    required int    workerId,
    required int    addressId,
    required String scheduledAt,
    required double totalPrice,
    required String paymentMethod,
    String?         paymentIntentId,
  }) async {
    final response = await ApiService.postRequest(
      '/booking/confirm',
      {
        'service_id'        : serviceId,
        'worker_id'         : workerId,
        'address_id'        : addressId,
        'scheduled_at'      : scheduledAt,
        'total_price'       : totalPrice,
        'payment_method'    : paymentMethod,
        'payment_intent_id' : paymentIntentId,
      },
      auth: true,
    );

    return response.statusCode == 201;
  }
}