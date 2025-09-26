import 'api_service.dart';

class UserService {
  final _api = ApiService();

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final res = await _api.dio.get('/user/profile');
      return (res.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load profile'));
    }
  }

  Future<void> updateProfile(Map<String, dynamic> payload) async {
    try {
      await _api.dio.put('/user/profile', data: payload);
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to update profile'));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _api.dio.post('/user/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to change password'));
    }
  }
}