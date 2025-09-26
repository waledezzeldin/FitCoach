import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  bool isLoading = false;
  String? error;
  String? info;

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      error = null;
      info = null;
    });
    try {
      await AuthService().forgotPassword(email);
      setState(() => info = 'OTP sent to $email');
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/reset_password',
        arguments: {'email': email},
      );
    } catch (e) {
      setState(() => error = 'Failed to send OTP');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
              if (info != null) Text(info!, style: TextStyle(color: green)),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: green),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: green)),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Email is required';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) return 'Enter a valid email';
                  return null;
                },
                onChanged: (val) => setState(() => email = val),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _sendOtp,
                child: isLoading ? const CircularProgressIndicator() : const Text('Send OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}