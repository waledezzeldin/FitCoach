import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String otp = '';
  String newPassword = '';
  String rePassword = '';
  bool isLoading = false;
  String? error;
  String? info;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['email'] is String) {
      email = args['email'] as String;
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { isLoading = true; error = null; info = null; });
    try {
      await AuthService().resetPassword(email: email, otp: otp, newPassword: newPassword);
      setState(() => info = 'Password changed successfully');
      if (!mounted) return;
      Navigator.popUntil(context, ModalRoute.withName('/login'));
    } catch (e) {
      setState(() => error = 'Failed to reset password. Check OTP.');
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
        title: const Text('Reset Password'),
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
                initialValue: email.isNotEmpty ? email : null,
                readOnly: email.isNotEmpty,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: green),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: green)),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (val) {
                  if (email.isNotEmpty) return null;
                  if (val == null || val.isEmpty) return 'Email is required';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) return 'Enter a valid email';
                  return null;
                },
                onChanged: (val) => setState(() => email = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'OTP Code',
                  labelStyle: TextStyle(color: green),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: green)),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (val) => val == null || val.isEmpty ? 'OTP is required' : null,
                onChanged: (val) => setState(() => otp = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: green),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: green)),
                ),
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                validator: (val) => val == null || val.length < 6 ? 'Min 6 characters' : null,
                onChanged: (val) => setState(() => newPassword = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Re-enter New Password',
                  labelStyle: TextStyle(color: green),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: green)),
                ),
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                validator: (val) => val != newPassword ? 'Passwords do not match' : null,
                onChanged: (val) => setState(() => rePassword = val),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _resetPassword,
                child: isLoading ? const CircularProgressIndicator() : const Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}