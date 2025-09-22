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
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Summary', style: TextStyle(fontSize: 20, color: green)),
            const SizedBox(height: 16),
            Card(
              color: Colors.black,
              child: ListTile(
                leading: Icon(Icons.shopping_cart, color: green),
                title: Text('Product Name', style: TextStyle(color: green)),
                subtitle: const Text('Quantity: 1', style: TextStyle(color: Colors.white)),
                trailing: Text('\$49.99', style: TextStyle(color: green)),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.black,
              child: ListTile(
                leading: Icon(Icons.local_shipping, color: green),
                title: Text('Shipping Address', style: TextStyle(color: green)),
                subtitle: const Text('123 Main St, City', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.black,
              child: ListTile(
                leading: Icon(Icons.payment, color: green),
                title: Text('Payment Method', style: TextStyle(color: green)),
                subtitle: const Text('Visa **** 1234', style: TextStyle(color: Colors.white)),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => initiatePayment(context),
              child: Text('Pay \$${amount.toStringAsFixed(2)}'),
            ),
          ],
        ),
      ),
    );
  }
}