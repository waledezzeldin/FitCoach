import 'api_service.dart';

class CoachService {
  final _api = ApiService();

  Future<Map<String, dynamic>> dashboard(String coachId, {required String userId}) async {
    try {
      final res = await _api.dio.get('/v1/coaches/$coachId/dashboard', queryParameters: {'userId': userId});
      return (res.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load coach dashboard'));
    }
  }

  Future<Map<String, dynamic>> profile(String coachId, {String? userId}) async {
    try {
      final res = await _api.dio.get(
        '/v1/coaches/$coachId/profile',
        queryParameters: {
          if (userId != null) 'userId': userId,
        },
      );
      return (res.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load coach profile'));
    }
  }

  Future<Map<String, dynamic>> availability(String coachId, {int days = 7}) async {
    try {
      final res = await _api.dio.get('/v1/sessions/availability/$coachId', queryParameters: {'days': days});
      return (res.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load availability'));
    }
  }

  Future<Map<String, dynamic>> bookSession({
    required String coachId,
    required String userId,
    required DateTime start,
    int durationMinutes = 30,
  }) async {
    try {
      final res = await _api.dio.post('/v1/sessions', data: {
        'coachId': coachId,
        'userId': userId,
        'scheduledAt': start.toIso8601String(),
        'durationMin': durationMinutes,
      });
      return (res.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to book session'));
    }
  }

  Future<void> rateSession({
    required String sessionId,
    required String userId,
    required int rating,
    String? note,
  }) async {
    try {
      await _api.dio.post('/v1/sessions/$sessionId/rate', data: {
        'userId': userId,
        'rating': rating,
        if (note != null && note.isNotEmpty) 'note': note,
      });
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to submit rating'));
    }
  }

  Future<Map<String, dynamic>> clientDetail(String coachId, String userId) async {
    try {
      final res = await _api.dio.get('/v1/coaches/$coachId/clients/$userId');
      return (res.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load client detail'));
    }
  }

  Future<List<Map<String, dynamic>>> fetchMessages(String coachId, {String? userId}) async {
    try {
      final res = await _api.dio.get('/v1/coaches/$coachId/messages', queryParameters: {
        if (userId != null) 'userId': userId,
      });
      final data = res.data as Map<String, dynamic>;
      return (data['messages'] as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load messages'));
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String coachId,
    required String userId,
    required String sender,
    String? body,
    Map<String, dynamic>? attachment,
  }) async {
    try {
      final res = await _api.dio.post('/v1/coaches/$coachId/messages', data: {
        'userId': userId,
        'sender': sender,
        'body': body,
        if (attachment != null) ...attachment,
      });
      return (res.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to send message'));
    }
  }
}