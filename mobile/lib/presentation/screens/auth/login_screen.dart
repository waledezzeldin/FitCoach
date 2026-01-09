import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/animated_reveal.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  final VoidCallback onNavigateToSignup;
  
  const LoginScreen({
    super.key,
    required this.onAuthenticated,
    required this.onNavigateToSignup,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo
                AnimatedReveal(
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo_primary.png',
                          width: 56,
                          height: 56,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                AnimatedReveal(
                  delay: const Duration(milliseconds: 80),
                  offset: Offset(isArabic ? -0.2 : 0.2, 0),
                  child: Text(
                    languageProvider.t('welcome_back'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                AnimatedReveal(
                  delay: const Duration(milliseconds: 140),
                  offset: Offset(isArabic ? -0.18 : 0.18, 0),
                  child: Text(
                    languageProvider.t('sign_in_subtitle'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 40),

                // Email or Phone input
                AnimatedReveal(
                  delay: const Duration(milliseconds: 220),
                  child: TextFormField(
                    controller: _emailOrPhoneController,
                    decoration: InputDecoration(
                      labelText: languageProvider.t('email_or_phone'),
                      hintText: languageProvider.t('email_or_phone_hint'),
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return languageProvider.t('email_or_phone');
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Password input
                AnimatedReveal(
                  delay: const Duration(milliseconds: 280),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: languageProvider.t('password'),
                      hintText: languageProvider.t('password_hint'),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return languageProvider.t('password');
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Remember me & Forgot password
                AnimatedReveal(
                  delay: const Duration(milliseconds: 340),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            languageProvider.t('remember_me'),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to forgot password
                          _showForgotPasswordDialog(isArabic);
                        },
                        child: Text(
                          languageProvider.t('forgot_password'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Login button
                AnimatedReveal(
                  delay: const Duration(milliseconds: 420),
                  child: CustomButton(
                    text: authProvider.isLoading ? languageProvider.t('signing_in') : languageProvider.t('sign_in'),
                    onPressed: authProvider.isLoading ? null : () => _handleLogin(isArabic),
                    variant: ButtonVariant.primary,
                    size: ButtonSize.large,
                    fullWidth: true,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Divider with "OR"
                AnimatedReveal(
                  delay: const Duration(milliseconds: 480),
                  child: Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          languageProvider.t('or'),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Continue with Phone (OTP)
                AnimatedReveal(
                  delay: const Duration(milliseconds: 540),
                  child: OutlinedButton.icon(
                    onPressed: () => _continueWithPhone(context),
                    icon: const Icon(Icons.phone, color: AppColors.primary),
                    label: Text(
                      languageProvider.t('continue_with_phone'),
                      style: const TextStyle(color: AppColors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Social login buttons
                AnimatedReveal(
                  delay: const Duration(milliseconds: 600),
                  child: Text(
                    languageProvider.t('or_continue_with'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Social buttons row
                AnimatedReveal(
                  delay: const Duration(milliseconds: 660),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSocialButton(
                          icon: Icons.g_mobiledata,
                          label: 'Google',
                          color: const Color(0xFFDB4437),
                          onPressed: () => _socialLogin('google', isArabic),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSocialButton(
                          icon: Icons.facebook,
                          label: 'Facebook',
                          color: const Color(0xFF4267B2),
                          onPressed: () => _socialLogin('facebook', isArabic),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSocialButton(
                          icon: Icons.apple,
                          label: 'Apple',
                          color: Colors.black,
                          onPressed: () => _socialLogin('apple', isArabic),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Sign up link
                AnimatedReveal(
                  delay: const Duration(milliseconds: 740),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        languageProvider.t('dont_have_account'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onNavigateToSignup,
                        child: Text(
                          languageProvider.t('sign_up'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
  
  Future<void> _handleLogin(bool isArabic) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final authProvider = context.read<AuthProvider>();
    final emailOrPhone = _emailOrPhoneController.text.trim();
    final password = _passwordController.text;
    
    final success = await authProvider.loginWithEmailOrPhone(
      emailOrPhone: emailOrPhone,
      password: password,
    );
    
    if (success && mounted) {
      widget.onAuthenticated();
    } else if (authProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  void _continueWithPhone(BuildContext context) {
    // Navigate to OTP screen
    Navigator.pushNamed(context, '/otp-auth');
  }
  
  Future<void> _socialLogin(String provider, bool isArabic) async {
    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.socialLogin(provider);
    
    if (success && mounted) {
      widget.onAuthenticated();
    } else if (authProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  void _showForgotPasswordDialog(bool isArabic) {
    final languageProvider = context.read<LanguageProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageProvider.t('forgot_password_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(languageProvider.t('forgot_password_desc')),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: languageProvider.t('email'),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(languageProvider.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(languageProvider.t('reset_link_sent')),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(languageProvider.t('send')),
          ),
        ],
      ),
    );
  }
}
