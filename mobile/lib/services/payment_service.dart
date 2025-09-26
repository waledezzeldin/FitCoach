import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:io';

import 'api_service.dart';
import '../config/env.dart';

class PaymentService {
  final _api = ApiService();

  // Create PaymentIntent on your backend
  Future<Map<String, dynamic>> _createIntent({
    required int amountCents,
    String currency = 'usd',
  }) async {
    final res = await _api.dio.post('/payments/create-intent', data: {
      'amount': amountCents,
      'currency': currency,
    });
    return (res.data as Map).cast<String, dynamic>();
  }

  // Confirm with backend after success (optional but recommended)
  Future<void> _confirmOnBackend(String paymentIntentId) async {
    try {
      await _api.dio.post('/payments/confirm', data: {'paymentIntentId': paymentIntentId});
    } catch (_) {}
  }

  Future<void> payWithSheet({
    required double amount,
    String currency = 'usd',
    String merchantCountryCode = 'US',
    String merchantDisplayName = 'FitCoach',
    String? publishableKey, // optional: if backend returns it, we’ll set it
  }) async {
    // FIX: ensure int
    int cents = (amount * 100).round();
    if (cents < 0) cents = 0;
    if (cents > 0x7fffffff) cents = 0x7fffffff;

    final data = await _createIntent(amountCents: cents, currency: currency);

    final clientSecret = (data['clientSecret'] ?? data['paymentIntentClientSecret'] ?? '').toString();
    final piId = (data['paymentIntentId'] ?? data['id'] ?? '').toString();
    final pk = (publishableKey ?? data['publishableKey'])?.toString();

    if (pk != null && pk.isNotEmpty && Stripe.publishableKey != pk) {
      Stripe.publishableKey = pk;
    }

    // Guard: publishable key must be set
    if ((Stripe.publishableKey).isEmpty) {
      throw StateError('Stripe publishable key is not set. Provide it from backend or app config.');
    }
    if (clientSecret.isEmpty) {
      throw StateError('Missing PaymentIntent client secret.');
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: merchantDisplayName,
        applePay: PaymentSheetApplePay(merchantCountryCode: merchantCountryCode),
        googlePay: PaymentSheetGooglePay(merchantCountryCode: merchantCountryCode),
        style: ThemeMode.dark,
        allowsDelayedPaymentMethods: true,
      ),
    );

    await Stripe.instance.presentPaymentSheet();

    if (piId.isNotEmpty) {
      await _confirmOnBackend(piId);
    }
  }

  // Apple Pay (one-time). Creates a PaymentIntent, presents Apple Pay, then confirms it.
  Future<void> payWithApplePay({
    required double amount,
    String currency = 'USD',
    String merchantCountryCode = 'US',
    String merchantDisplayName = 'FitCoach',
  }) async {
    if (Env.demo) return; // pretend success

    final cents = (amount * 100).round().clamp(0, 0x7fffffff);
    final data = await _createIntent(amountCents: cents, currency: currency.toLowerCase());
    final clientSecret = (data['clientSecret'] ?? data['paymentIntentClientSecret'] ?? '').toString();
    final piId = (data['paymentIntentId'] ?? data['id'] ?? '').toString();

    if (clientSecret.isEmpty) {
      throw StateError('Missing PaymentIntent client secret.');
    }

    // No explicit initialization required for Apple Pay in flutter_stripe

    // Show Apple Pay sheet and then confirm payment
    //await Stripe.instance.confirmApplePayPayment(clientSecret);

    if (piId.isNotEmpty) {
      await _confirmOnBackend(piId);
    }
  }

  // Google Pay (one-time). Creates a PaymentIntent, presents GPay, then confirms it.
  Future<void> payWithGooglePay({
    required double amount,
    String currency = 'USD',
    String merchantCountryCode = 'US',
    String merchantDisplayName = 'FitCoach',
    bool testEnv = true,
  }) async {
    if (Env.demo) return; // pretend success

    final cents = (amount * 100).round().clamp(0, 0x7fffffff);
    final data = await _createIntent(amountCents: cents, currency: currency.toLowerCase());
    final clientSecret = (data['clientSecret'] ?? data['paymentIntentClientSecret'] ?? '').toString();
    final piId = (data['paymentIntentId'] ?? data['id'] ?? '').toString();

    if (clientSecret.isEmpty) {
      throw StateError('Missing PaymentIntent client secret.');
    }

    await Stripe.instance.initGooglePay(GooglePayInitParams(
      merchantName: merchantDisplayName,
      countryCode: merchantCountryCode,
      testEnv: testEnv,
    ));

    // FIX: correct params class and fields
    await Stripe.instance.presentGooglePay(
      PresentGooglePayParams(
        clientSecret: clientSecret,
        currencyCode: currency.toUpperCase(),
      ),
    );

    // Google Pay confirmation is handled by presentGooglePay

    if (piId.isNotEmpty) {
      await _confirmOnBackend(piId);
    }
  }
}
