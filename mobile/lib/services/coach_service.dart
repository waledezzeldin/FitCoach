import 'api_service.dart';

class CoachService {
  final _api = ApiService();

  Future<List<Map<String, dynamic>>> listCoaches({int page = 1}) async {
    try {
      final res = await _api.dio.get('/coaches', queryParameters: {'page': page});
      return (res.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load coaches'));
    }
  }

  Future<List<Map<String, dynamic>>> reviews(String coachId) async {
    try {
      final res = await _api.dio.get('/coaches/$coachId/reviews');
      return (res.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load reviews'));
    }
  }

  Future<List<Map<String, dynamic>>> schedule(String coachId) async {
    try {
      final res = await _api.dio.get('/coaches/$coachId/schedule');
      return (res.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load schedule'));
    }
  }

  Future<Map<String, dynamic>> book({
    required String coachId,
    required String sessionId,
  }) async {
    try {
      final res = await _api.dio.post('/coaches/$coachId/bookings', data: {
        'sessionId': sessionId,
      });
      return (res.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to book session'));
    }
  }

  Future<List<Map<String, dynamic>>> videoCalls() async {
    try {
      final res = await _api.dio.get('/video-calls');
      return (res.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load video calls'));
    }
  }

  Future<Map<String, dynamic>> bookingSummary() async {
    try {
      final res = await _api.dio.get('/coaches/bookings/summary');
      return (res.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load quota'));
    }
  }

  Future<List<Map<String, dynamic>>> listBookings() async {
    try {
      final res = await _api.dio.get('/coaches/bookings');
      return (res.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to load bookings'));
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _api.dio.post('/coaches/bookings/$bookingId/cancel');
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to cancel booking'));
    }
  }

  Future<Map<String, dynamic>> rescheduleBooking({
    required String bookingId,
    required String newSessionId,
  }) async {
    try {
      final res = await _api.dio.post('/coaches/bookings/$bookingId/reschedule', data: {
        'sessionId': newSessionId,
      });
      return (res.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception(_api.mapError(e, fallback: 'Failed to reschedule'));
    }
  }
}