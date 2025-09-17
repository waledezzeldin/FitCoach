import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:stripe_payment/stripe_payment.dart';

class CheckoutScreen extends StatelessWidget {
  final double amount;
  final String userId;
  final String orderId;
  const CheckoutScreen({super.key, required this.amount, required this.userId, required this.orderId});

  Future<void> initiatePayment(BuildContext context) async {
    try {
      final response = await Dio().post(
        'http://localhost:3000/api/payments',
        data: {
          'userId': userId,
          'orderId': orderId,
          'amount': amount,
          'provider': 'stripe',
        },
      );
      final clientSecret = response.data['clientSecret'];

      // Initialize Stripe (do this once, e.g. in main.dart)
      StripePayment.setOptions(
        StripeOptions(
          publishableKey: "YOUR_STRIPE_PUBLISHABLE_KEY",
          merchantId: "Test",
          androidPayMode: 'test',
        ),
      );

      // Present payment sheet
      PaymentMethod paymentMethod = await StripePayment.paymentRequestWithCardForm(
        CardFormPaymentRequest(),
      );

      PaymentIntentResult paymentIntent = await StripePayment.confirmPaymentIntent(
        PaymentIntent(
          clientSecret: clientSecret,
          paymentMethodId: paymentMethod.id,
        ),
      );

      if (paymentIntent.status == 'succeeded') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment status: ${paymentIntent.status}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => initiatePayment(context),
          child: Text('Pay \$${amount.toStringAsFixed(2)}'),
        ),
      ),
    );
  }
}