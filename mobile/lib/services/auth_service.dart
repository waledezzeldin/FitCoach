import 'api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _api = ApiService();
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> signup(String email, String password) async {
    final res = await _api.dio.post('/v1/auth/signup', data: {
      "email": email,
      "password": password,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _api.dio.post('/v1/auth/login', data: {
      "email": email,
      "password": password,
    });
    final token = res.data['access_token'];
    if (token != null) {
      await _storage.write(key: "access_token", value: token);
    }
    return res.data;
  }

  Future<void> logout() async {
    await _storage.delete(key: "access_token");
  }
}