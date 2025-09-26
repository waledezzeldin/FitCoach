import 'api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/env.dart';
import '../demo/demo_session.dart';

class AuthService {
  final _api = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _api.dio.post('/auth/login', data: {"email": email, "password": password});
      final data = (res.data as Map<String, dynamic>);
      await _saveTokensFromResponse(data);
      return data;
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Login failed'));
    }
  }

  Future<void> demoLogin(String email, String password) async {
    if (Env.demo) return; // success
    // ...existing real login...
  }

  Future<Map<String, dynamic>> signup(String email, String password, {String? name}) async {
    try {
      final res = await _api.dio.post('/auth/signup', data: {"email": email, "password": password, "name": name});
      final data = (res.data as Map<String, dynamic>);
      await _saveTokensFromResponse(data);
      return data;
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Sign up failed'));
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _api.dio.post('/auth/forgot-password', data: {"email": email});
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to send OTP'));
    }
  }

  Future<void> resetPassword({required String email, required String otp, required String newPassword}) async {
    try {
      await _api.dio.post('/auth/reset-password', data: {"email": email, "otp": otp, "newPassword": newPassword});
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to reset password'));
    }
  }

  // Social sign-in (unified)
  Future<Map<String, dynamic>> signInWithGoogle(String idToken) async {
    try {
      final res = await _api.dio.post('/auth/social/google', data: {"idToken": idToken});
      final data = (res.data as Map<String, dynamic>);
      await _saveTokensFromResponse(data);
      return data;
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Google sign-in failed'));
    }
  }

  Future<Map<String, dynamic>> signInWithFacebook(String accessToken) async {
    try {
      final res = await _api.dio.post('/auth/social/facebook', data: {"accessToken": accessToken});
      final data = (res.data as Map<String, dynamic>);
      await _saveTokensFromResponse(data);
      return data;
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Facebook sign-in failed'));
    }
  }

  Future<Map<String, dynamic>> signInWithApple({
    required String identityToken,
    required String authorizationCode,
  }) async {
    try {
      final res = await _api.dio.post('/auth/social/apple', data: {
        "identityToken": identityToken,
        "authorizationCode": authorizationCode,
      });
      final data = (res.data as Map<String, dynamic>);
      await _saveTokensFromResponse(data);
      return data;
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Apple sign-in failed'));
    }
  }

  // Firebase phone auth -> backend session exchange
  Future<Map<String, dynamic>> exchangeFirebaseIdToken(String idToken) async {
    try {
      final res = await _api.dio.post('/auth/firebase/exchange', data: {"idToken": idToken});
      final data = (res.data as Map<String, dynamic>);
      await _saveTokensFromResponse(data);
      return data;
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Session exchange failed'));
    }
  }

  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout');
    } catch (_) {
      // ignore server errors on logout
    } finally {
      await _api.clearTokens();
    }
  }

  Future<void> signOut() async {
    if (Env.demo) return;
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _saveTokensFromResponse(Map data) async {
    final access = (data['access_token'] ?? data['accessToken'])?.toString();
    final refresh = (data['refresh_token'] ?? data['refreshToken'])?.toString();
    if (access != null && access.isNotEmpty) {
      await _api.saveTokens(access: access, refresh: refresh);
    }
  }
}