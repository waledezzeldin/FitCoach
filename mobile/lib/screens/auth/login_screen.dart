import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  Future<void> _signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? account = await GoogleSignIn.instance.attemptLightweightAuthentication();
    if (account != null) {
      // Send account info to backend for authentication
      // Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      // Send result.accessToken to backend for authentication
      // Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Handle email/password login
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', width: 80),
                const SizedBox(height: 32),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: green),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: green),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Email is required';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) return 'Enter a valid email';
                    return null;
                  },
                  onChanged: (val) => setState(() => email = val),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: green),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: green),
                    ),
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  validator: (val) => val == null || val.isEmpty ? 'Password is required' : null,
                  onChanged: (val) => setState(() => password = val),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Sign In'),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: Text('Don\'t have an account? Sign up', style: TextStyle(color: green)),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                  label: const Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(backgroundColor: green),
                  onPressed: () => _signInWithGoogle(context),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.facebook, color: Colors.white),
                  label: const Text('Sign in with Facebook'),
                  style: ElevatedButton.styleFrom(backgroundColor: green),
                  onPressed: () => _signInWithFacebook(context),
                ),
                // Add Apple and phone sign-in buttons here
              ],
            ),
          ),
        ),
      ),
    );
  }
}
