import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

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
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'عاش',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  isArabic ? 'مرحباً بعودتك' : 'Welcome Back',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  isArabic 
                      ? 'تسجيل الدخول إلى حسابك'
                      : 'Sign in to your account',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Email or Phone input
                TextFormField(
                  controller: _emailOrPhoneController,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'البريد الإلكتروني أو رقم الهاتف' : 'Email or Phone',
                    hintText: isArabic ? 'example@email.com أو +966...' : 'example@email.com or +966...',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isArabic ? 'الرجاء إدخال البريد أو الهاتف' : 'Please enter email or phone';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Password input
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'كلمة المرور' : 'Password',
                    hintText: isArabic ? 'أدخل كلمة المرور' : 'Enter your password',
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
                      return isArabic ? 'الرجاء إدخال كلمة المرور' : 'Please enter password';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Remember me & Forgot password
                Row(
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
                          isArabic ? 'تذكرني' : 'Remember me',
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
                        isArabic ? 'نسيت كلمة المرور؟' : 'Forgot Password?',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Login button
                CustomButton(
                  text: authProvider.isLoading
                      ? (isArabic ? 'جاري التسجيل...' : 'Signing in...')
                      : (isArabic ? 'تسجيل الدخول' : 'Sign In'),
                  onPressed: authProvider.isLoading ? null : () => _handleLogin(isArabic),
                  variant: ButtonVariant.primary,
                  size: ButtonSize.large,
                  fullWidth: true,
                ),
                
                const SizedBox(height: 24),
                
                // Divider with "OR"
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        isArabic ? 'أو' : 'OR',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Continue with Phone (OTP)
                OutlinedButton.icon(
                  onPressed: () => _continueWithPhone(context),
                  icon: const Icon(Icons.phone, color: AppColors.primary),
                  label: Text(
                    isArabic ? 'المتابعة برقم الهاتف' : 'Continue with Phone',
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
                
                const SizedBox(height: 16),
                
                // Social login buttons
                Text(
                  isArabic ? 'أو المتابعة باستخدام' : 'Or continue with',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Social buttons row
                Row(
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
                
                const SizedBox(height: 32),
                
                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isArabic ? 'ليس لديك حساب؟' : 'Don\'t have an account?',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onNavigateToSignup,
                      child: Text(
                        isArabic ? 'إنشاء حساب' : 'Sign Up',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'استعادة كلمة المرور' : 'Forgot Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isArabic
                  ? 'أدخل بريدك الإلكتروني وسنرسل لك رابط الاستعادة'
                  : 'Enter your email and we\'ll send you a reset link',
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: isArabic ? 'البريد الإلكتروني' : 'Email',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic 
                        ? 'تم إرسال رابط الاستعادة'
                        : 'Reset link sent to your email',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(isArabic ? 'إرسال' : 'Send'),
          ),
        ],
      ),
    );
  }
}
