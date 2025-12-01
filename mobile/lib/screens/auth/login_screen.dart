import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../services/auth_service.dart';
import '../../state/app_state.dart';
import '../../widgets/primary_cta.dart';
import '../../demo/demo_launcher.dart';
import '../../design_system/design_tokens.dart';
import 'phone_login_screen.dart';

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
    setState(() {
      isLoading = true;
      error = null;
    });
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
    setState(() {
      isLoading = true;
      error = null;
    });
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
    setState(() {
      isLoading = true;
      error = null;
    });
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
      setState(() {
        isLoading = true;
        error = null;
      });
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

  Future<void> _showDemoSheet() async {
    if (!mounted) return;
    await DemoLauncher.showSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabIndicator = BoxDecoration(
      color: Colors.white.withOpacity(0.14),
      borderRadius: BorderRadius.circular(28),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF03030D), Color(0xFF09091D), Color(0xFF050208)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: DefaultTabController(
            length: 2,
            initialIndex: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose how you want to sign in',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: TabBar(
                      labelStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      indicator: tabIndicator,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: const [
                        Tab(text: 'Phone'),
                        Tab(text: 'Email'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const PhoneLoginPanel(
                          embedded: true,
                          showDemoCta: false,
                          showEmailSwitch: false,
                          showHeader: false,
                        ),
                        _buildEmailTab(theme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.visibility_outlined),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.12),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(54),
                    ),
                    onPressed: isLoading ? null : _showDemoSheet,
                    label: const Text('Try Demo Mode'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                    child: const Text('Create account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTab(ThemeData theme) {
    final cs = theme.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _glassCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: _fieldDecoration(label: 'Email', icon: Icons.alternate_email),
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
                    decoration: _fieldDecoration(label: 'Password', icon: Icons.lock_outline),
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    validator: (val) => val == null || val.isEmpty ? 'Password is required' : null,
                    onChanged: (val) => setState(() => password = val),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/forgot_password'),
                      child: const Text('Forgot password?', style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                  if (error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: FitCoachColors.destructive.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(error!, style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryCTA(
                      label: 'Sign in with Email',
                      onPressed: isLoading ? null : _submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Or continue with', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          const SizedBox(height: 12),
          Column(
            children: [
              _ssoButton(
                icon: Icons.g_mobiledata,
                label: 'Continue with Google',
                onTap: isLoading ? null : _signInWithGoogle,
                color: cs.primary,
              ),
              const SizedBox(height: 12),
              _ssoButton(
                icon: Icons.facebook,
                label: 'Continue with Facebook',
                onTap: isLoading ? null : _signInWithFacebook,
                color: const Color(0xFF1877F2),
              ),
              const SizedBox(height: 12),
              _ssoButton(
                icon: Icons.apple,
                label: 'Continue with Apple',
                onTap: isLoading ? null : _signInWithApple,
                color: Colors.white,
                foreground: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ssoButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color color,
    Color? foreground,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: foreground ?? Colors.white),
        label: Text(label, style: TextStyle(color: foreground ?? Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foreground ?? Colors.white,
          minimumSize: const Size.fromHeight(52),
        ),
        onPressed: onTap,
      ),
    );
  }

  InputDecoration _fieldDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.white),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 40, offset: Offset(0, 24)),
        ],
      ),
      child: child,
    );
  }
}
