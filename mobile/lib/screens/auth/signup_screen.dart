import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  String rePassword = '';
  String role = 'user';

  Future<void> _signUpWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? account = await GoogleSignIn.instance.attemptLightweightAuthentication();
    if (account != null) {
      // Send account info to backend for registration
      // Navigator.pushReplacementNamed(context, '/intake');
    }
  }

  Future<void> _signUpWithFacebook(BuildContext context) async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      // Send result.accessToken to backend for registration
      // Navigator.pushReplacementNamed(context, '/intake');
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Handle email/password signup
      Navigator.pushReplacementNamed(context, '/intake');
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
                    labelText: 'Name',
                    labelStyle: TextStyle(color: green),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: green),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                  onChanged: (val) => setState(() => name = val),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Re-enter Password',
                    labelStyle: TextStyle(color: green),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: green),
                    ),
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  validator: (val) => val != password ? 'Passwords do not match' : null,
                  onChanged: (val) => setState(() => rePassword = val),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: InputDecoration(
                    labelText: 'Sign up as',
                    labelStyle: TextStyle(color: green),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: green),
                    ),
                  ),
                  dropdownColor: Colors.black,
                  items: [
                    DropdownMenuItem(value: 'user', child: Text('User', style: TextStyle(color: green))),
                    DropdownMenuItem(value: 'coach', child: Text('Coach', style: TextStyle(color: green))),
                  ],
                  onChanged: (val) => setState(() => role = val ?? 'user'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Sign Up'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Already have an account? Sign in', style: TextStyle(color: green)),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                  label: const Text('Sign up with Google'),
                  style: ElevatedButton.styleFrom(backgroundColor: green),
                  onPressed: () => _signUpWithGoogle(context),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.facebook, color: Colors.white),
                  label: const Text('Sign up with Facebook'),
                  style: ElevatedButton.styleFrom(backgroundColor: green),
                  onPressed: () => _signUpWithFacebook(context),
                ),
                // Add Apple and phone sign-up buttons here
              ],
            ),
          ),
        ),
      ),
    );
  }
}
