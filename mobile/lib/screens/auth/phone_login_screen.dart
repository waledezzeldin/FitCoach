import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../state/app_state.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  FirebaseAuth? _auth;            // was: FirebaseAuth.instance (field init) -> causes crash
  bool _ready = false;
  String? _err;

  @override
  void initState() {
    super.initState();
    _initFirebase();
  }

  Future<void> _initFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _auth = FirebaseAuth.instance;
    } catch (e) {
      _err = 'Phone auth unavailable';
    } finally {
      if (mounted) setState(() => _ready = true);
    }
  }

  String phone = '';
  String smsCode = '';
  String? verificationId;
  bool sending = false;
  bool verifying = false;
  String? error;
  String? info;

  Future<void> _sendOtp() async {
    if (!_phoneKey.currentState!.validate()) return;
    setState(() { sending = true; error = null; info = null; });

    await _auth!.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await _auth!.signInWithCredential(credential);
          await _exchangeAndProceed();
        } catch (e) {
          if (mounted) setState(() => error = 'Auto verification failed');
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => error = e.message ?? 'Verification failed');
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          info = 'OTP sent';
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    ).whenComplete(() {
      if (mounted) setState(() => sending = false);
    });
  }

  Future<void> _verifyOtp() async {
    if (verificationId == null) {
      setState(() => error = 'Send OTP first');
      return;
    }
    if (!_otpKey.currentState!.validate()) return;
    setState(() { verifying = true; error = null; info = null; });
    try {
      final cred = PhoneAuthProvider.credential(verificationId: verificationId!, smsCode: smsCode);
      await _auth!.signInWithCredential(cred);
      await _exchangeAndProceed();
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message ?? 'Invalid code');
    } catch (_) {
      setState(() => error = 'Verification failed');
    } finally {
      if (mounted) setState(() => verifying = false);
    }
  }

  Future<void> _exchangeAndProceed() async {
    final user = _auth!.currentUser;
    final idToken = await user?.getIdToken(true);
    if (idToken == null) {
      setState(() => error = 'Unable to get ID token');
      return;
    }
    try {
      await AuthService().exchangeFirebaseIdToken(idToken);
      await AppStateScope.of(context).signIn(subscription: 'freemium');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  final _phoneKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_auth == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Phone Login')),
        body: Center(child: Text(_err ?? 'Phone auth unavailable')),
      );
    }

    final green = Theme.of(context).colorScheme.primary;
    InputDecoration deco(String label) => InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: green),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: green)),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: green)),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Phone Login'), backgroundColor: Colors.black, foregroundColor: green),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
            if (info != null) Text(info!, style: TextStyle(color: green)),
            Form(
              key: _phoneKey,
              child: TextFormField(
                enabled: verificationId == null,
                keyboardType: TextInputType.phone,
                decoration: deco('Phone (e.g. +1 5551234567)'),
                style: const TextStyle(color: Colors.white),
                validator: (v) => (v == null || !v.trim().startsWith('+') || v.trim().length < 8) ? 'Enter E.164 phone' : null,
                onChanged: (v) => phone = v.trim(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: sending || verificationId != null ? null : _sendOtp,
              child: sending ? const CircularProgressIndicator() : const Text('Send OTP'),
            ),
            const SizedBox(height: 24),
            if (verificationId != null) ...[
              Form(
                key: _otpKey,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: deco('Enter OTP'),
                  style: const TextStyle(color: Colors.white),
                  validator: (v) => (v == null || v.trim().length < 4) ? 'Enter valid OTP' : null,
                  onChanged: (v) => smsCode = v.trim(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: verifying ? null : _verifyOtp,
                child: verifying ? const CircularProgressIndicator() : const Text('Verify & Continue'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}