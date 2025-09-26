import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../state/cart_state.dart';
import '../../services/orders_service.dart';
import '../../services/store_service.dart';
import '../../services/payment_service.dart';
import '../../widgets/primary_cta.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Simple shipping fields
  String fullName = '';
  String phone = '';
  String addressLine1 = '';
  String city = '';
  String zip = '';

  bool placing = false;
  bool paying = false;
  final _couponCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAddress() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      fullName = p.getString('ship_fullName') ?? '';
      phone = p.getString('ship_phone') ?? '';
      addressLine1 = p.getString('ship_addressLine1') ?? '';
      city = p.getString('ship_city') ?? '';
      zip = p.getString('ship_zip') ?? '';
    });
  }

  Future<void> _saveAddress() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('ship_fullName', fullName);
    await p.setString('ship_phone', phone);
    await p.setString('ship_addressLine1', addressLine1);
    await p.setString('ship_city', city);
    await p.setString('ship_zip', zip);
  }

  Future<void> _placeOrder(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final cart = CartStateScope.of(context);
    if (cart.isEmpty) return;

    setState(() => placing = true);
    final items = cart.items
        .map((i) => {
              'productId': i.id,
              'name': i.name,
              'price': i.price,
              'quantity': i.quantity,
            })
        .toList();

    final payload = {
      'items': items,
      'total': cart.total,
      'shipping': {
        'fullName': fullName,
        'phone': phone,
        'addressLine1': addressLine1,
        'city': city,
        'zip': zip,
      },
      // Add payment method fields here when ready
    };

    try {
      await _saveAddress(); // persist address
      final order = await OrdersService().create(payload);
      final orderId = order['id']?.toString();
      cart.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully')),
      );
      if (orderId != null) {
        Navigator.pushReplacementNamed(
          context,
          '/order_details',
          arguments: {'id': orderId},
        );
      } else {
        Navigator.pushReplacementNamed(context, '/orders');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order')),
      );
    } finally {
      if (mounted) setState(() => placing = false);
    }
  }

  Future<void> _applyCoupon() async {
    final code = _couponCtrl.text.trim();
    if (code.isEmpty) return;
    final cart = CartStateScope.of(context);
    try {
      final res = await StoreService().validateCoupon(code: code, subtotal: cart.total);
      final amountOff = (res['amountOff'] as num?)?.toDouble() ??
          (res['discount'] as num?)?.toDouble() ??
          0.0;
      cart.applyCoupon(code: code, amountOff: amountOff);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coupon applied')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid coupon')));
      CartStateScope.of(context).clearCoupon();
    }
  }

  Future<void> _payNow() async {
    final cart = CartStateScope.of(context);
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }
    setState(() => paying = true);
    try {
      final total = cart.totalAfterDiscount; // uses coupon if applied
      await PaymentService().payWithSheet(
        amount: total,
        currency: 'usd',
        merchantCountryCode: 'US',
        merchantDisplayName: 'FitCoach',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful')));
      // Optional: clear cart if your CartState supports it
      try { cart.clear(); } catch (_) {}
      Navigator.pushReplacementNamed(context, '/orders');
    } on Exception catch (e) {
      if (!mounted) return;
      final code = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment canceled ($code)')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment failed')));
    } finally {
      if (mounted) setState(() => paying = false);
    }
  }

  Future<void> _payApple() async {
    final total = CartStateScope.of(context).totalAfterDiscount;
    setState(() => paying = true);
    try {
      await PaymentService().payWithApplePay(
        amount: total,
        currency: 'USD',
        merchantCountryCode: 'US',
        merchantDisplayName: 'FitCoach',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful')));
      try { CartStateScope.of(context).clear(); } catch (_) {}
      Navigator.pushReplacementNamed(context, '/orders');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Apple Pay failed or canceled')));
    } finally {
      if (mounted) setState(() => paying = false);
    }
  }

  Future<void> _payGoogle() async {
    final total = CartStateScope.of(context).totalAfterDiscount;
    setState(() => paying = true);
    try {
      await PaymentService().payWithGooglePay(
        amount: total,
        currency: 'USD',
        merchantCountryCode: 'US',
        merchantDisplayName: 'FitCoach',
        testEnv: true, // set false for production
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful')));
      try { CartStateScope.of(context).clear(); } catch (_) {}
      Navigator.pushReplacementNamed(context, '/orders');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google Pay failed or canceled')));
    } finally {
      if (mounted) setState(() => paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cart = CartStateScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Shipping Details', style: TextStyle(color: cs.primary, fontSize: 22)),
          const SizedBox(height: 8),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Full name',
                    labelStyle: TextStyle(color: cs.primary),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary.withOpacity(0.6))),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  onChanged: (v) => fullName = v.trim(),
                  initialValue: fullName, // prefill
                ),
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    labelStyle: TextStyle(color: cs.primary),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary.withOpacity(0.6))),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary)),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.trim().length < 7) ? 'Enter valid phone' : null,
                  onChanged: (v) => phone = v.trim(),
                  initialValue: phone,
                ),
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Address line 1',
                    labelStyle: TextStyle(color: cs.primary),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary.withOpacity(0.6))),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  onChanged: (v) => addressLine1 = v.trim(),
                  initialValue: addressLine1,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'City',
                          labelStyle: TextStyle(color: cs.primary),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary.withOpacity(0.6))),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary)),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        onChanged: (v) => city = v.trim(),
                        initialValue: city,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ZIP',
                          labelStyle: TextStyle(color: cs.primary),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary.withOpacity(0.6))),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary)),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        onChanged: (v) => zip = v.trim(),
                        initialValue: zip,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Discount code', style: TextStyle(color: cs.primary, fontSize: 16)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter coupon',
                    hintStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary.withOpacity(0.6))),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _applyCoupon, child: const Text('Apply')),
            ],
          ),
          const SizedBox(height: 12),
          // Order summary (use theme; no hardcoded colors)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order summary', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: cart.isEmpty
                        ? const Center(child: Text('Your cart is empty.', style: TextStyle(color: Colors.white70)))
                        : ListView.builder(
                            itemCount: cart.items.length,
                            itemBuilder: (context, index) {
                              final item = cart.items[index];
                              return ListTile(
                                title: Text(item.name, style: TextStyle(color: cs.primary)),
                                subtitle: Text('Quantity: ${item.quantity}', style: const TextStyle(color: Colors.white)),
                                trailing: Text('\$${item.price.toStringAsFixed(2)}', style: TextStyle(color: cs.primary)),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  if (cart.discount > 0)
                    Text('Subtotal: \$${cart.total.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white70, decoration: TextDecoration.lineThrough)),
                  Text(
                    'Total: \$${cart.totalAfterDiscount.toStringAsFixed(2)}',
                    style: TextStyle(color: cs.primary, fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Payment method selection (if any)
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary pay button (uses themed ElevatedButton)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: paying ? null : _payNow,
                child: Text(paying ? 'Processing…' : 'Pay now'),
              ),
            ),
            const SizedBox(height: 8),
            // Icon-only Apple/Google pay (themed, compact, side by side)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.apple, color: cs.primary),
                    label: const Text('Apple Pay'),
                    onPressed: paying ? null : _payApple,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.account_balance_wallet, color: cs.primary),
                    label: const Text('Google Pay'),
                    onPressed: paying ? null : _payGoogle,
                  ),
                ),
              ],
            ),
            if (paying)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}