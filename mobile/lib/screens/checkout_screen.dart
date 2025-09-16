import 'package:flutter/material.dart';

class ApiService {
  // Existing methods and properties

  Future<Map<String, dynamic>> createCheckoutSession(int amount) async {
    // Replace with your actual API call logic
    // For demonstration, returning a dummy URL
    await Future.delayed(Duration(seconds: 1));
    return {"url": "https://checkout.example.com/session?amount=$amount"};
  }
}

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final api = ApiService();
  String? checkoutUrl;

  Future<void> _createCheckout() async {
    final data = await api.createCheckoutSession(5000);
    setState(() {
      checkoutUrl = data["url"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Checkout")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _createCheckout,
              child: Text("Buy Supplement (\$50)"),
            ),
            if (checkoutUrl != null) Text("Open in browser: $checkoutUrl"),
          ],
        ),
      ),
    );
  }
}
