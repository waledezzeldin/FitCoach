import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ApiService {
  // Add your API methods here

  Future<dynamic> login(String email, String password) async {
    // TODO: Implement actual API call logic here
    // For now, simulate a successful login response
    await Future.delayed(Duration(seconds: 1));
    return {'success': true, 'email': email};
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> sendDeviceTokenToBackend(String userId) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await Dio().post(
        'http://your-backend-url/v1/users/device-token',
        data: {'userId': userId, 'deviceToken': fcmToken},
      );
    }
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    final googleSignIn = GoogleSignIn.instance;
    final account = await googleSignIn.attemptLightweightAuthentication();
    final auth = await account?.authentication;
    final idToken = auth?.idToken;
    if (idToken != null) {
      final response = await Dio().post(
        'http://your-backend-url/v1/users/social',
        data: {'provider': 'google', 'idToken': idToken},
      );
      // Save JWT and user info from response
      final userId = response.data['user']['id'];
      await sendDeviceTokenToBackend(userId); // <-- Register device token
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google login successful!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google login failed')),
      );
    }
  }

  Future<void> handleFacebookSignIn(BuildContext context) async {
    final result = await FacebookAuth.instance.login();
    final accessToken = result.accessToken?.tokenString;
    if (accessToken != null) {
      final response = await Dio().post(
        'http://your-backend-url/v1/users/social',
        data: {'provider': 'facebook', 'accessToken': accessToken},
      );
      // Save JWT and user info from response
      final userId = response.data['user']['id'];
      await sendDeviceTokenToBackend(userId); // <-- Register device token
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Facebook login successful!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Facebook login failed')),
      );
    }
  }

  Future<void> handleAppleSignIn(BuildContext context) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );
      final accessToken = credential.identityToken;
      if (accessToken != null) {
        final response = await Dio().post(
          'http://your-backend-url/v1/users/social',
          data: {'provider': 'apple', 'accessToken': accessToken},
        );
        // Save JWT and user info from response
        final userId = response.data['user']['id'];
        await sendDeviceTokenToBackend(userId); // <-- Register device token
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Apple login successful!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apple login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Apple login error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ...existing login fields...
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('Sign in with Google'),
              onPressed: () => handleGoogleSignIn(context),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.apple),
              label: const Text('Sign in with Apple'),
              onPressed: () => handleAppleSignIn(context),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.facebook),
              label: const Text('Sign in with Facebook'),
              onPressed: () => handleFacebookSignIn(context),
            ),
          ],
        ),
      ),
    );
  }
}
