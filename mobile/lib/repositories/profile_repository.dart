import '../config/env.dart';

class ProfileRepository {
  Future<Map<String, dynamic>> fetchMe() async {
    if (Env.demo) {
      return {
        'name': 'Demo User',
        'email': 'demo@example.com',
        'avatarUrl': null,
      };
    }
    // ...existing network code...
    // return real data
    throw UnimplementedError('Implement real fetchMe');
  }
}