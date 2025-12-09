import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/auth/auth_state.dart';
import 'package:fitcoach/app.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _LoginMode { choice, email }

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  _LoginMode _mode = _LoginMode.choice;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image or color overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login_bg.jpg'), // Replace with your background asset or use a color
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and subtitle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.fitness_center, color: Colors.black, size: 36),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'FitCoach+',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your personal fitness journey',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 24),
                  // Card
                  Container(
                    width: 380,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _mode == _LoginMode.choice
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Welcome back',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign in to your account to continue',
                                style: TextStyle(fontSize: 15, color: Colors.black54),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.email_outlined),
                                label: const Text('Continue with Email'),
                                onPressed: () => setState(() => _mode = _LoginMode.email),
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.phone_outlined),
                                label: const Text('Continue with Phone'),
                                onPressed: () => context.push('/auth_phone'),
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(child: Divider()),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('or'),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.g_mobiledata, size: 32),
                                    onPressed: () => context.go('/quickstart/1'),
                                    tooltip: 'Continue with Google',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.facebook, size: 28),
                                    onPressed: () => context.go('/quickstart/1'),
                                    tooltip: 'Continue with Facebook',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.apple, size: 28),
                                    onPressed: () => context.go('/quickstart/1'),
                                    tooltip: 'Continue with Apple',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<AppState>().setDemo(true);
                                  context.go('/home');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                child: const Text('Try Demo Mode'),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Don't have an account? "),
                                  GestureDetector(
                                    onTap: () => context.push('/signup'),
                                    child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(labelText: 'Email'),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) =>
                                      (v == null || v.isEmpty || !v.contains('@'))
                                          ? 'Enter a valid email'
                                          : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: const InputDecoration(labelText: 'Password'),
                                  obscureText: true,
                                  validator: (v) =>
                                      (v == null || v.length < 6) ? 'Min 6 chars' : null,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  key: const Key('loginSubmit'),
                                  onPressed: _loading
                                      ? null
                                      : () async {
                                          if (!_formKey.currentState!.validate()) return;
                                          setState(() => _loading = true);
                                          await Future.delayed(
                                            const Duration(milliseconds: 400),
                                          );
                                          final email = _emailController.text.trim();
                                          if (!context.mounted) return;
                                          await context.read<AuthState>().login(email);
                                          if (!context.mounted) return;
                                          // After login, go directly into Quick Start intake
                                          context.go('/quickstart/1');
                                        },
                                  child: _loading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Sign In'),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  key: const Key('loginCreateAccountLink'),
                                  onPressed: () => context.push('/signup'),
                                  child: const Text('Create an account'),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => setState(() => _mode = _LoginMode.choice),
                                  child: const Text('Back'),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  // Demo credentials (optional)
                  Text(
                    'Demo credentials:\nUser: any email',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
