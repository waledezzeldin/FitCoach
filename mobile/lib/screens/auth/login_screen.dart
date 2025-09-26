import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../services/auth_service.dart';
import '../../state/app_state.dart';
import '../../widgets/primary_cta.dart';
import '../../config/env.dart';
import '../../demo/demo_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;
  String? error;

  Future<void> _signInWithGoogle() async {
    setState(() => isLoading = true);
    try {
      final googleSignIn = GoogleSignIn.instance;
      final account = await googleSignIn.attemptLightweightAuthentication();
      final auth = await account?.authentication;
      final idToken = auth?.idToken;
      if (idToken == null) throw Exception('Google token missing');
      await AuthService().signInWithGoogle(idToken);
      final app = AppStateScope.of(context);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        app.needsIntake ? '/intake' : '/dashboard',
      );
    } catch (e) {
      setState(() => error = 'Google sign-in failed');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() => isLoading = true);
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) throw Exception('Canceled');
      await AuthService().signInWithFacebook(result.accessToken!.tokenString);
      final app = AppStateScope.of(context);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        app.needsIntake ? '/intake' : '/dashboard',
      );
    } catch (e) {
      setState(() => error = 'Facebook sign-in failed');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => isLoading = true);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );
      final idTok = credential.identityToken;
      final code = credential.authorizationCode;
      if (idTok == null || code.isEmpty) throw Exception('Apple token missing');
      await AuthService().signInWithApple(identityToken: idTok, authorizationCode: code);
      final app = AppStateScope.of(context);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        app.needsIntake ? '/intake' : '/dashboard',
      );
    } catch (e) {
      setState(() => error = 'Apple sign-in failed');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        await AuthService().login(email, password);
        final app = AppStateScope.of(context);
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          app.needsIntake ? '/intake' : '/dashboard',
        );
      } catch (e) {
        setState(() => error = 'Email/password sign-in failed');
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  void _demoGo(DemoRole role) async {
    DemoSession.role = role;
    await AppStateScope.of(context).signIn(
      user: {'id': 'demo_${role.name}', 'role': role.name},
      subscription: role == DemoRole.user ? 'freemium' : 'pro',
    );
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppStateScope.of(context).needsIntake ? '/intake' : '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo
          const SizedBox(height: 32),
          Center(child: Image.asset('assets/branding/logo.png', width: 96, height: 96, semanticLabel: 'FitCoach')),
          const SizedBox(height: 24),

          TextFormField(
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: cs.primary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: cs.primary),
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
              labelStyle: TextStyle(color: cs.primary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: cs.primary),
              ),
            ),
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            validator: (val) => val == null || val.isEmpty ? 'Password is required' : null,
            onChanged: (val) => setState(() => password = val),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgot_password'),
              child: Text('Forgot password?', style: TextStyle(color: cs.primary)),
            ),
          ),
          PrimaryCTA(
            label: 'Sign in',
            onPressed: isLoading ? null : _submit,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
            child: const Text('Create account'),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.g_mobiledata, color: Colors.white),
            label: const Text('Sign in with Google'),
            style: ElevatedButton.styleFrom(backgroundColor: cs.primary),
            onPressed: isLoading ? null : _signInWithGoogle,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.facebook, color: Colors.white),
            label: const Text('Sign in with Facebook'),
            style: ElevatedButton.styleFrom(backgroundColor: cs.primary),
            onPressed: isLoading ? null : _signInWithFacebook,
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.apple, color: Colors.white),
            label: const Text('Sign in with Apple'),
            style: ElevatedButton.styleFrom(backgroundColor: cs.primary),
            onPressed: isLoading ? null : _signInWithApple,
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/phone_login'),
            icon: const Icon(Icons.phone),
            label: const Text('Continue with Phone'),
          ),
          // Demo-only bypass buttons (appear only when --dart-define=DEMO=true)
          if (Env.demo) ...[
            const SizedBox(height: 20),
            Center(child: Text('Demo login', style: TextStyle(color: cs.onSurfaceVariant))),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MiniRoleButton(label: 'User',    color: cs.primary, onTap: () => _demoGo(DemoRole.user)),
                const SizedBox(width: 10),
                _MiniRoleButton(label: 'Coach',   color: cs.primary, onTap: () => _demoGo(DemoRole.coach)),
                const SizedBox(width: 10),
                _MiniRoleButton(label: 'Admin',   color: cs.primary, onTap: () => _demoGo(DemoRole.admin)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;
  const _SocialIconButton({required this.icon, this.tooltip, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 44,
      height: 44,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 44), // override global min size
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          side: BorderSide(color: cs.primary, width: 1.2),
        ),
        onPressed: onPressed,
        child: Icon(icon, color: cs.primary, size: 22),
      ),
    );
  }
}

class _MiniRoleButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MiniRoleButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(height: 44), // fixed height to match style
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),      // allow narrow width, fixed height
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: const StadiumBorder(),
          side: BorderSide(color: color, width: 1.2),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: onTap,
        child: Text(label, style: TextStyle(color: color)),
      ),
    );
  }
}
