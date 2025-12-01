import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'api_service.dart';
import '../config/env.dart';
import '../demo/demo_data.dart';
import '../models/quota_models.dart';

class SubscriptionService {
  final _api = ApiService();

  Future<Map<String, dynamic>> current() async {
    if (Env.demo) return DemoData.currentSub();
    final res = await _api.dio.get('/billing/subscription');
    return (res.data as Map).cast<String, dynamic>();
  }

  Future<List<Map<String, dynamic>>> plans() async {
    if (Env.demo) return List<Map<String, dynamic>>.from(DemoData.plans);
    final res = await _api.dio.get('/billing/plans');
    return (res.data as List).cast<Map<String, dynamic>>();
  }

  Future<void> subscribe(String planId, {String merchantCountryCode = 'US', String merchantDisplayName = 'FitCoach'}) async {
    // 1) SetupIntent from backend
    final si = await _api.dio.post('/billing/setup-intent');
    final data = (si.data as Map).cast<String, dynamic>();
    final clientSecret = (data['clientSecret'] ?? data['setupIntentClientSecret'] ?? '').toString();
    final pk = (data['publishableKey'] ?? '').toString();

    if (pk.isNotEmpty && Stripe.publishableKey != pk) {
      Stripe.publishableKey = pk;
    }
    if (Stripe.publishableKey.isEmpty) {
      throw StateError('Stripe publishable key is not set.');
    }
    if (clientSecret.isEmpty) {
      throw StateError('Missing SetupIntent client secret.');
    }

    // 2) Present PaymentSheet in setup mode
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        setupIntentClientSecret: clientSecret,
        merchantDisplayName: merchantDisplayName,
        style: ThemeMode.dark,
        allowsDelayedPaymentMethods: true,
        applePay: PaymentSheetApplePay(merchantCountryCode: merchantCountryCode),
        googlePay: PaymentSheetGooglePay(merchantCountryCode: merchantCountryCode),
      ),
    );
    await Stripe.instance.presentPaymentSheet();

    // 3) Create subscription on backend
    await _api.dio.post('/billing/subscribe', data: {'planId': planId});
  }

  Future<void> cancel() async {
    await _api.dio.post('/billing/cancel');
  }

  Future<SubscriptionTier> changeTier(String userId, SubscriptionTier nextTier) async {
    if (Env.demo) {
      return nextTier;
    }
    await _api.dio.post('/v1/subscription/tier', data: {
      'userId': userId,
      'tier': nextTier.apiValue,
    });
    return nextTier;
  }
}