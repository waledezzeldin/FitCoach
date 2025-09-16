import 'api_service.dart';

class SessionService {
  final _api = ApiService();

  Future<Map<String, dynamic>> createSession(String coachId) async {
    final res = await _api.dio.post('/v1/sessions', data: {"coachId": coachId});
    return res.data;
  }

  Future<Map<String, dynamic>> joinSession(String sessionId) async {
    final res = await _api.dio.get('/v1/sessions/$sessionId/join');
    return res.data; // includes Agora token + channelName
  }
}
