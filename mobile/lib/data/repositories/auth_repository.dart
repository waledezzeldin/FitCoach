import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_profile.dart';
import '../../core/config/api_config.dart';

abstract class AuthRepositoryBase {
  Future<void> requestOTP(String phoneNumber);
  Future<AuthResponse> verifyOTP(String phoneNumber, String otpCode);
  Future<AuthResponse> loginWithEmailOrPhone({
    required String emailOrPhone,
    required String password,
  });
  Future<AuthResponse> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
  Future<AuthResponse> socialLogin(String provider);
  Future<String?> getStoredToken();
  Future<void> storeToken(String token);
  Future<void> removeToken();
  Future<UserProfile?> getUserProfile();
  Future<void> logout();
  Future<String?> refreshToken();
}

class AuthResponse {
  final String token;
  final UserProfile user;
  final bool isNewUser;
  
  AuthResponse({required this.token, required this.user, required this.isNewUser});
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
      isNewUser: json['isNewUser'] ?? false,
    );
  }
}

class AuthRepository implements AuthRepositoryBase {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  
  static const String _tokenKey = 'fitcoach_auth_token';
  
  AuthRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          contentType: ApiConfig.contentType,
        )),
        _secureStorage = const FlutterSecureStorage();
  
  // Request OTP
  Future<void> requestOTP(String phoneNumber) async {
    try {
      await _dio.post('/auth/send-otp', data: {
        'phoneNumber': phoneNumber,
      });
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to send OTP');
      }
      throw Exception('Network error. Please check your connection.');
    }
  }
  
  // Verify OTP
  Future<AuthResponse> verifyOTP(String phoneNumber, String otpCode) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {
          'phoneNumber': phoneNumber,
          'otpCode': otpCode,
        },
      );
      
      final data = response.data as Map<String, dynamic>;
      final user = UserProfile.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;
      
      return AuthResponse(user: user, token: token, isNewUser: data['isNewUser'] ?? false);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to verify OTP');
    }
  }
  
  // Login with email or phone + password
  Future<AuthResponse> loginWithEmailOrPhone({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'emailOrPhone': emailOrPhone,
          'password': password,
        },
      );
      
      final data = response.data as Map<String, dynamic>;
      final user = UserProfile.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;
      
      return AuthResponse(user: user, token: token, isNewUser: false);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }
  
  // Signup with email
  Future<AuthResponse> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/signup',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );
      
      final data = response.data as Map<String, dynamic>;
      final user = UserProfile.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;
      
      return AuthResponse(user: user, token: token, isNewUser: true);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Signup failed');
    }
  }
  
  // Social login (Google, Facebook, Apple)
  Future<AuthResponse> socialLogin(String provider) async {
    try {
      // In production, this would integrate with:
      // - google_sign_in package for Google
      // - flutter_facebook_auth for Facebook
      // - sign_in_with_apple for Apple
      
      // For now, simulate the flow
      final response = await _dio.post(
        '/auth/social-login',
        data: {
          'provider': provider,
          // In real implementation, include the OAuth token from the social provider
          // 'accessToken': socialAccessToken,
        },
      );
      
      final data = response.data as Map<String, dynamic>;
      final user = UserProfile.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;
      
      return AuthResponse(user: user, token: token, isNewUser: data['isNewUser'] ?? false);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Social login failed');
    }
  }
  
  // Get stored token
  Future<String?> getStoredToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }
  
  // Store token
  Future<void> storeToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw Exception('Failed to store authentication token');
    }
  }
  
  // Get user profile
  Future<UserProfile?> getUserProfile() async {
    try {
      final token = await getStoredToken();
      
      if (token == null) {
        return null;
      }
      
      final response = await _dio.get(
        '/users/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      return UserProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token expired, clear it
        await logout();
        return null;
      }
      return null;
    }
  }

  // Remove token
  @override
  Future<void> removeToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      throw Exception('Failed to remove authentication token');
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      throw Exception('Failed to logout');
    }
  }
  
  // Refresh token
  Future<String?> refreshToken() async {
    try {
      final currentToken = await getStoredToken();
      
      if (currentToken == null) {
        return null;
      }
      
      final response = await _dio.post(
        '/auth/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer $currentToken'},
        ),
      );
      
      final newToken = response.data['token'] as String;
      await storeToken(newToken);
      
      return newToken;
    } catch (e) {
      return null;
    }
  }
}
