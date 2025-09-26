import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../state/app_state.dart';
import '../../config/env.dart'; // ADDED

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String password2 = '';
  bool isLoading = false;
  String? error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      // DEMO MODE: bypass real signup and go directly to intake
      if (Env.demo) {
        await AppStateScope.of(context).signIn(
          subscription: 'freemium',
          user: {
            'id': 'demo_user',
            'email': email.trim(),
            'role': 'user',
            'demo': true,
          },
        );
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/intake'); // ALWAYS go to intake
        return;
      }

      final data = await AuthService().signup(email.trim(), password.trim());
      await AppStateScope.of(context).signIn(subscription: 'freemium', user: data);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/intake'); // real signup -> intake
    } catch (e) {
      setState(() => error = 'Signup failed');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24),
          Center(
            child: Image.asset(
              'assets/branding/logo.png',
              width: 90,
              height: 90,
              semanticLabel: 'FitCoach',
            ),
          ),
          const SizedBox(height: 24),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(error!, style: TextStyle(color: cs.error)),
            ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Email is required';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) return 'Enter a valid email';
                    return null;
                  },
                  onChanged: (v) => email = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                  onChanged: (v) => password = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Confirm password'),
                  obscureText: true,
                  validator: (v) => v != password ? 'Passwords do not match' : null,
                  onChanged: (v) => password2 = v,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(Env.demo ? 'Enter Demo' : 'Sign Up'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.phone),
                  label: const Text('Sign up with Phone'),
                  onPressed: isLoading ? null : () => Navigator.pushNamed(context, '/phone_login'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: Text('Already have an account? Sign in', style: TextStyle(color: cs.primary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
