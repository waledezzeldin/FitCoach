import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animated_reveal.dart';

class OTPAuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  
  const OTPAuthScreen({
    super.key,
    required this.onAuthenticated,
  });

  @override
  State<OTPAuthScreen> createState() => _OTPAuthScreenState();
}

class _OTPAuthScreenState extends State<OTPAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers = 
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = 
      List.generate(6, (_) => FocusNode());
  
  bool _showOTPInput = false;
  bool _isResendEnabled = false;
  int _resendCountdown = 60;
  
  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }
  
  void _startResendCountdown() {
    setState(() {
      _isResendEnabled = false;
      _resendCountdown = 60;
    });
    
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return false;
      
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) {
          _isResendEnabled = true;
        }
      });
      
      return _resendCountdown > 0;
    });
  }
  
  Future<void> _requestOTP() async {
    final authProvider = context.read<AuthProvider>();
    final languageProvider = context.read<LanguageProvider>();
    final phone = _phoneController.text.trim();
    
    // Validate phone number (+966 5X XXX XXXX)
    if (!_isValidSaudiPhone(phone)) {
      _showError(languageProvider.t('otp_invalid_phone'));
      return;
    }
    
    final success = await authProvider.requestOTP(phone);
    
    if (success && mounted) {
      setState(() {
        _showOTPInput = true;
      });
      _startResendCountdown();
      _otpFocusNodes[0].requestFocus();
    } else if (authProvider.error != null && mounted) {
      _showError(authProvider.error!);
    }
  }
  
  Future<void> _verifyOTP() async {
    final authProvider = context.read<AuthProvider>();
    final languageProvider = context.read<LanguageProvider>();
    final phone = _phoneController.text.trim();
    final otp = _otpControllers.map((c) => c.text).join();
    
    if (otp.length < 6) {
      _showError(languageProvider.t('otp_incomplete'));
      return;
    }
    
    final success = await authProvider.verifyOTP(phone, otp);
    
    if (success && mounted) {
      widget.onAuthenticated();
    } else if (authProvider.error != null && mounted) {
      _showError(authProvider.error!);
      // Clear OTP fields
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _otpFocusNodes[0].requestFocus();
    }
  }
  
  bool _isValidSaudiPhone(String phone) {
    // Remove spaces and special characters
    final cleaned = phone.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check format: +966 5X XXX XXXX
    final regex = RegExp(r'^\+9665\d{8}$');
    return regex.hasMatch(cleaned);
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              
              // Logo
              AnimatedReveal(
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'عاش',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              AnimatedReveal(
                delay: const Duration(milliseconds: 120),
                child: Text(
                  _showOTPInput
                      ? languageProvider.t('enter_otp')
                      : languageProvider.t('enter_phone'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              AnimatedReveal(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  _showOTPInput
                      ? 'Enter the 6-digit code sent to ${_phoneController.text}'
                      : languageProvider.t('phone_hint'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              
              if (!_showOTPInput) ...[
                // Phone input
                AnimatedReveal(
                  delay: const Duration(milliseconds: 320),
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: languageProvider.t('enter_phone'),
                      hintText: '+966 5X XXX XXXX',
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Send OTP button
                AnimatedReveal(
                  delay: const Duration(milliseconds: 420),
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _requestOTP,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(languageProvider.t('send_otp')),
                  ),
                ),
              ] else ...[
                // OTP input
                AnimatedReveal(
                  delay: const Duration(milliseconds: 320),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 45,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _otpFocusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              _otpFocusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _otpFocusNodes[index - 1].requestFocus();
                            }
                            
                            // Auto-verify when all digits entered
                            if (index == 5 && value.isNotEmpty) {
                              _verifyOTP();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Verify button
                AnimatedReveal(
                  delay: const Duration(milliseconds: 420),
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _verifyOTP,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(languageProvider.t('verify')),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Resend code
                AnimatedReveal(
                  delay: const Duration(milliseconds: 500),
                  child: Center(
                    child: TextButton(
                      onPressed: _isResendEnabled ? _requestOTP : null,
                      child: Text(
                        _isResendEnabled
                            ? languageProvider.t('resend')
                            : 'Resend code in $_resendCountdown seconds',
                        style: TextStyle(
                          color: _isResendEnabled
                              ? AppColors.primary
                              : AppColors.textDisabled,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Change number
                AnimatedReveal(
                  delay: const Duration(milliseconds: 580),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _showOTPInput = false;
                          _phoneController.clear();
                          for (var controller in _otpControllers) {
                            controller.clear();
                          }
                        });
                      },
                      child: Text(languageProvider.t('change_phone')),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
