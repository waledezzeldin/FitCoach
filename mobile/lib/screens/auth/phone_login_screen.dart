import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../demo/demo_launcher.dart';
import '../../design_system/design_tokens.dart';
import '../../localization/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../state/app_state.dart';
import '../../widgets/primary_cta.dart';

class PhoneLoginScreen extends StatelessWidget {
  const PhoneLoginScreen({super.key});

  @override
  Widget build(BuildContext context) => const PhoneLoginPanel();
}

class PhoneLoginPanel extends StatefulWidget {
  const PhoneLoginPanel({
    super.key,
    this.embedded = false,
    this.showEmailSwitch = true,
    this.showDemoCta = true,
    this.showHeader = true,
  });

  final bool embedded;
  final bool showEmailSwitch;
  final bool showDemoCta;
  final bool showHeader;

  @override
  State<PhoneLoginPanel> createState() => _PhoneLoginPanelState();
}

class _PhoneLoginPanelState extends State<PhoneLoginPanel> {
  FirebaseAuth? _auth;
  bool _ready = false;

  final _phoneKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  String? verificationId;
  bool sending = false;
  bool verifying = false;
  String? bannerError;
  String? bannerInfo;

  Timer? _resendTicker;
  int _resendSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initFirebase();
  }

  @override
  void dispose() {
    _resendTicker?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _initFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _auth = FirebaseAuth.instance;
    } catch (_) {
      _auth = null;
    } finally {
      if (mounted) setState(() => _ready = true);
    }
  }

  String get _phone => _phoneController.text.trim();
  String get _otp => _otpController.text.trim();
  bool get _hasCode => verificationId != null;

  Future<void> _sendOtp({bool isResend = false}) async {
    if (_auth == null) return;
    final l10n = context.l10n;
    if (!isResend && !_phoneKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      sending = true;
      bannerError = null;
      bannerInfo = null;
    });

    try {
      await _auth!.verifyPhoneNumber(
        phoneNumber: _phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth!.signInWithCredential(credential);
            await _exchangeAndProceed();
          } catch (_) {
            if (mounted) {
              setState(() => bannerError = l10n.t('auth.autoVerificationFailed'));
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => bannerError = e.message ?? l10n.t('auth.phoneUnavailable'));
        },
        codeSent: (String verId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            verificationId = verId;
            bannerInfo = l10n.t('auth.codeSent');
            _otpController.clear();
          });
          _startResendCountdown();
        },
        codeAutoRetrievalTimeout: (String verId) {
          if (!mounted) return;
          setState(() => verificationId = verId);
        },
      );
    } catch (e) {
      if (mounted) setState(() => bannerError = l10n.t('auth.phoneUnavailable'));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  Future<void> _verifyOtp() async {
    final l10n = context.l10n;
    if (verificationId == null) {
      setState(() => bannerError = l10n.t('auth.sendOtpFirst'));
      return;
    }
    if (!_otpKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      verifying = true;
      bannerError = null;
      bannerInfo = null;
    });
    try {
      final cred = PhoneAuthProvider.credential(verificationId: verificationId!, smsCode: _otp);
      await _auth!.signInWithCredential(cred);
      await _exchangeAndProceed();
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => bannerError = e.message ?? l10n.t('auth.invalidOtp'));
    } catch (_) {
      if (mounted) setState(() => bannerError = l10n.t('auth.invalidOtp'));
    } finally {
      if (mounted) setState(() => verifying = false);
    }
  }

  Future<void> _exchangeAndProceed() async {
    final current = _auth?.currentUser;
    final idToken = await current?.getIdToken(true);
    if (idToken == null) {
      setState(() => bannerError = context.l10n.t('auth.phoneUnavailable'));
      return;
    }
    try {
      final payload = await AuthService().exchangeFirebaseIdToken(idToken);
      final app = AppStateScope.of(context);
      final user = (payload['user'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final subscription = (payload['subscriptionType'] ?? payload['subscription'] ?? 'freemium').toString();
      final role = (user['role'] ?? payload['role'])?.toString();
      await app.signIn(user: user, subscription: subscription, role: role);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, app.resolveLandingRoute());
    } catch (e) {
      if (mounted) {
        setState(() => bannerError = e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void _startResendCountdown() {
    _resendTicker?.cancel();
    setState(() => _resendSeconds = 30);
    _resendTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds -= 1);
      }
    });
  }

  void _resetFlow() {
    setState(() {
      verificationId = null;
      bannerInfo = null;
      bannerError = null;
      _otpController.clear();
      _resendTicker?.cancel();
      _resendSeconds = 0;
    });
  }

  Future<void> _showDemoSheet() async {
    if (!mounted) return;
    await DemoLauncher.showSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      const loader = Center(child: CircularProgressIndicator());
      if (widget.embedded) return loader;
      return const Scaffold(body: loader);
    }
    if (_auth == null) {
      final unavailable = Center(child: Text(context.l10n.t('auth.phoneUnavailable')));
      if (widget.embedded) return unavailable;
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.t('auth.phonePrimaryCta'))),
        body: unavailable,
      );
    }

    final l10n = context.l10n;
    final theme = Theme.of(context);
    final panel = _buildPanel(l10n, theme);

    if (widget.embedded) {
      return panel;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.t('auth.phonePrimaryCta')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050417), Color(0xFF090A1F), Color(0xFF050208)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(child: panel),
      ),
    );
  }

  Widget _buildPanel(AppLocalizations l10n, ThemeData theme) {
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader) ...[
          Text(
            l10n.t('auth.phoneTitle'),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.t('auth.phoneSubtitle'),
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
        ],
        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('auth.phoneHelpText'),
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              if (bannerError != null)
                _statusBanner(
                  icon: Icons.error_outline,
                  color: FitCoachColors.destructive,
                  message: bannerError!,
                ),
              if (bannerInfo != null)
                _statusBanner(
                  icon: Icons.check_circle_outline,
                  color: theme.colorScheme.primary,
                  message: bannerInfo!,
                ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _hasCode ? _buildOtpForm(l10n) : _buildPhoneForm(l10n),
              ),
            ],
          ),
        ),
        if (widget.showDemoCta) ...[
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.visibility_outlined),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.08),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
            ),
            onPressed: sending || verifying ? null : _showDemoSheet,
            label: Text(l10n.t('auth.demoCta')),
          ),
        ],
        if (widget.showEmailSwitch) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: Text(
              l10n.t('auth.useEmailInstead'),
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ],
    );

    final padding = widget.embedded ? const EdgeInsets.symmetric(horizontal: 4, vertical: 8) : const EdgeInsets.fromLTRB(24, 24, 24, 40);
    final constraints = BoxConstraints(maxWidth: widget.embedded ? 640 : 520);
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: padding,
        physics: widget.embedded ? const BouncingScrollPhysics() : null,
        child: ConstrainedBox(
          constraints: constraints,
          child: column,
        ),
      ),
    );
  }

  Widget _buildPhoneForm(AppLocalizations l10n) {
    return Form(
      key: _phoneKey,
      child: Column(
        key: const ValueKey('phone_form'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            decoration: _darkFieldDecoration(
              label: l10n.t('auth.phonePlaceholder'),
              icon: Icons.phone_outlined,
            ),
            validator: (value) {
              final v = value?.trim() ?? '';
              final valid = v.startsWith('+') && v.length >= 8;
              return valid ? null : l10n.t('auth.invalidPhone');
            },
          ),
          const SizedBox(height: 20),
          _gradientActionButton(
            label: l10n.t('auth.sendOtp'),
            busy: sending,
            icon: Icons.sms_outlined,
            onPressed: sending ? null : _sendOtp,
          ),
        ],
      ),
    );
  }

  Widget _buildOtpForm(AppLocalizations l10n) {
    final disableResend = _resendSeconds > 0 || sending;
    return Column(
      key: const ValueKey('otp_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.t('auth.enterCodeCta'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),
        Form(
          key: _otpKey,
          child: TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white, letterSpacing: 4),
            decoration: _darkFieldDecoration(
              label: l10n.t('auth.otpPlaceholder'),
              icon: Icons.lock_outline,
            ).copyWith(counterText: ''),
            validator: (value) {
              final v = value?.trim() ?? '';
              return v.length >= 4 ? null : l10n.t('auth.invalidOtp');
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton(
              onPressed: disableResend ? null : () => _sendOtp(isResend: true),
              child: Text(
                _resendSeconds > 0
                    ? '${l10n.t('auth.resendOtp')} (${_resendSeconds}s)'
                    : l10n.t('auth.resendOtp'),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: verifying ? null : _resetFlow,
              child: Text(l10n.t('auth.changeNumber')),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _gradientActionButton(
          label: l10n.t('auth.verifyOtp'),
          busy: verifying,
          icon: Icons.check_circle_outline,
          onPressed: verifying ? null : _verifyOtp,
        ),
      ],
    );
  }

  Widget _gradientActionButton({
    required String label,
    required bool busy,
    required VoidCallback? onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          PrimaryCTA(
            label: label,
            icon: icon,
            onPressed: busy ? null : onPressed,
          ),
          if (busy)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(26),
              ),
              alignment: Alignment.center,
              child: const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _darkFieldDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.18)),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 30, offset: Offset(0, 20)),
        ],
      ),
      child: child,
    );
  }

  Widget _statusBanner({required IconData icon, required Color color, required String message}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
